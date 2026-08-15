import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:khelam/features/booking/bloc/turf_selection_cubit.dart';
import 'package:khelam/features/booking/data/turfs_repository.dart';
import 'package:khelam/features/booking/models/turf_summary.dart';
import 'package:khelam/features/booking/views/turf_selection_view.dart';
import 'package:khelam/ui/navigation/app_routes.dart';

import '../../../helpers/recording_preferences.dart';

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

  Widget app(TurfSelectionCubit cubit) {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.turfSelectionPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.turfSelectionPath,
          name: AppRoutes.turfSelection,
          builder: (BuildContext c, GoRouterState s) =>
              BlocProvider<TurfSelectionCubit>.value(
                value: cubit,
                child: const TurfSelectionView(),
              ),
        ),
        GoRoute(
          path: AppRoutes.schedulePath,
          name: AppRoutes.schedule,
          builder: (BuildContext c, GoRouterState s) =>
              const Scaffold(body: Text('SCHEDULE_PLACEHOLDER')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  TurfSelectionCubit buildCubit() {
    return TurfSelectionCubit(
      repository: repository,
      preferences: preferences,
    );
  }

  testWidgets('first-time user sees turf cards and a disabled Continue', (
    WidgetTester tester,
  ) async {
    final TurfSelectionCubit cubit = buildCubit();
    await tester.pumpWidget(app(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Select Turf'), findsOneWidget);
    expect(find.text('Turf A'), findsOneWidget);
    expect(find.text('Turf B'), findsOneWidget);

    final FilledButton continueButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('selecting a turf card enables Continue; confirming lands on the schedule', (
    WidgetTester tester,
  ) async {
    final TurfSelectionCubit cubit = buildCubit();
    await tester.pumpWidget(app(cubit));
    await tester.pumpAndSettle();

    // Turf cards are labelled by name; tap to select.
    await tester.tap(find.text(firstTurf.name));
    await tester.pumpAndSettle();

    final FilledButton continueButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(continueButton.onPressed, isNotNull);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('SCHEDULE_PLACEHOLDER'), findsOneWidget);
    expect(preferences.storedTurfId, firstTurf.id);
  });

  testWidgets('a stored turf auto-advances past the turf list', (
    WidgetTester tester,
  ) async {
    preferences.storedTurfId = secondTurf.id;
    final TurfSelectionCubit cubit = buildCubit();
    await tester.pumpWidget(app(cubit));
    await tester.pumpAndSettle();

    expect(find.text('SCHEDULE_PLACEHOLDER'), findsOneWidget);
    expect(find.text(secondTurf.name), findsNothing);
  });

  testWidgets('load failure shows the error view; retry recovers', (
    WidgetTester tester,
  ) async {
    repository.shouldThrow = true;
    final TurfSelectionCubit cubit = buildCubit();
    await tester.pumpWidget(app(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Could not load turfs.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // The endpoint is back: retry loads the turf cards.
    repository.shouldThrow = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text(firstTurf.name), findsOneWidget);
  });
}
