import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

class DateChip extends m.StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    this.selected = false,
    this.onTap,
  });

  final DateTime date;
  final bool selected;
  final m.VoidCallback? onTap;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    final bool isToday = _isSameDay(date, DateTime.now());

    return m.GestureDetector(
      onTap: onTap,
      child: m.AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const m.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: m.BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: m.BorderRadius.circular(24),
          border: isToday && !selected
              ? m.Border.all(color: colors.primary, width: 1.5)
              : null,
        ),
        child: m.Column(
          mainAxisAlignment: m.MainAxisAlignment.center,
          mainAxisSize: m.MainAxisSize.min,
          children: <m.Widget>[
            m.Text(
              DateFormat('EEE').format(date),
              style: m.Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
            const m.SizedBox(height: 4),
            m.Text(
              date.day.toString(),
              style: m.Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: m.FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
