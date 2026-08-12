import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/schedule_slot_item.dart';
import '../models/slot_status.dart';
import 'available_slot_card.dart';
import 'booked_slot_card.dart';

/// A simple vertical stack of slot cards — one per slot, no hour label column
/// or timeline rail. The slot's time range is shown inside each card.
class BookingTimeline extends StatelessWidget {
  const BookingTimeline({
    super.key,
    required this.items,
    this.onBookedSlotTap,
    this.onAvailableSlotTap,
  });

  final List<ScheduleSlotItem> items;
  final void Function(ScheduleSlotItem)? onBookedSlotTap;
  final void Function(ScheduleSlotItem)? onAvailableSlotTap;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          _buildCard(context, items[i]),
          if (i < items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context, ScheduleSlotItem item) {
    final Widget card;
    // Booked is decided by slot status so API data (no booking object on
    // list slots) renders booked slots correctly; booking presence is kept
    // as a fallback for mocks/legacy data.
    final bool isBooked =
        item.booking != null || item.slot.status == SlotStatus.booked;
    if (isBooked) {
      final void Function(ScheduleSlotItem)? onTap = onBookedSlotTap;
      card = BookedSlotCard(
        item: item,
        onTap: onTap == null ? null : () => onTap(item),
      );
    } else {
      final void Function(ScheduleSlotItem)? onTap = onAvailableSlotTap;
      card = AvailableSlotCard(
        slot: item.slot,
        onTap: onTap == null ? null : () => onTap(item),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: card,
    );
  }
}

/// Skeleton placeholder for the timeline while slots load. Mirrors the
/// [BookingTimeline] card layout (horizontal 16 padding, 8px gaps) so the
/// swap to real data doesn't jump; the placeholder texts are never painted —
/// [Skeletonizer] turns them into bones.
class BookingTimelineSkeleton extends StatelessWidget {
  const BookingTimelineSkeleton({super.key, this.cardCount = 4});

  /// Number of placeholder cards to render.
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < cardCount; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: 8),
              const _SkeletonSlotCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonSlotCard extends StatelessWidget {
  const _SkeletonSlotCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: <Widget>[
            Text(
              '10:00 AM',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            Text('Book Now', style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
