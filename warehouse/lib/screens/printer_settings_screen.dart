import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../models/box_label.dart';
import '../services/label_printer.dart';
import '../widgets/box_label_sticker.dart';

/// Choose which paired Bluetooth printer the box labels go to.
///
/// Pairing itself is left to Android's own Bluetooth settings: thermal printers
/// want a PIN and sometimes a power cycle, and the system dialog handles that
/// better than anything here could. This screen only picks between machines the
/// phone has already been introduced to.
class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key, required this.printer});

  final LabelPrinter printer;

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<BluetoothDevice> _devices = const [];
  BluetoothDevice? _selected;
  bool _loading = true;
  bool _testing = false;
  bool _bluetoothOff = false;
  PrinterLanguage _language = PrinterLanguage.tspl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final on = await widget.printer.isOn;
    final devices = on ? await widget.printer.devices() : <BluetoothDevice>[];
    final saved = await widget.printer.restore();
    final language = await widget.printer.restoreLanguage();
    if (!mounted) return;
    setState(() {
      _bluetoothOff = !on;
      _devices = devices;
      _selected = saved;
      _language = language;
      _loading = false;
    });
  }

  Future<void> _choose(BluetoothDevice device) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await widget.printer.remember(device);
    if (!mounted) return;
    setState(() => _selected = device);
    // Saved on tap rather than behind a Save button -- there is one setting on
    // this page and a button to confirm it would be a second thing to forget.
    // It still has to SAY so, or a packer cannot tell it took.
    messenger.showSnackBar(SnackBar(
        content: Text(l10n.printerSaved(device.name ?? l10n.unnamedPrinter))));
  }

  Future<void> _chooseLanguage(PrinterLanguage? language) async {
    if (language == null) return;
    await widget.printer.rememberLanguage(language);
    if (!mounted) return;
    setState(() => _language = language);
  }

  /// Ask the printer to prove it speaks TSPL, in TSPL's own drawing commands.
  ///
  /// Separate from [_testPrint] on purpose. If a sticker does not come out
  /// there are two possible reasons -- wrong language, or a bad bitmap -- and
  /// one button that tests both together cannot tell a packer which.
  Future<void> _testLanguage() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _testing = true);
    try {
      final result = await widget.printer.printLanguageTest();
      messenger.showSnackBar(SnackBar(
        content: Text(result.succeeded
            ? l10n.languageTestSent
            : result.message ?? l10n.somethingWentWrong),
      ));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  /// Print one sticker so the packer can see it came out straight before they
  /// trust it with a parcel. Far cheaper than discovering the alignment is off
  /// after twelve boxes have gone out.
  Future<void> _testPrint() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _testing = true);
    try {
      // A test sticker that exercises every row, including the QR: a test that
      // skipped it would come out clean and the first real label would not.
      final sticker = await renderStickerForPrinter(BoxLabelSticker(
        label: const BoxLabel(
            product: 'Test label',
            sku: 'TEST-SKU',
            boxNo: 1,
            boxTotal: 1,
            index: 1,
            total: 1,
            quantity: 4),
        invoiceNo: 'TEST',
        customer: 'Printer check',
        phone: '012 345 678',
        company: 'Company name',
        seller: 'Seller name  077 827 492',
        driver: 'Driver name',
        qrData: 'https://yeaksa.com/shipment/test',
        stamps: [
          LabelStamp(l10n.stampAccepted, 'Warehouse staff'),
          LabelStamp(l10n.stampPacked, 'Packer name'),
          LabelStamp(l10n.stampAudited, 'Supervisor name'),
        ],
      ));
      final result = await widget.printer.printLabel(sticker);
      messenger.showSnackBar(SnackBar(
        content: Text(result.succeeded
            ? l10n.testLabelSent
            : result.message ?? l10n.somethingWentWrong),
      ));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.labelPrinter),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_bluetoothOff)
                  _Note(
                    icon: Icons.bluetooth_disabled,
                    title: l10n.bluetoothIsOff,
                    body: l10n.bluetoothIsOffBody,
                  )
                else if (_devices.isEmpty)
                  _Note(
                    icon: Icons.print_disabled_outlined,
                    title: l10n.noPrintersPaired,
                    body: l10n.noPrintersPairedBody,
                  )
                else ...[
                  Text(l10n.pairedPrinters,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final device in _devices)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _choose(device),
                        leading: Icon(
                          _selected?.address == device.address
                              ? Icons.check_circle
                              : Icons.print_outlined,
                          color: _selected?.address == device.address
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(device.name ?? l10n.unnamedPrinter),
                        subtitle: Text(device.address ?? ''),
                        // The saved choice is the whole point of this page, so
                        // it is stated rather than left to a tick a packer has
                        // to interpret.
                        trailing: _selected?.address == device.address
                            ? Chip(
                                label: Text(l10n.inUse),
                                visualDensity: VisualDensity.compact,
                              )
                            : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(l10n.printerLanguage,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.printerLanguageBody,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: RadioGroup<PrinterLanguage>(
                      groupValue: _language,
                      onChanged: _chooseLanguage,
                      child: const Column(children: [
                        _LanguageTile(PrinterLanguage.tspl),
                        _LanguageTile(PrinterLanguage.escPos),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Its own test, separate from the sticker below: this one is
                  // drawn by the printer's own commands, so it answers "does
                  // this machine speak TSPL" even when the sticker does not come
                  // out. Two different questions, two buttons.
                  OutlinedButton.icon(
                    onPressed: _selected == null || _testing
                        ? null
                        : _testLanguage,
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.checkTheLanguage),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed:
                        _selected == null || _testing ? null : _testPrint,
                    icon: _testing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.receipt_long),
                    label: Text(_testing ? l10n.sending : l10n.printATestLabel),
                  ),
                  if (_selected != null)
                    TextButton(
                      onPressed: () async {
                        await widget.printer.forget();
                        if (!mounted) return;
                        setState(() => _selected = null);
                      },
                      child: Text(l10n.forgetThisPrinter),
                    ),
                ],
              ],
            ),
    );
  }
}

/// One row of the language picker.
///
/// A widget rather than two copies inline: the pair must stay identical apart
/// from which language they name, and the titles come from the same place.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile(this.language);

  final PrinterLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLabel = language == PrinterLanguage.tspl;
    return RadioListTile<PrinterLanguage>(
      value: language,
      title: Text(isLabel ? l10n.labelPrinterTspl : l10n.receiptPrinterEscPos),
      subtitle: Text(
          isLabel ? l10n.labelPrinterTsplBody : l10n.receiptPrinterEscPosBody),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
