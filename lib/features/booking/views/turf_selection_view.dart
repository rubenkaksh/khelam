import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DropdownInput<String>(
            label: 'Turf',
            hint: 'Choose your turf',
            items: <(String, String)>[
              for (final TurfSummary turf in state.turfs) (turf.id, turf.id),
            ],
            value: state.selectedTurfId,
            onChanged: cubit.selectTurf,
          ),
          const SizedBox(height: 24),
          AppFilledButton(
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
