import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/hrm.dart';
import '../state/hrm_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/motion.dart';
import 'leave_screen.dart';

/// A manager's view: every request, pending first, each one tappable to
/// approve or reject.
class LeaveApprovalsScreen extends StatefulWidget {
  const LeaveApprovalsScreen({super.key});

  @override
  State<LeaveApprovalsScreen> createState() => _LeaveApprovalsScreenState();
}

class _LeaveApprovalsScreenState extends State<LeaveApprovalsScreen> {
  LeaveStatus? _filter = LeaveStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HrmController>().loadLeaves();
    });
  }

  Future<void> _decide(LeaveRequest leave) async {
    final l10n = AppLocalizations.of(context);
    final status = await showModalBottomSheet<LeaveStatus>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                '${leave.userName.isEmpty ? l10n.request : leave.userName} · '
                '${leave.typeLabel}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle:
                  Text(leave.reason.isEmpty ? leave.daysLabel : leave.reason),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF1B7F4C)),
              title: Text(l10n.approve),
              onTap: () => Navigator.of(sheet).pop(LeaveStatus.approved),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Color(0xFFB3261E)),
              title: Text(l10n.reject),
              onTap: () => Navigator.of(sheet).pop(LeaveStatus.rejected),
            ),
            if (leave.status != LeaveStatus.pending)
              ListTile(
                leading: const Icon(Icons.undo),
                title: Text(l10n.backToPending),
                onTap: () => Navigator.of(sheet).pop(LeaveStatus.pending),
              ),
          ],
        ),
      ),
    );
    if (status == null || !mounted) return;
    final hrm = context.read<HrmController>();
    final messenger = ScaffoldMessenger.of(context);
    final done = await hrm.setLeaveStatus(leave.id, status);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(done
            ? '${leave.userName.isEmpty ? l10n.request : leave.userName}: ${status.label}.'
            : (hrm.error ?? l10n.couldNotBeChanged)),
      ));
    if (!done) hrm.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hrm = context.watch<HrmController>();
    final scheme = Theme.of(context).colorScheme;
    final leaves = hrm.leaves
        .where((leave) => _filter == null || leave.status == _filter)
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaveApprovals)),
      body: RefreshIndicator(
        onRefresh: () => context.read<HrmController>().loadLeaves(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final status in LeaveStatus.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: _filter == status,
                    onSelected: (_) => setState(() => _filter = status),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (hrm.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(hrm.error!, style: TextStyle(color: scheme.error)),
              ),
            if (leaves.isEmpty)
              SizedBox(
                height: 280,
                child: EmptyState(
                  icon: Icons.inbox_outlined,
                  title: l10n.nothingHereTitle,
                  message: l10n.noRequestsMatch,
                ),
              ),
            for (final leave in leaves) ...[
              Appear(
                key: ValueKey(leave.id),
                index: leaves.indexOf(leave),
                child: LeaveCard(
                  leave: leave,
                  showName: true,
                  onTap: hrm.busy ? null : () => _decide(leave),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
