import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/schedule_slot_item.dart';
import 'slot_time_range.dart';

class BookedSlotCard extends StatelessWidget {
  const BookedSlotCard({super.key, required this.item, this.onTap});

  final ScheduleSlotItem item;
  final VoidCallback? onTap;

  /// Tapping a booked slot card calls the booker (customer-entered phone
  /// from `bookedByContact`, C20). No contact → no-op (card tap stays inert).
  Future<void> _callBooker() async {
    final String? contact = item.bookedByContact;
    if (contact == null || contact.isEmpty) {
      return;
    }
    final Uri telUri = Uri(scheme: 'tel', path: contact);
    if (!await launchUrl(telUri)) {
      // Launch failure is non-fatal — the schedule still works.
      debugPrint('BookedSlotCard: could not launch $telUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String title = item.customerName?.split(' ').first ?? 'N/A';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outline,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      color: isDark ? colors.primaryContainer : colors.secondaryContainer,
      child: InkWell(
        onTap: () {
          // Card-level tap (navigation etc.) OR call the booker when a
          // contact is present — contact wins (C20 tap-to-call).
          if (item.bookedByContact case final String contact
              when contact.isNotEmpty) {
            _callBooker();
          } else {
            onTap?.call();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Row(
            children: <Widget>[
              Text(
                slotTimeRange(item.slot),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Booked',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by $title',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
