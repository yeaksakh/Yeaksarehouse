import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/fulfilment_stage.dart';
import '../state/session_controller.dart';
import '../state/stock_controller.dart';
import '../state/tasks_controller.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import '../widgets/order_task_card.dart';
import '../widgets/section_card.dart';
import 'order_detail_screen.dart';

/// The shipments, one tab per status, as the website's /shipments page filters
/// them: Ordered, Packed, Audited.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame: loading notifies listeners, and doing that while
    // this widget is still building is an error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TasksController>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final tasks = context.watch<TasksController>();
    final staff = session.staff;

    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      // The status tabs, then Riders: who has taken what, and where it has got to.
      length: kStaffQueues.length + 1,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orders',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              if (staff != null && staff.warehouseName.isNotEmpty)
                Text(
                  staff.warehouseName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          bottom: TabBar(
            tabs: [
              for (final stage in kStaffQueues)
                _LabelledTab(
                  label: stage.label,
                  count: tasks.queueCount(stage),
                  color: context.appColors.forStage(stage),
                ),
              _LabelledTab(
                label: l10n.ridersTab,
                count: tasks.ridersCount,
                color: context.appColors.pickedUp,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final stage in kStaffQueues) _Queue(stage: stage),
            const _RidersQueue(),
          ],
        ),
      ),
    );
  }
}

/// A tab's name, with its count UNDER it rather than beside it: four tabs fit
/// a phone's width that way, and a long Khmer name is not squeezed by the badge.
class _LabelledTab extends StatelessWidget {
  const _LabelledTab({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          // Kept at its height when the count is 0, so the labels line up.
          SizedBox(height: 18, child: _Badge(count: count, color: color)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Morph(
      child: count == 0
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Container(
              key: ValueKey(count),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(36),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
    );
  }
}

class _Queue extends StatelessWidget {
  const _Queue({required this.stage});

  final FulfilmentStage stage;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksController>();
    final staffId = context.select<SessionController, String?>(
      (session) => session.staff?.id,
    );
    final orders = tasks.queue(stage);

    if (!tasks.hasLoaded(stage) && tasks.error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Both controllers are resolved before the first await: a lookup on the
        // far side of one runs against a context that may already be gone.
        final tasksController = context.read<TasksController>();
        final stockController = context.read<StockController>();
        await tasksController.refreshAll();
        await stockController.load();
      },
      child: orders.isEmpty
          ? ListView(
              // A scrollable is needed for pull-to-refresh to work on an
              // otherwise empty tab.
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: Builder(
                    builder: (context) {
                      // A tab that never loaded is a failure to say out loud,
                      // not an empty queue: "Nothing to pack" would be a lie.
                      final failed = !tasks.hasLoaded(stage);
                      final copy = emptyQueueCopy(stage, AppLocalizations.of(context));
                      return EmptyState(
                        icon: failed ? Icons.cloud_off : copy.icon,
                        title: failed ? 'Could not load shipments' : copy.title,
                        message: failed
                            ? '${tasks.error ?? ''}\nPull down to try again.'
                            : copy.message,
                      );
                    },
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Appear(
                  key: ValueKey(order.id),
                  index: index,
                  child: OrderTaskCard(
                    order: order,
                    staffId: staffId,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: order.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


/// The Riders tab: each shipment a rider has taken, with the rider and their
/// latest step -- accepted, picked up, on the way, delivered (today).
class _RidersQueue extends StatelessWidget {
  const _RidersQueue();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksController>();
    final l10n = AppLocalizations.of(context);
    final orders = tasks.riders;

    if (!tasks.ridersLoaded && tasks.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => context.read<TasksController>().loadRiders(),
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: EmptyState(
                    icon: tasks.ridersLoaded ? Icons.two_wheeler : Icons.cloud_off,
                    title: tasks.ridersLoaded
                        ? l10n.noRidersTitle
                        : 'Could not load shipments',
                    message: tasks.ridersLoaded
                        ? l10n.noRidersBody
                        : '${tasks.error ?? ''}\nPull down to try again.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Appear(
                  key: ValueKey('rider-${order.id}'),
                  index: index,
                  child: _RiderCard(order: order),
                );
              },
            ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  const _RiderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final (label, color, icon) = switch (order.riderStage) {
      'picked_up' => (l10n.riderStagePickedUp, colors.pickedUp, Icons.inventory_2),
      'on_the_way' => (l10n.riderStageOnTheWay, colors.pickedUp, Icons.two_wheeler),
      'delivered' => (l10n.riderStageDelivered, colors.delivered, Icons.check_circle),
      _ => (l10n.riderStageAccepted, colors.checked, Icons.assignment_turned_in),
    };
    return SectionCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.code,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(36),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(label,
                        style: TextStyle(
                            color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(order.customerName,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.two_wheeler, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  [order.riderName, if (order.riderPhone.isNotEmpty) order.riderPhone]
                      .join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (order.riderStageAt != null)
                Text(dateTime(order.riderStageAt!),
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
