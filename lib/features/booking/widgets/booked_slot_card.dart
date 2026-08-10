import 'package:flutter/material.dart' as m;

import 'package:commons/commons.dart';
import '../models/schedule_slot_item.dart';
import 'slot_time_range.dart';

class BookedSlotCard extends m.StatelessWidget {
  const BookedSlotCard({super.key, required this.item, this.onTap});

  final ScheduleSlotItem item;
  final m.VoidCallback? onTap;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    final String title =
        item.customerName ?? item.booking?.bookingCode ?? 'Booked';

    return m.Card(
      child: m.InkWell(
        onTap: onTap,
        borderRadius: m.BorderRadius.circular(12),
        child: m.Padding(
          padding: const m.EdgeInsets.all(12),
          child: m.Row(
            children: <m.Widget>[
              m.Container(
                width: 4,
                height: 48,
                decoration: m.BoxDecoration(
                  color: colors.secondary,
                  borderRadius: m.BorderRadius.circular(2),
                ),
              ),
              const m.SizedBox(width: 12),
              m.Expanded(
                child: m.Column(
                  crossAxisAlignment: m.CrossAxisAlignment.start,
                  children: <m.Widget>[
                    m.Text(
                      title,
                      style: m.Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: m.FontWeight.w600,
                      ),
                    ),
                    const m.SizedBox(height: 4),
                    m.Row(
                      children: <m.Widget>[
                        m.Text(
                          slotTimeRange(item.slot),
                          style: m.Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const m.SizedBox(width: 8),
                        StatusBadge(
                          label: 'Confirmed',
                          icon: const m.Icon(m.Icons.check_circle, size: 14),
                          tone: BadgeTone.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              m.Icon(m.Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
