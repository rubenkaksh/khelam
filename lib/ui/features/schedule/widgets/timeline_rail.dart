import 'package:flutter/material.dart' as m;

class TimelineRail extends m.StatelessWidget {
  const TimelineRail({super.key});

  @override
  m.Widget build(m.BuildContext context) {
    final m.ColorScheme colors = m.Theme.of(context).colorScheme;
    return m.SizedBox(
      width: 24,
      child: m.Column(
        mainAxisSize: m.MainAxisSize.min,
        children: <m.Widget>[
          m.Container(
            width: 10,
            height: 10,
            margin: const m.EdgeInsets.only(top: 18),
            decoration: m.BoxDecoration(
              color: colors.outlineVariant,
              shape: m.BoxShape.circle,
            ),
          ),
          m.Container(
            width: 1.5,
            height: 100,
            color: colors.outlineVariant,
          ),
        ],
      ),
    );
  }
}
