import 'dart:async';
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'label_bitmap.dart';
import 'tspl.dart';

/// Which language the machine on the other end actually speaks.
///
/// There is no reliable way to ask it. Some of these printers answer `~!T`,
/// many say nothing, and a till printer sent `~!T` just prints "~!T" on a
/// receipt. So the packer chooses it once in Profile, and the test print tells
/// them straight away whether they chose right.
enum PrinterLanguage {
  /// Label printers -- Vigo, TSC, Xprinter, and most machines that take a roll
  /// of die-cut stickers. The printer is told the label size and finds the gaps
  /// between labels itself.
  tspl,

  /// Till printers, like the one in Yeaksaundry: continuous paper, raster rows,
  /// no idea what a label is. Sent to a label printer this usually prints
  /// NOTHING AT ALL, which is why it is not the default.
  escPos;

  static PrinterLanguage fromStorage(String? value) =>
      PrinterLanguage.values.firstWhere((l) => l.name == value,
          orElse: () => PrinterLanguage.tspl);
}

/// Talking to the warehouse's Bluetooth label printer.
///
/// Modelled on the till app (`Yeaksaundry`), which has been printing to these
/// machines for months: remember one paired device, reconnect to it silently,
/// and send raster rows. A thermal printer cannot take a PDF, so the sticker is
/// drawn on the phone and sent as an image.
///
/// WHY THE DEVICE IS REMEMBERED BY NAME AND ADDRESS. `getBondedDevices` returns
/// whatever Android has paired right now, in no guaranteed order, and a
/// warehouse may have several machines paired. Storing both and matching on
/// both means a packer picks their printer once, not once per parcel.
///
/// NOTHING HERE THROWS FOR A MISSING PRINTER. Every call returns a
/// [PrinterResult] saying what happened, because "no printer chosen yet" and
/// "printer is switched off" are ordinary situations a packer has to be told
/// about plainly, not crashes.
class LabelPrinter {
  LabelPrinter({BlueThermalPrinter? printer})
      : _printer = printer ?? BlueThermalPrinter.instance;

  final BlueThermalPrinter _printer;

  /// `name|address`, matching the till app's own key format.
  static const _savedDeviceKey = 'label_printer_device_v1';
  static const _savedLanguageKey = 'label_printer_language_v1';

  BluetoothDevice? _selected;
  BluetoothDevice? get selected => _selected;

  PrinterLanguage _language = PrinterLanguage.tspl;
  PrinterLanguage get language => _language;

  /// The language the packer chose last time, or TSPL for a fresh install.
  Future<PrinterLanguage> restoreLanguage() async {
    final stored =
        (await SharedPreferences.getInstance()).getString(_savedLanguageKey);
    return _language = PrinterLanguage.fromStorage(stored);
  }

  Future<void> rememberLanguage(PrinterLanguage language) async {
    _language = language;
    await (await SharedPreferences.getInstance())
        .setString(_savedLanguageKey, language.name);
  }

  /// The printer the packer chose, if it is still paired with this phone.
  Future<BluetoothDevice?> restore() async {
    final stored = (await SharedPreferences.getInstance())
        .getString(_savedDeviceKey);
    if (stored == null || stored.isEmpty) return null;

    // Older builds stored "name|address"; keep reading those.
    final address = stored.contains('|') ? stored.split('|').last : stored;

    // Matched against what is ACTUALLY paired now: a printer that has been
    // unpaired since should show as "not set" rather than failing at the moment
    // someone presses print.
    for (final device in await devices()) {
      if (device.address == address) {
        _selected = device;
        return device;
      }
    }
    return null;
  }

  Future<void> remember(BluetoothDevice device) async {
    _selected = device;
    // Address only. Storing "name|address" wrote the literal text "null" for a
    // printer with no name, and restore then compared that against a real null
    // and never matched -- so the choice looked saved and was silently lost.
    // The address is what identifies the machine anyway; the name is a label.
    await (await SharedPreferences.getInstance())
        .setString(_savedDeviceKey, device.address ?? '');
  }

  Future<void> forget() async {
    _selected = null;
    await (await SharedPreferences.getInstance()).remove(_savedDeviceKey);
  }

