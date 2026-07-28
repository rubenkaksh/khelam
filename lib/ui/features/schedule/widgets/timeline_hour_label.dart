import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';

class TimelineHourLabel extends m.StatelessWidget {
  const TimelineHourLabel({super.key, required this.time});

  final DateTime time;

  @override
  m.Widget build(m.BuildContext context) {
    return m.Text(
      DateFormat('h:mm a').format(time),
      style: m.Theme.of(context).textTheme.labelSmall?.copyWith(
        color: m.Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
