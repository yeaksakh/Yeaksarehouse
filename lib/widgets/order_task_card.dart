import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import '../models/fulfilment_stage.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'section_card.dart';
import 'stage_chip.dart';

/// One shipment in a tab.
///
/// Leads with the invoice number and how long it has been waiting, because in a
/// queue worked front to back those decide what a person picks up next -- and,
/// while it is `ordered`, whether anyone has taken it yet.
class OrderTaskCard extends StatelessWidget {
  const OrderTaskCard({
    super.key,
    required this.order,
    this.staffId,
    this.onTap,
    this.action,
  });

  final Order order;

  /// The next step as a button under the card (Accept, Pack, Audit) -- the Work
  /// board passes one; the full per-stage lists do not.
  final Widget? action;

  /// Who is signed in, so the card can say "Yours" rather than their own name.
  final String? staffId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final ordered = order.stage == FulfilmentStage.ordered;
    final partlyPacked =
        ordered && order.packedCount > 0 && !order.isFullyPacked;

    return SectionCard(
      onTap: onTap,
      accent: colors.forOrder(order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StageChip(stage: order.stage),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            order.customerName,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Wrap, not Row: three facts and their spacers overflow a 360px
          // phone, and a fact clipped off the edge is worse than one that moved
          // to a second line.
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _Fact(
                icon: Icons.inventory_2_outlined,
                text: plural(order.lineCount, 'item'),
              ),
              _Fact(
                icon: Icons.numbers,
                text: plural(order.totalQuantity.round(), 'unit'),
              ),
              _Fact(
                icon: Icons.schedule,
                text: waitingFor(order.placedAt),
              ),
              if (ordered && order.acceptedAt != null)
                _Fact(
                  icon: Icons.assignment_ind_outlined,
                  text: 'Accepted ${relativeTime(order.acceptedAt!)}',
                ),
            ],
          ),
          if (partlyPacked) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: order.packProgress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation(colors.forOrder(order)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${order.packedCount} of ${order.lineCount} packed',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ordered && !order.isAccepted)
                _Tag(
                  icon: Icons.assignment_ind_outlined,
                  label: l10n.notAccepted,
                  color: colors.ordered,
                )
              else if (ordered && order.isAcceptedBy(staffId))
                _Tag(
                  icon: Icons.person,
                  label: l10n.yours,
                  color: colors.checked,
                )
              else if (order.isAccepted)
                _Tag(
                  icon: Icons.person_outline,
                  label: l10n.withStaff(order.preparedBy!.name),
                  color: scheme.onSurfaceVariant,
                ),
              if (order.isCashOnDelivery)
                _Tag(
                  icon: Icons.payments_outlined,
                  label: l10n.collectCash,
                  color: colors.prepared,
                ),
              if (order.note.isNotEmpty)
                _Tag(
                  icon: Icons.sticky_note_2_outlined,
                  label: l10n.hasANote,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: action!),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty-tab copy, phrased per status. A blank Ordered tab means the floor is
/// caught up, which is worth saying rather than showing a generic shrug.
({IconData icon, String title, String message}) emptyQueueCopy(
  FulfilmentStage stage,
  AppLocalizations l10n,
) =>
    switch (stage) {
      FulfilmentStage.ordered => (
          icon: Icons.check_circle_outline,
          title: l10n.nothingToPack,
          message: l10n.newOrdersLandHere,
        ),
      FulfilmentStage.packed => (
          icon: Icons.fact_check_outlined,
          title: l10n.nothingWaitingForAudit,
          message: l10n.packedWaitForSupervisor,
        ),
      FulfilmentStage.audited => (
          icon: Icons.local_shipping_outlined,
          title: l10n.nothingWaitingForRider,
          message: l10n.auditedWaitForRider,
        ),
      _ => (
          icon: Icons.inbox_outlined,
          title: l10n.nothingHereTitle,
          message: l10n.noShipmentsAtStatus,
        ),
    };
