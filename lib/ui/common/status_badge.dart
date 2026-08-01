import 'package:flutter/material.dart' as m;

enum BadgeTone { primary, success, warning, neutral }

class StatusBadge extends m.StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = BadgeTone.neutral,
  });

  final String label;
  final m.Widget? icon;
  final BadgeTone tone;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;

    final (m.Color bg, m.Color fg) = switch (tone) {
      BadgeTone.primary => (colors.primaryContainer, colors.onPrimaryContainer),
      BadgeTone.success => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      BadgeTone.warning => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      BadgeTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };

    return m.Container(
      padding: const m.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: m.BoxDecoration(
        color: bg,
        borderRadius: m.BorderRadius.circular(12),
      ),
      child: m.Row(
        mainAxisSize: m.MainAxisSize.min,
        children: <m.Widget>[
          if (icon case final m.Widget iconWidget) ...[
            m.IconTheme(
              data: m.IconThemeData(size: 14, color: fg),
              child: iconWidget,
            ),
            const m.SizedBox(width: 4),
          ],
          m.Text(
            label,
            style: m.Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: m.FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
