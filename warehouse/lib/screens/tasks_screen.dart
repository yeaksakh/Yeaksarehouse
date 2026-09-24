import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/fulfilment_stage.dart';
import '../state/session_controller.dart';
import '../state/stock_controller.dart';
import '../state/tasks_controller.dart';
import '../models/order.dart';
import '../models/staff.dart';
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
  final _searchText = TextEditingController();
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchText.dispose();
    super.dispose();
  }

  /// Asks the server once typing pauses, not on every letter.
  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<TasksController>().search(text);
    });
  }

  void _toggleSearch() {
    _debounce?.cancel();
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchText.clear();
      context.read<TasksController>().search('');
    }
  }

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
    final workCount =
        kStaffQueues.fold<int>(0, (n, s) => n + tasks.queueCount(s));
    return DefaultTabController(
      // Laid out like YeaksaBoy: one Work board with every stage stacked in its
      // own colour, and History for what riders have taken.
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: _searching
              ? TextField(
                  key: const ValueKey('order-search'),
                  controller: _searchText,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                  onSubmitted: (text) {
                    _debounce?.cancel();
                    context.read<TasksController>().search(text);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchOrdersHint,
                    border: InputBorder.none,
                    filled: false,
                  ),
                )
              : Column(
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
          actions: [
            IconButton(
              tooltip: _searching ? l10n.closeSearch : l10n.searchOrders,
              icon: Icon(_searching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            tabs: [
              _LabelledTab(
                label: l10n.workTab,
                count: workCount,
                color: context.appColors.ordered,
              ),
              _LabelledTab(
                label: l10n.historyTab,
                count: tasks.ridersCount,
                color: context.appColors.pickedUp,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WorkBoard(),
            _RidersQueue(),
          ],
        ),
      ),
    );
  }
}

/// The Work tab: every stage the warehouse still acts on, top to bottom in the
/// order a shipment moves -- Ordered, Packed, Audited -- each in its own colour,
/// each card with its next step. The newest few of each stage; "See all" opens
/// the stage's full list (Ordered can hold thousands of old sales).
class _WorkBoard extends StatelessWidget {
  const _WorkBoard();

  static const _perStage = 10;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksController>();
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final staff = context.select<SessionController, Staff?>((s) => s.staff);

    final loading =
        kStaffQueues.any((s) => !tasks.hasLoaded(s)) && tasks.error == null;
    if (loading && kStaffQueues.every((s) => tasks.queue(s).isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    String title(FulfilmentStage stage) => switch (stage) {
          FulfilmentStage.ordered => l10n.stageOrdered,
          FulfilmentStage.packed => l10n.stagePacked,
          _ => l10n.stageAudited,
        };

    void open(Order order) => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id)),
        );

    Future<void> accept(Order order) async {
      final messenger = ScaffoldMessenger.of(context);
      final controller = context.read<TasksController>();
      final ok = await controller.accept(order.id);
      if (!ok) {
        messenger.showSnackBar(
            SnackBar(content: Text(controller.error ?? 'Could not accept.')));
      }
    }

    Widget? nextStep(Order order) {
      final color = colors.forOrder(order);
      ButtonStyle style() => ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white);
      switch (order.stage) {
        case FulfilmentStage.ordered:
          if (!order.isAccepted) {
            return ElevatedButton.icon(
              style: style(),
              onPressed: tasks.busy ? null : () => accept(order),
              icon: const Icon(Icons.assignment_ind, size: 18),
              label: Text(l10n.nextAccept),
            );
          }
          if (order.isAcceptedBy(staff?.id)) {
            return ElevatedButton.icon(
              style: style(),
              onPressed: () => open(order),
              icon: const Icon(Icons.inventory_2, size: 18),
              label: Text(l10n.nextPack),
            );
          }
          return null;
        case FulfilmentStage.packed:
          if (staff != null && staff.canAudit) {
            return ElevatedButton.icon(
              style: style(),
              onPressed: () => open(order),
              icon: const Icon(Icons.fact_check, size: 18),
              label: Text(l10n.nextAudit),
            );
          }
          return null;
        default:
          return Row(
            children: [
              Icon(order.hasRider ? Icons.two_wheeler : Icons.hourglass_top,
                  size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.hasRider
                      ? l10n.riderName(order.riderName)
                      : l10n.waitingForRider,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
      }
    }

    // An order leaves its stage's section once somebody has it in hand: an
    // Ordered one with a packer moves to Packing, an Audited one a rider has
    // taken leaves the board for History. Counts are the server's, less the
    // ones moved out of that section.
    final ordered = tasks.queue(FulfilmentStage.ordered);
    final packing = ordered.where((o) => o.isAccepted).toList();
    final audited = tasks.queue(FulfilmentStage.audited);
    final taken = audited.where((o) => o.hasRider).length;
    final groups = [
      (
        stage: FulfilmentStage.ordered,
        title: l10n.stageOrdered,
        orders: ordered.where((o) => !o.isAccepted).toList(),
        count: tasks.queueCount(FulfilmentStage.ordered) - packing.length,
        color: colors.forStage(FulfilmentStage.ordered),
        key: 'ordered',
      ),
      (
        stage: FulfilmentStage.ordered,
        title: l10n.stagePacking,
        orders: packing,
        count: packing.length,
        color: colors.packing,
        key: 'packing',
      ),
      (
        stage: FulfilmentStage.packed,
        title: l10n.stagePacked,
        orders: tasks.queue(FulfilmentStage.packed),
        count: tasks.queueCount(FulfilmentStage.packed),
        color: colors.forStage(FulfilmentStage.packed),
        key: 'packed',
      ),
      (
        stage: FulfilmentStage.audited,
        title: l10n.stageAudited,
        orders: audited.where((o) => !o.hasRider).toList(),
        count: tasks.queueCount(FulfilmentStage.audited) - taken,
        color: colors.forStage(FulfilmentStage.audited),
        key: 'audited',
      ),
    ];

    final sections = <Widget>[];
    for (final group in groups) {
      final orders = group.orders;
      final count = group.count < orders.length ? orders.length : group.count;
      if (orders.isEmpty) continue;
      final color = group.color;
      final stage = group.stage;
      sections.add(_StageHeader(group.title, count, color));
      sections.add(const SizedBox(height: 10));
      for (final (i, order) in orders.take(_perStage).indexed) {
        sections.add(Appear(
          key: ValueKey('work-${group.key}-${order.id}'),
          index: i,
          child: OrderTaskCard(
            order: order,
            staffId: staff?.id,
            onTap: () => open(order),
            action: nextStep(order),
          ),
        ));
        sections.add(const SizedBox(height: 12));
      }
      if (count > _perStage) {
        sections.add(Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(title(stage))),
                body: _Queue(stage: stage),
              ),
            )),
            icon: Icon(Icons.chevron_right, color: color),
            label:
                Text(l10n.seeAllCount(count), style: TextStyle(color: color)),
          ),
        ));
      }
      sections.add(const SizedBox(height: 12));
    }

    return RefreshIndicator(
      onRefresh: () async {
        final tasksController = context.read<TasksController>();
        final stockController = context.read<StockController>();
        await tasksController.refreshAll();
        await stockController.load();
      },
      child: sections.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: EmptyState(
                    icon: tasks.error != null
                        ? Icons.cloud_off
                        : tasks.query.isNotEmpty
                            ? Icons.search_off
                            : Icons.task_alt,
                    title: tasks.error != null
                        ? 'Could not load shipments'
                        : tasks.query.isNotEmpty
                            ? l10n.noMatchTitle
                            : l10n.nothingToDoTitle,
                    message: tasks.error != null
                        ? '${tasks.error}\nPull down to try again.'
                        : tasks.query.isNotEmpty
                            ? l10n.noMatchBody(tasks.query)
                            : l10n.nothingToDoBody,
                  ),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: sections,
            ),
    );
  }
}

