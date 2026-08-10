import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    this.selected = false,
    this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isToday = _isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: isToday && !selected
              ? Border.all(color: colors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              DateFormat('EEE').format(date),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w700,
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
