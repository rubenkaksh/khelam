import 'package:flutter/material.dart' as m;

class SectionHeader extends m.StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onTap,
  });

  final String title;
  final m.Widget? leadingIcon;
  final m.VoidCallback? onTap;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.Row(
      children: <m.Widget>[
        if (leadingIcon case final m.Widget icon) ...[
          icon,
          const m.SizedBox(width: 8),
        ],
        m.Text(
          title,
          style: m.Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: m.FontWeight.w600),
        ),
        const m.Spacer(),
        if (onTap != null)
          m.IconButton(
            icon: m.Icon(m.Icons.chevron_right, color: colors.onSurfaceVariant),
            onPressed: onTap,
          ),
      ],
    );
  }
}
