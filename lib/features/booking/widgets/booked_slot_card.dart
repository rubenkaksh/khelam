import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as m;

import '../models/schedule_slot_item.dart';
import 'slot_time_range.dart';

class BookedSlotCard extends m.StatelessWidget {
  const BookedSlotCard({super.key, required this.item, this.onTap});

  final ScheduleSlotItem item;
  final m.VoidCallback? onTap;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    final String title = item.customerName?.split(' ').first ?? 'N/A';

    return m.Card(
      shape: m.RoundedRectangleBorder(
        borderRadius: m.BorderRadius.circular(12),
        side: m.BorderSide(
          color: colors.outline,
          width: 1,
          strokeAlign: m.BorderSide.strokeAlignInside,
        ),
      ),
      color: colors.secondaryContainer,
      child: m.InkWell(
        onTap: onTap,
        borderRadius: m.BorderRadius.circular(12),
        child: m.Padding(
          padding: const m.EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: m.Row(
            children: <m.Widget>[
              m.Text(
                slotTimeRange(item.slot),
                style: m.Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              m.Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <m.Widget>[
                  m.Text(
                    'Booked',
                    style: m.Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: m.FontWeight.w400,
                      color: colors.primary,
                    ),
                  ),
                  const m.SizedBox(height: 4),
                  m.Text(
                    'by $title',
                    style: m.Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: m.FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
