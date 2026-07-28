import 'package:flutter/material.dart' as m;

import '../../../common/section_header.dart';
import '../../../common/stat_card.dart';

class DayStats {
  const DayStats({
    this.bookingCount = 0,
    this.revenue = 0.0,
  });

  final int bookingCount;
  final double revenue;
}

class DayStatsSection extends m.StatelessWidget {
  const DayStatsSection({super.key, required this.stats});

  final DayStats stats;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.Padding(
      padding: const m.EdgeInsets.all(16),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.start,
        children: <m.Widget>[
          const SectionHeader(title: "Today's Stats"),
          const m.SizedBox(height: 12),
          m.Row(
            children: <m.Widget>[
              m.Expanded(
                child: StatCard(
                  icon: m.Icon(m.Icons.calendar_today, size: 20),
                  label: 'Bookings',
                  value: '${stats.bookingCount}',
                  valueColor: colors.primary,
                ),
              ),
              const m.SizedBox(width: 12),
              m.Expanded(
                child: StatCard(
                  icon: m.Icon(m.Icons.currency_rupee, size: 20),
                  label: 'Revenue',
                  value: '₹${stats.revenue.toStringAsFixed(0)}',
                  valueColor: colors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
