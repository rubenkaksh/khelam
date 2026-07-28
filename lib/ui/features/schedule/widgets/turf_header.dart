import 'package:flutter/material.dart' as m;

import '../../../../domain/models/turf_summary.dart';

class TurfHeader extends m.StatelessWidget {
  const TurfHeader({
    super.key,
    required this.turf,
  });

  final TurfSummary turf;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.Padding(
      padding: const m.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: m.Row(
        children: <m.Widget>[
          m.CircleAvatar(
            backgroundColor: colors.primaryContainer,
            child: m.Text(
              turf.name.isNotEmpty ? turf.name[0] : '?',
              style: m.TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
          const m.SizedBox(width: 12),
          m.Expanded(
            child: m.Column(
              crossAxisAlignment: m.CrossAxisAlignment.start,
              children: <m.Widget>[
                m.Text(
                  turf.name,
                  style: m.Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: m.FontWeight.w600,
                  ),
                ),
                if (turf.address != null)
                  m.Text(
                    turf.address!,
                    style: m.Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          m.Container(
            padding: const m.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: m.BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: m.BorderRadius.circular(16),
            ),
            child: m.Text(
              'All Day',
              style: m.Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
