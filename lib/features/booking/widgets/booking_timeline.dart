import 'package:flutter/material.dart' as m;

import '../models/schedule_slot_item.dart';
import '../models/slot_status.dart';
import 'available_slot_card.dart';
import 'booked_slot_card.dart';

/// A simple vertical stack of slot cards — one per slot, no hour label column
/// or timeline rail. The slot's time range is shown inside each card.
class BookingTimeline extends m.StatelessWidget {
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
  m.Widget build(m.BuildContext context) {
    return m.ListBody(
      children: <m.Widget>[
        for (int i = 0; i < items.length; i++) ...<m.Widget>[
          _buildCard(context, items[i]),
          if (i < items.length - 1) const m.SizedBox(height: 8),
        ],
      ],
    );
  }

  m.Widget _buildCard(m.BuildContext context, ScheduleSlotItem item) {
    final m.Widget card;
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
    return m.Padding(
      padding: const m.EdgeInsets.symmetric(horizontal: 16),
      child: card,
    );
  }
}
