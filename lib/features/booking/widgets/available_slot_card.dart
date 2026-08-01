import 'package:flutter/material.dart' as m;

class AvailableSlotCard extends m.StatelessWidget {
  const AvailableSlotCard({super.key, this.onTap});

  final m.VoidCallback? onTap;

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.Card(
      shape: m.RoundedRectangleBorder(
        borderRadius: m.BorderRadius.circular(12),
        side: m.BorderSide(
          color: colors.outline,
          width: 1,
          strokeAlign: m.BorderSide.strokeAlignInside,
        ),
      ),
      color: colors.surface,
      child: m.InkWell(
        onTap: onTap,
        borderRadius: m.BorderRadius.circular(12),
        child: m.Padding(
          padding: const m.EdgeInsets.all(12),
          child: m.Row(
            children: <m.Widget>[
              m.Container(
                width: 4,
                height: 48,
                decoration: m.BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: m.BorderRadius.circular(2),
                ),
              ),
              const m.SizedBox(width: 12),
              m.Expanded(
                child: m.Text(
                  '+ Available',
                  style: m.Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
