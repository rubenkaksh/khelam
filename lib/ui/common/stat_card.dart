import 'package:flutter/material.dart' as m;

class StatCard extends m.StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final m.Widget icon;
  final String label;
  final String value;
  final m.Color? valueColor;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.Card(
      child: m.Padding(
        padding: const m.EdgeInsets.all(16),
        child: m.Column(
          crossAxisAlignment: m.CrossAxisAlignment.start,
          mainAxisSize: m.MainAxisSize.min,
          children: <m.Widget>[
            m.Row(
              children: <m.Widget>[
                m.IconTheme(data: m.IconThemeData(color: colors.primary), child: icon),
                const m.SizedBox(width: 8),
                m.Text(label, style: m.Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const m.SizedBox(height: 8),
            m.Text(
              value,
              style: m.Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: m.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
