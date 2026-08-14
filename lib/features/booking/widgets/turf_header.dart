import 'package:flutter/material.dart';

import '../models/turf_summary.dart';

class TurfHeader extends StatelessWidget {
  const TurfHeader({super.key, required this.turf});

  final TurfSummary turf;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: colors.primaryContainer,
            child: Text(
              turf.name.isNotEmpty ? turf.name[0] : '?',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  turf.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (turf.address case final String address)
                  Text(
                    address,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                if (turf.pricePerHour != null || turf.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      if (turf.pricePerHour case final double price) ...[
                        Text(
                          _formatPrice(price),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (turf.rating case final double rating) ...[
                        Icon(Icons.star_rounded, size: 14, color: colors.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'All Day',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPrice(double price) {
    final String whole = price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return '₹$whole/hr';
  }
}
