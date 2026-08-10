import 'package:commons/commons.dart';
import 'package:flutter/material.dart' as m;
import 'package:khelam/ui/core/theme/app_palette.dart';

import '../models/slot.dart';
import 'slot_time_range.dart';

class AvailableSlotCard extends m.StatelessWidget {
  const AvailableSlotCard({super.key, required this.slot, this.onTap});

  final Slot slot;
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
      color: AppPalette.cardBackground,
      child: m.InkWell(
        onTap: onTap,
        borderRadius: m.BorderRadius.circular(12),
        child: m.Padding(
          padding: const m.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: m.Row(
            children: <m.Widget>[
              m.Text(
                slotTimeRange(slot),
                style: m.Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: m.FontWeight.w500,
                  color: colors.onSecondary,
                ),
              ),
              const m.Spacer(),
              AppOutlinedButton(text: 'Book Now', onPressed: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
