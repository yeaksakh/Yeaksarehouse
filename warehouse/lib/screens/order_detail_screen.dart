import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'printer_settings_screen.dart';
import '../widgets/box_label_sticker.dart';
import '../services/label_printer.dart';

import '../models/fulfilment_stage.dart';
import '../models/order.dart';
import '../models/staff.dart';
import '../state/session_controller.dart';
import '../state/tasks_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/pick_line_tile.dart';
import '../widgets/scan_field.dart';
import '../widgets/section_card.dart';
import '../widgets/stage_chip.dart';
import '../widgets/stage_timeline.dart';

/// One shipment, and the work of moving it on -- the website's shipment pop-up.
///
/// While it is `ordered` the flow is the website's: someone accepts it, that
/// person ticks every item into the box, then marks it packed. A supervisor then
/// marks it audited, and the rider app takes it from there.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  /// True while the label PDF is being fetched and the print sheet opened.
  bool _printing = false;


  /// The item a scan last landed on, so it can be flashed.
  String? _flashedLineId;

  @override
  void initState() {
    super.initState();
    // A list row carries no items: fetch them, and anything that changed since.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TasksController>().openDetail(widget.orderId);
    });
  }

  Future<void> _handleScan(String code) async {
    final tasks = context.read<TasksController>();
    final order = tasks.orderById(widget.orderId);
    if (order == null) return;

    final target = order.lineForCode(code);
    if (target == null) {
      HapticFeedback.heavyImpact();
      showScanResult(
        context,
        outcome: ScanOutcome.unknown,
        message: '$code is not on this shipment.',
      );
      return;
    }
    if (target.packed) {
      HapticFeedback.mediumImpact();
      setState(() => _flashedLineId = target.id);
      showScanResult(
        context,
        outcome: ScanOutcome.alreadyComplete,
        message: '${target.name} is already ticked.',
      );
      return;
    }

    final ticked =
        await tasks.setLinePacked(widget.orderId, target.id, packed: true);
    if (!mounted) return;
    if (!ticked) {
      _showError(tasks);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _flashedLineId = target.id);
    showScanResult(
      context,
      outcome: ScanOutcome.accepted,
      message: '${target.name} ticked',
    );
  }

  void _showError(TasksController tasks) {
    final message = tasks.error;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    tasks.clearError();
  }

  /// Runs one move, then says what happened -- the server's own words when it
  /// refused, so "Already accepted by Sok Dara." reaches the person as written.
  Future<void> _run(
    Future<bool> Function(TasksController tasks) move, {
    String? done,
    bool close = false,
  }) async {
    final tasks = context.read<TasksController>();
    // Resolved before the await: after it this context may be gone.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final moved = await move(tasks);
    if (!mounted) return;
    if (!moved) {
      _showError(tasks);
      return;
    }
    HapticFeedback.mediumImpact();
    if (close) navigator.pop();
    if (done != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(done)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasks = context.watch<TasksController>();
    final staff = context.watch<SessionController>().staff;
    final order = tasks.orderById(widget.orderId);
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.shipmentNoLongerHere)),
      );
    }

    final stage = order.stage;
    final mine = order.isAcceptedBy(staff?.id);
    final packing = stage == FulfilmentStage.ordered && mine;
    final waiting = tasks.busy;

    return Scaffold(
      appBar: AppBar(
        title: Text(order.code),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StageChip(stage: stage)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StageTimeline(stage: stage),
                const Divider(height: 28),
                _Row(icon: Icons.person_outline, label: order.customerName),
                if (order.customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.phone_outlined, label: order.customerPhone),
                ],
                if (order.shippingAddress.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(
                    icon: Icons.location_on_outlined,
                    label: order.shippingAddress,
                  ),
                ],
                if (order.locationName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.store_outlined, label: order.locationName),
                ],
                if (order.isAccepted) ...[
                  const SizedBox(height: 8),
                  _Row(
                    icon: Icons.assignment_ind,
                    label: 'Accepted by ${order.preparedBy!.name}'
                        '${mine ? ' (you)' : ''}'
                        '${order.acceptedAt == null ? '' : ' · ${dateTime(order.acceptedAt!)}'}',
                    tone: mine ? colors.checked : null,
                  ),
                ],
                if (order.packedAt != null) ...[
                  const SizedBox(height: 8),
                  _Row(
                    icon: Icons.inventory_2_outlined,
                    label: '${order.packedByName.isEmpty ? l10n.stagePacked : l10n.packedByName(order.packedByName)}'
                        ' · ${dateTime(order.packedAt!)}',
                  ),
                ],
                if (order.auditedAt != null) ...[
                  const SizedBox(height: 8),
                  _Row(
                    icon: Icons.fact_check_outlined,
                    label: '${order.auditedByName.isEmpty ? l10n.stageAudited : l10n.auditedByName(order.auditedByName)}'
                        ' · ${dateTime(order.auditedAt!)}',
                  ),
                ],
                const SizedBox(height: 8),
                _Row(
                  icon: order.isCashOnDelivery
                      ? Icons.payments_outlined
                      : Icons.credit_score,
                  label: order.paymentStatus.label,
                  tone: order.isCashOnDelivery ? colors.prepared : null,
                ),
                const SizedBox(height: 8),
                _Row(
                  icon: Icons.schedule,
                  label: 'Ordered ${relativeTime(order.placedAt)}'
                      ' · ${clockTime(order.placedAt)}',
                ),
                if (order.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.sticky_note_2_outlined, label: order.note),
                ],
              ],
            ),
          ),
          if (stage == FulfilmentStage.ordered && !order.isAccepted) ...[
            const SizedBox(height: 12),
            _Banner(
              icon: Icons.assignment_ind_outlined,
              color: colors.ordered,
              title: l10n.notAcceptedYet,
              message: 'Accept it to start packing. The website shows you as '
                  'the one preparing it.',
            ),
          ],
          if (stage == FulfilmentStage.ordered &&
              order.isAccepted &&
              !mine) ...[
            const SizedBox(height: 12),
            _Banner(
              icon: Icons.person_pin_outlined,
              color: scheme.onSurfaceVariant,
              title: 'Being packed by ${order.preparedBy!.name}',
              message:
                  l10n.onlyAccepterTicks,
            ),
          ],
          if (order.isCashOnDelivery) ...[
            const SizedBox(height: 12),
            _Banner(
              icon: Icons.payments,
              color: colors.prepared,
              title: l10n.collectOnDelivery,
              message:
                  l10n.collectOnDeliveryBody,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.items,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${order.packedCount} / ${order.lineCount} packed',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: order.isFullyPacked ? colors.inStock : colors.lowStock,
                ),
              ),
            ],
          ),
          if (packing) ...[
            const SizedBox(height: 12),
            // Not focused on arrival: on a phone that raises the keyboard,
            // which covered the very items the packer came to tick. A wedge
            // scanner needs the box tapped once; it keeps focus after each scan.
            ScanField(
              onScan: _handleScan,
              hintText: l10n.scanOrTypeSku,
              autofocus: false,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tapAnItemToTick,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          if (!order.hasDetail)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          for (final line in order.lines) ...[
            PickLineTile(
              line: line,
              highlighted: _flashedLineId == line.id,
              onPackedChanged: packing && !waiting
                  ? (value) => _run((tasks) =>
                      tasks.setLinePacked(order.id, line.id, packed: value))
                  : null,
            ),
            const SizedBox(height: 10),
          ],
          if (order.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.photos,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final photo in order.photos)
                  SizedBox(
                    width: 104,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            photo.url,
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 104,
                              height: 104,
                              color: scheme.surfaceContainerHighest,
                              child: Icon(Icons.broken_image,
                                  color: scheme.outline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Which step it is evidence for, and when it went up.
                        Text(
                          photo.stage?.label ?? l10n.photo,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: photo.stage == null
                                ? scheme.onSurfaceVariant
                                : colors.forStage(photo.stage!),
                          ),
                        ),
                        if (photo.takenAt != null)
                          Text(
                            dateTime(photo.takenAt!),
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _printing ? null : () => _printLabels(order),
            icon: _printing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print_outlined),
            label: Text(_printing ? l10n.preparingLabels : l10n.printBoxLabels),
          ),
          const SizedBox(height: 10),
          ..._actions(order,
              l10n: l10n, staff: staff, mine: mine, waiting: waiting),
        ],
      ),
    );
  }

  /// Ask where the stickers should go, then send them.
  ///
  /// Two routes, because warehouses have both kinds of machine. The Bluetooth
  /// one draws each sticker on the phone and sends raster rows, which is all a
  /// thermal label printer understands. The system dialog takes the server's
  /// PDF and reaches Wi-Fi and USB printers, and offers "Save as PDF" for a
  /// packer with no printer at hand.
  Future<void> _printLabels(Order order) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<_PrintRoute>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: Text(l10n.bluetoothLabelPrinter),
              subtitle: Text(l10n.theWarehouseStickerPrinter),
              onTap: () => Navigator.of(sheet).pop(_PrintRoute.bluetooth),
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: Text(l10n.otherPrinterOrPdf),
              subtitle: Text(l10n.wifiUsbOrKeepCopy),
              onTap: () => Navigator.of(sheet).pop(_PrintRoute.system),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.chooseTheLabelPrinter),
              onTap: () => Navigator.of(sheet).pop(_PrintRoute.settings),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case _PrintRoute.settings:
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => PrinterSettingsScreen(printer: context.read<LabelPrinter>()),
        ));
      case _PrintRoute.system:
        await _printViaSystem(order);
      case _PrintRoute.bluetooth:
        await _printViaBluetooth(order);
    }
  }

  Future<void> _printViaSystem(Order order) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _printing = true);
    try {
      final pdf = await context.read<TasksController>().labels(order.id);
      await Printing.layoutPdf(
          onLayout: (_) async => pdf, name: 'labels-${order.code}');
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  /// One sticker at a time, in order, stopping at the first refusal.
  ///
  /// Stopping matters: if the printer runs out of labels on sticker three of
  /// six, carrying on sends three more into a machine that cannot print them
  /// and the packer has no idea which ones are missing.
  Future<void> _printViaBluetooth(Order order) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Resolved before the first await: the loop below crosses several, and
    // reading the context after one is how a disposed screen ends up handing
    // back a printer from a page that no longer exists.
    final printer = context.read<LabelPrinter>();
    setState(() => _printing = true);
    try {
      final sheet = await context.read<TasksController>().labelData(order.id);
      if (sheet.isEmpty) {
        messenger.showSnackBar(
            SnackBar(content: Text(l10n.nothingToLabel)));
        return;
      }
      var sent = 0;
      for (final label in sheet.labels) {
        final png = await renderSticker(BoxLabelSticker(
          label: label,
          invoiceNo: sheet.invoiceNo,
          customer: sheet.customer,
        ));
        final result = await printer.printImage(png);
        if (!result.succeeded) {
          messenger.showSnackBar(SnackBar(
              content: Text('${result.message} '
                  '($sent of ${sheet.labels.length} printed)')));
          return;
        }
        sent++;
      }
      messenger.showSnackBar(SnackBar(
          content: Text('$sent label${sent == 1 ? '' : 's'} sent.')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  List<Widget> _actions(
    Order order, {
    required AppLocalizations l10n,
    required Staff? staff,
    required bool mine,
    required bool waiting,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final stage = order.stage;

    // Printing is useful at every stage -- while packing, and again if a
    // sticker is torn off in the van -- so it is not tied to one of the
    // branches below. Added by the caller, not here, for that reason.

    if (stage == FulfilmentStage.ordered && !order.isAccepted) {
      return [
        ElevatedButton.icon(
          onPressed: waiting
              ? null
              : () => _run(
                    (tasks) => tasks.accept(order.id),
                    done: 'You are packing ${order.code}.',
                  ),
          icon: const Icon(Icons.assignment_ind),
          label: Text(l10n.acceptToPack),
        ),
      ];
    }

    if (stage == FulfilmentStage.ordered && mine) {
      return [
        ElevatedButton.icon(
          onPressed: waiting || !order.isFullyPacked
              ? null
              : () => _run(
                    (tasks) => tasks.markPacked(order.id),
                    done: '${order.code} packed — waiting for audit.',
                    close: true,
                  ),
          icon: const Icon(Icons.inventory_2),
          label: Text(l10n.markPacked),
        ),
        if (!order.isFullyPacked && order.hasDetail) ...[
          const SizedBox(height: 8),
          Text(
            'Tick every item first (${order.unpackedCount} left).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
        // The server refuses to hand back a shipment once an item is ticked,
        // so the button only exists while it would work.
        if (order.packedCount == 0) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: waiting
                ? null
                : () => _run(
                      (tasks) => tasks.release(order.id),
                      done: '${order.code} handed back.',
                      close: true,
                    ),
            icon: const Icon(Icons.undo),
            label: Text(l10n.handBack),
          ),
        ],
      ];
    }

    if (stage == FulfilmentStage.ordered) return const [];

    if (stage == FulfilmentStage.packed) {
      if (staff != null && staff.role.canCheck) {
        return [
          ElevatedButton.icon(
            onPressed: waiting
                ? null
                : () => _run(
                      (tasks) => tasks.markAudited(order.id, staff: staff),
                      done: '${order.code} audited — waiting for the rider.',
                      close: true,
                    ),
            icon: const Icon(Icons.fact_check),
            label: Text(l10n.markAudited),
          ),
        ];
      }
      return [
        _Banner(
          icon: Icons.lock_outline,
          color: scheme.onSurfaceVariant,
          title: l10n.waitingForAudit,
          message: 'A supervisor checks the packed shipment before the rider '
              'takes it.',
        ),
      ];
    }

    if (stage == FulfilmentStage.audited) {
      return [
        _Banner(
          icon: Icons.local_shipping,
          color: colors.checked,
          title: l10n.waitingForRider,
          message: l10n.waitingForRiderBody,
        ),
      ];
    }

    return [
      _Banner(
        icon: Icons.done_all,
        color: colors.forStage(stage),
        title: stage.label,
        message: l10n.shipmentHasLeft,
      ),
    ];
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, this.tone});

  final IconData icon;
  final String label;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: tone ?? scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: tone,
              fontWeight: tone == null ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Where a packer wants this parcel's stickers to go.
enum _PrintRoute { bluetooth, system, settings }
