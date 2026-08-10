import 'package:flutter/material.dart';

import 'package:commons/commons.dart';
import '../bloc/schedule_cubit.dart';

class DayStatsSection extends StatelessWidget {
  const DayStatsSection({super.key, required this.stats});

  final DayStats stats;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(title: "Today's Stats"),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: StatCard(
                  icon: Icon(Icons.calendar_today, size: 20),
                  label: 'Bookings',
                  value: '${stats.bookingCount}',
                  valueColor: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icon(Icons.currency_rupee, size: 20),
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
