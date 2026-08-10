import 'package:flutter/material.dart';

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
