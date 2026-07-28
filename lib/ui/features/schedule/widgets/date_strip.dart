import 'package:flutter/material.dart' as m;

import 'date_chip.dart';

class DateStrip extends m.StatelessWidget {
  const DateStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  @override
  m.Widget build(m.BuildContext context) {
    return m.SizedBox(
      height: 80,
      child: m.ListView.separated(
        scrollDirection: m.Axis.horizontal,
        padding: const m.EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const m.SizedBox(width: 8),
        itemBuilder: (m.BuildContext context, int index) {
          final DateTime date = dates[index];
          return DateChip(
            date: date,
            selected: _isSameDay(date, selectedDate),
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
