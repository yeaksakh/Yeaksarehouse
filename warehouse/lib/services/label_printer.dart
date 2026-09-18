import 'dart:async';
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  BluetoothDevice? _selected;
  BluetoothDevice? get selected => _selected;

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

  /// Send one already-rendered sticker.
  Future<PrinterResult> printImage(Uint8List pngBytes) async {
    final connected = await connect();
    if (!connected.succeeded) return connected;
    try {
      await _printer.printImageBytes(pngBytes);
      // Feed clear of the tear bar, or the packer tears through the next label.
      await _printer.printNewLine();
      return PrinterResult.ok(_selected);
    } catch (_) {
      return const PrinterResult.failed('The printer stopped part way through.');
    }
  }
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
