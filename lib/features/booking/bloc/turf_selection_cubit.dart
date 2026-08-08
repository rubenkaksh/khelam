import 'package:commons/commons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/storage/preferences.dart';
import '../data/turfs_repository.dart';
import '../models/turf_summary.dart';

/// State of the turf-selection screen.
///
/// The screen is the foundation for a future richer turf picker: this cubit
/// is the contract (load list / select / persist) that the richer UI will
/// keep using.
class TurfSelectionState {
  const TurfSelectionState({
    this.turfs = const <TurfSummary>[],
    this.selectedTurfId,
    this.storedTurfId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<TurfSummary> turfs;
  final String? selectedTurfId;

  /// Persisted pick: when set, the view auto-advances to the schedule with
  /// this turf (a returning user's stored choice, or the just-confirmed one).
  final String? storedTurfId;
  final bool isLoading;
  final String? errorMessage;

  TurfSelectionState copyWith({
    List<TurfSummary>? turfs,
    String? selectedTurfId,
    String? storedTurfId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TurfSelectionState(
      turfs: turfs ?? this.turfs,
      selectedTurfId: selectedTurfId ?? this.selectedTurfId,
      storedTurfId: storedTurfId ?? this.storedTurfId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TurfSelectionCubit extends Cubit<TurfSelectionState> {
  TurfSelectionCubit({
    required TurfsRepository repository,
    required Preferences preferences,
  }) : _repository = repository,
       _preferences = preferences,
       super(const TurfSelectionState());

  final TurfsRepository _repository;
  final Preferences _preferences;

  /// Entry point: a returning user's stored pick skips the dropdown entirely
  /// ([storedTurfId] set); a first-time user gets the turf list to choose
  /// from.
  Future<void> initialize() async {
    final String? stored = await _preferences.selectedTurfId();
    if (stored != null) {
      emit(state.copyWith(storedTurfId: stored, clearError: true));
      return;
    }
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final List<TurfSummary> turfs = await _repository.getTurfs();
      emit(
        state.copyWith(turfs: turfs, isLoading: false, clearError: true),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load turfs.',
        ),
      );
    }
  }

  void selectTurf(String? turfId) {
    emit(state.copyWith(selectedTurfId: turfId, clearError: true));
  }

  /// Persists the selection and returns whether it succeeded. The view
  /// navigates on the resulting [TurfSelectionState.storedTurfId], so a
  /// failed write keeps the user on the screen with the error shown.
  Future<bool> confirm() async {
    final String? selected = state.selectedTurfId;
    if (selected == null) {
      return false;
    }
    try {
      await _preferences.setSelectedTurfId(selected);
      emit(state.copyWith(storedTurfId: selected, clearError: true));
      return true;
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not save your selection.'));
      return false;
    }
  }
}