  /// Printers already paired in Android's Bluetooth settings.
  ///
  /// Pairing itself is left to Android. Thermal printers want a PIN and
  /// sometimes a power cycle, and the system dialog handles that far better
  /// than anything this app could put on screen.
  Future<List<BluetoothDevice>> devices() async {
    try {
      return await _printer.getBondedDevices();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> get isOn async => (await _printer.isOn) ?? false;
  Future<bool> get isConnected async => (await _printer.isConnected) ?? false;

  /// Connect to [device], or to the remembered one. Safe to call repeatedly.
  Future<PrinterResult> connect([BluetoothDevice? device]) async {
    final target = device ?? _selected ?? await restore();
    if (target == null) {
      return const PrinterResult.failed(
          'No printer chosen yet. Pick one in Profile > Label printer.');
    }
    if (!await isOn) {
      return const PrinterResult.failed('Bluetooth is switched off.');
    }
    try {
      if (await isConnected) return PrinterResult.ok(target);
      await _printer.connect(target);
      _selected = target;
      return PrinterResult.ok(target);
    } catch (_) {
      // Almost always the printer being off or out of range, and a stack trace
      // helps nobody holding a parcel.
      return PrinterResult.failed(
          'Could not reach ${target.name ?? 'the printer'}. Is it switched on?');
    }
  }

  Future<void> disconnect() async {
    try {
      if (await isConnected) await _printer.disconnect();
    } catch (_) {
      // Already gone is the outcome we wanted.
    }
  }

  /// Send one already-rendered sticker, in whichever language is set.
  ///
  /// The two paths are not variations on a theme. TSPL hands the printer a
  /// label definition and a bitmap and tells it to print one; ESC/POS streams
  /// raster rows onto continuous paper and then feeds. A machine given the
  /// wrong one does not print a poor label, it prints nothing.
  Future<PrinterResult> printLabel(RenderedSticker sticker) async {
    final connected = await connect();
    if (!connected.succeeded) return connected;
    try {
      switch (_language) {
        case PrinterLanguage.tspl:
          await _sendChunked(Tspl.label(sticker.mono));
        case PrinterLanguage.escPos:
          // This path is unchanged from the version that printed to till
          // printers: `printImageBytes` wants a PNG and does its own dithering.
          await _printer.printImageBytes(sticker.png);
          // Feed clear of the tear bar, or the packer tears the next label.
          await _printer.printNewLine();
      }
      return PrinterResult.ok(_selected);
    } catch (_) {
      return const PrinterResult.failed('The printer stopped part way through.');
    }
  }

  /// Ask the printer to prove it speaks TSPL, using TSPL's own drawing commands.
  ///
  /// Deliberately NOT a bitmap: if the bitmap packing were the broken part, a
  /// bitmap test would fail too and point the finger at the wrong thing. A frame
  /// and a word come out of the printer's own font, so anything at all on the
  /// label means the language is right.
  Future<PrinterResult> printLanguageTest() async {
    final connected = await connect();
    if (!connected.succeeded) return connected;
    try {
      await _sendChunked(Tspl.testLabel());
      return PrinterResult.ok(_selected);
    } catch (_) {
      return const PrinterResult.failed('The printer stopped part way through.');
    }
  }

  /// Send in small pieces rather than one 11 KB write.
  ///
  /// A 45 x 30 mm sticker is 10,800 bytes of bitmap, and these machines have a
  /// receive buffer measured in hundreds of bytes. Handed the lot at once, a
  /// printer with no flow control quietly drops whatever overflows: the label
  /// comes out fine down to some arbitrary line and blank below it, or -- if
  /// the loss lands mid-payload and the printer is still waiting for bytes that
  /// will never arrive -- nothing comes out at all. A short pause between
  /// chunks gives it time to drain.
  static const _chunkBytes = 512;
  static const _chunkPause = Duration(milliseconds: 20);

  Future<void> _sendChunked(Uint8List bytes) async {
    for (var start = 0; start < bytes.length; start += _chunkBytes) {
      final end = start + _chunkBytes < bytes.length
          ? start + _chunkBytes
          : bytes.length;
      await _printer.writeBytes(Uint8List.sublistView(bytes, start, end));
      if (end < bytes.length) await Future<void>.delayed(_chunkPause);
    }
  }
}

/// One sticker drawn once, in both the forms the two languages need.
///
/// Rendering is not free and the two paths want different things -- TSPL takes
/// packed dots, `printImageBytes` takes a PNG -- so the widget is rasterised
/// once and both come out of the same pixels. That also means the label a
/// packer sees in the preview is provably the one that goes to the printer.
class RenderedSticker {
  const RenderedSticker({required this.mono, required this.png});

  final MonoBitmap mono;
  final Uint8List png;
}

/// What a printer call did, and what to tell the packer if it did not work.
class PrinterResult {
  const PrinterResult.ok(this.device)
      : succeeded = true,
        message = null;
  const PrinterResult.failed(this.message)
      : succeeded = false,
        device = null;

  final bool succeeded;
  final String? message;
  final BluetoothDevice? device;
}
