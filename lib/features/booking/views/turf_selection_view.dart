import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commons/commons.dart';
import '../../../ui/navigation/app_routes.dart';
import '../bloc/turf_selection_cubit.dart';
import '../models/turf_summary.dart';

/// First-time entry screen: pick a turf from a card list, Continue, and the
/// current flow (schedule) begins with that turf. Returning users with a
/// stored pick auto-advance straight through.
///
/// Each card shows the turf's name, address, price and a cover image (a local
/// placeholder icon when the image is missing or fails to load). Tapping a
/// card selects it; Continue confirms and persists the pick.
class TurfSelectionView extends StatefulWidget {
  const TurfSelectionView({super.key});

  @override
  State<TurfSelectionView> createState() => _TurfSelectionViewState();
}

class _TurfSelectionViewState extends State<TurfSelectionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TurfSelectionCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TurfSelectionCubit, TurfSelectionState>(
      builder: (BuildContext context, TurfSelectionState state) {
        // A stored pick (returning user or just confirmed) sends the user
        // into the schedule flow with the chosen turf id.
        if (state.storedTurfId case final String storedTurfId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.goNamed(
                AppRoutes.schedule,
                queryParameters: <String, String>{'turfId': storedTurfId},
              );
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Select Turf')),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TurfSelectionState state) {
    if (state.isLoading && state.turfs.isEmpty) {
      return const LoadingView();
    }

    if (state.errorMessage case final String error when state.turfs.isEmpty) {
      return ErrorView(
        message: error,
        onRetry: () => context.read<TurfSelectionCubit>().load(),
      );
    }

    final TurfSelectionCubit cubit = context.read<TurfSelectionCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: state.turfs.length,
            itemBuilder: (BuildContext context, int index) {
              final TurfSummary turf = state.turfs[index];
              return _TurfCard(
                turf: turf,
                selected: turf.id == state.selectedTurfId,
                onTap: () => cubit.selectTurf(turf.id),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppFilledButton(
            text: 'Continue',
            onPressed: state.selectedTurfId == null
                ? null
                : () => cubit.confirm(),
          ),
        ),
      ],
    );
  }
}

/// A selectable turf card: cover image (or placeholder icon), name, address,
/// price per hour and rating.
class _TurfCard extends StatelessWidget {
  const _TurfCard({
    required this.turf,
    required this.selected,
    required this.onTap,
  });

  final TurfSummary turf;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TurfCoverImage(
              coverImageUrl: turf.coverImageUrl,
              width: 96,
              height: 96,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      turf.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (turf.address case final String address) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        if (turf.pricePerHour case final double price) ...[
                          Text(
                            _formatPrice(price),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (turf.rating case final double rating) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: colors.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 12),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? colors.primary : colors.outline,
              ),
            ),
          ],
        ),
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

/// Renders the turf cover image, falling back to a local placeholder icon
/// when the URL is missing or fails to load.
class _TurfCoverImage extends StatelessWidget {
  const _TurfCoverImage({
    required this.coverImageUrl,
    required this.width,
    required this.height,
  });

  final String? coverImageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? url = coverImageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder(context);
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.sports_soccer, size: 40, color: colors.primary),
    );
  }
}
