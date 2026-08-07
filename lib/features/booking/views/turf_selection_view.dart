import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:commons/commons.dart';
import '../../../ui/navigation/app_routes.dart';
import '../bloc/turf_selection_cubit.dart';
import '../models/turf_summary.dart';

/// First-time entry screen: pick a turf from the dropdown, Continue, and the
/// current flow (schedule) begins with that turf. Returning users with a
/// stored pick auto-advance straight through.
///
/// Named as the foundation for a future turf-selection screen: the dropdown
/// is the placeholder UI; a richer picker can replace it while keeping this
/// view's cubit contract.
class TurfSelectionView extends m.StatefulWidget {
  const TurfSelectionView({super.key});

  @override
  m.State<TurfSelectionView> createState() => _TurfSelectionViewState();
}

class _TurfSelectionViewState extends m.State<TurfSelectionView> {
  @override
  void initState() {
    super.initState();
    m.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TurfSelectionCubit>().initialize();
    });
  }

  @override
  m.Widget build(m.BuildContext context) {
    return BlocBuilder<TurfSelectionCubit, TurfSelectionState>(
      builder: (m.BuildContext context, TurfSelectionState state) {
        // A stored pick (returning user or just confirmed) sends the user
        // into the schedule flow with the chosen turf id.
        if (state.storedTurfId case final String storedTurfId) {
          m.WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.goNamed(
                AppRoutes.schedule,
                queryParameters: <String, String>{'turfId': storedTurfId},
              );
            }
          });
        }

        return m.Scaffold(
          appBar: m.AppBar(title: const m.Text('Select Turf')),
          body: _buildBody(context, state),
        );
      },
    );
  }

  m.Widget _buildBody(m.BuildContext context, TurfSelectionState state) {
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
    return m.Padding(
      padding: const m.EdgeInsets.all(16),
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.stretch,
        children: <m.Widget>[
          DropdownInput<String>(
            label: 'Turf',
            hint: 'Choose your turf',
            items: <(String, String)>[
              for (final TurfSummary turf in state.turfs) (turf.id, turf.id),
            ],
            value: state.selectedTurfId,
            onChanged: cubit.selectTurf,
          ),
          const m.SizedBox(height: 24),
          FilledButton(
            text: 'Continue',
            onPressed: state.selectedTurfId == null
                ? null
                : () => cubit.confirm(),
          ),
        ],
      ),
    );
  }
}
