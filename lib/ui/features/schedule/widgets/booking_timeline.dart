import 'package:flutter/material.dart' as m;

import '../../../../domain/models/schedule_slot_item.dart';
import '../../../../domain/models/slot_status.dart';
import 'available_slot_card.dart';
import 'booked_slot_card.dart';
import 'timeline_hour_label.dart';
import 'timeline_rail.dart';

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
      children: _buildRows(context),
    );
  }

  List<m.Widget> _buildRows(m.BuildContext context) {
    final List<m.Widget> rows = <m.Widget>[];
    for (int i = 0; i < items.length; i++) {
      final ScheduleSlotItem item = items[i];
      rows.add(
        m.Padding(
          padding: const m.EdgeInsets.symmetric(horizontal: 16),
          child: m.Row(
            crossAxisAlignment: m.CrossAxisAlignment.start,
            children: <m.Widget>[
              m.SizedBox(
                width: 64,
                child: m.Padding(
                  padding: const m.EdgeInsets.only(top: 14),
                  child: TimelineHourLabel(time: item.slot.startTime),
                ),
              ),
              const TimelineRail(),
              const m.SizedBox(width: 8),
              m.Expanded(
                child: _buildCard(item),
              ),
            ],
          ),
        ),
      );
      if (i < items.length - 1) {
        rows.add(const m.SizedBox(height: 4));
      }
    }
    return rows;
  }

  m.Widget _buildCard(ScheduleSlotItem item) {
    // Booked is decided by slot status so API data (no booking object on
    // list slots) renders booked slots correctly; booking presence is kept
    // as a fallback for mocks/legacy data.
    final bool isBooked =
        item.booking != null || item.slot.status == SlotStatus.booked;
    if (isBooked) {
      return BookedSlotCard(
        item: item,
        onTap: onBookedSlotTap != null
            ? () => onBookedSlotTap!(item)
            : null,
      );
    }
    return AvailableSlotCard(
      onTap: onAvailableSlotTap != null
          ? () => onAvailableSlotTap!(item)
          : null,
    );
  }
}
