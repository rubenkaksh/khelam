import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/booking/bloc/turf_selection_cubit.dart';
import 'package:khelam/features/booking/data/turfs_repository.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';

import '../../helpers/recording_preferences.dart';

class FakeTurfsRepository implements TurfsRepository {
  FakeTurfsRepository(this.turfs);

  final List<TurfSummary> turfs;
  bool shouldThrow = false;

  @override
  Future<List<TurfSummary>> getTurfs() async {
    if (shouldThrow) throw Exception('Network error');
    return turfs;
  }
}

void main() {
  const TurfSummary firstTurf = TurfSummary(
    id: '44444444-4444-4444-4444-444444444441',
    name: 'Turf A',
  );
  const TurfSummary secondTurf = TurfSummary(
    id: '2f293756-5cc8-41a4-be78-89e13c2d2ea6',
    name: 'Turf B',
  );

  late FakeTurfsRepository repository;
  late RecordingPreferences preferences;

  setUp(() {
    repository = FakeTurfsRepository(const <TurfSummary>[firstTurf, secondTurf]);
    preferences = RecordingPreferences();
  });

  TurfSelectionCubit buildCubit() {
    return TurfSelectionCubit(
      repository: repository,
      preferences: preferences,
    );
  }

  group('TurfSelectionCubit', () {
    test('initial state has no turf selected, nothing stored', () {
      final cubit = buildCubit();
      expect(cubit.state.turfs, isEmpty);
      expect(cubit.state.selectedTurfId, isNull);
      expect(cubit.state.storedTurfId, isNull);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('initialize loads the turf list when nothing is stored', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      expect(cubit.state.turfs, hasLength(2));
      expect(cubit.state.storedTurfId, isNull);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('initialize skips the list when a turf is already stored', () async {
      preferences.storedTurfId = secondTurf.id;
      final cubit = buildCubit();
      await cubit.initialize();

      // Returning user: no list fetch, straight to the stored pick.
      expect(cubit.state.turfs, isEmpty);
      expect(cubit.state.storedTurfId, secondTurf.id);
    });

    test('load sets an error message on failure', () async {
      repository.shouldThrow = true;
      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.state.errorMessage, 'Could not load turfs.');
      expect(cubit.state.turfs, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('selectTurf records the dropdown selection', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      cubit.selectTurf(secondTurf.id);
      expect(cubit.state.selectedTurfId, secondTurf.id);
    });

    test('confirm persists the selection and sets storedTurfId', () async {
      final cubit = buildCubit();
      await cubit.initialize();
      cubit.selectTurf(firstTurf.id);

      final bool persisted = await cubit.confirm();
      expect(persisted, isTrue);
      expect(cubit.state.storedTurfId, firstTurf.id);
      expect(preferences.storedTurfId, firstTurf.id);
    });

    test('confirm without a selection does not persist anything', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      final bool persisted = await cubit.confirm();
      expect(persisted, isFalse);
      expect(cubit.state.storedTurfId, isNull);
      expect(preferences.storedTurfId, isNull);
    });

    test('confirm surfaces an error when persistence fails', () async {
      preferences.failWrites = true;
      final cubit = buildCubit();
      await cubit.initialize();
      cubit.selectTurf(firstTurf.id);

      final bool persisted = await cubit.confirm();
      expect(persisted, isFalse);
      expect(cubit.state.storedTurfId, isNull);
      expect(cubit.state.errorMessage, 'Could not save your selection.');
    });
  });
}
