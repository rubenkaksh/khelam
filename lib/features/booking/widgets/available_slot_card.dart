import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:khelam/ui/core/theme/app_palette.dart';

import '../models/slot.dart';
import 'slot_time_range.dart';

class AvailableSlotCard extends StatelessWidget {
  const AvailableSlotCard({super.key, required this.slot, this.onTap});

  final Slot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outline,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      color: AppPalette.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: <Widget>[
              Text(
                slotTimeRange(slot),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.onSecondary,
                ),
              ),
              const Spacer(),
              AppOutlinedButton(text: 'Book Now', onPressed: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