/// A stage heading: a dot and the name in the stage's colour, and the count.
class _StageHeader extends StatelessWidget {
  const _StageHeader(this.title, this.count, this.color);

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      );
}

class _LabelledTab extends StatelessWidget {
  const _LabelledTab(
      {required this.label, required this.count, required this.color});

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
                      final copy =
                          emptyQueueCopy(stage, AppLocalizations.of(context));
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
                    icon: tasks.ridersLoaded
                        ? Icons.two_wheeler
                        : Icons.cloud_off,
                    title: !tasks.ridersLoaded
                        ? 'Could not load shipments'
                        : tasks.query.isNotEmpty
                            ? l10n.noMatchTitle
                            : l10n.noRidersTitle,
                    message: tasks.ridersLoaded
                        ? (tasks.query.isNotEmpty
                            ? l10n.noMatchBody(tasks.query)
                            : l10n.noRidersBody)
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
      'picked_up' => (
          l10n.riderStagePickedUp,
          colors.pickedUp,
          Icons.inventory_2
        ),
      'on_the_way' => (
          l10n.riderStageOnTheWay,
          colors.pickedUp,
          Icons.two_wheeler
        ),
      'delivered' => (
          l10n.riderStageDelivered,
          colors.delivered,
          Icons.check_circle
        ),
      _ => (
          l10n.riderStageAccepted,
          colors.checked,
          Icons.assignment_turned_in
        ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
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
                  [
                    order.riderName,
                    if (order.riderPhone.isNotEmpty) order.riderPhone
                  ].join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (order.riderStageAt != null)
                Text(dateTime(order.riderStageAt!),
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
