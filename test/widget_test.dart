import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/data/storage/preferences.dart';
import 'package:khelam/di/service_locator.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/booking/data/mock_turfs_repository.dart';
import 'package:khelam/ui/navigation/app_router.dart';

import 'helpers/recording_preferences.dart';
import 'helpers/recording_token_store.dart';

void main() {
  late RecordingPreferences preferences;

  setUp(() {
    serviceLocator.reset();
    preferences = RecordingPreferences();
  });

  /// Swaps the keychain-backed token store for an in-memory fake before the
  /// app first resolves AuthCubit (all registrations are lazy). Required
  /// whenever a test signs in or out: the real FlutterSecureStorage platform
  /// channel has no handler in widget tests, so its futures never complete.
  void overrideTokenStoreWithFake() {
    serviceLocator.allowReassignment = true;
    serviceLocator.registerLazySingleton<AuthTokenStore>(
      () => RecordingTokenStore(),
    );
  }

  /// Swaps the SharedPreferences-backed store for an in-memory fake before
  /// the app first resolves Preferences (lazy). The boot screen reads
  /// preferences on launch, so every test needs this: the real
  /// shared_preferences platform channel has no handler in widget tests and
  /// its futures never complete.
  void overridePreferencesWithRecording() {
    serviceLocator.allowReassignment = true;
    serviceLocator.registerLazySingleton<Preferences>(
      () => preferences,
    );
  }

  /// Boots the app and picks a turf on the first-time selection screen, so
  /// the flow lands on the schedule (the default destination for a user with
  /// a stored turf). Returns once the schedule is showing.
  Future<void> bootAndPickTurf(WidgetTester tester) async {
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // First-time user: dropdown + Continue.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(MockTurfsRepository.firstTurfId).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('App starts on the turf-selection screen', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overridePreferencesWithRecording();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // First-time landing: no stored turf, dropdown + Continue shown.
    expect(find.text('Select Turf'), findsOneWidget);
    expect(find.text('Choose your turf'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('picking a turf persists it and lands on the schedule', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overridePreferencesWithRecording();
    await bootAndPickTurf(tester);

    expect(find.text('Schedule'), findsOneWidget);
    expect(preferences.storedTurfId, MockTurfsRepository.firstTurfId);
  });

  testWidgets('Unauthenticated access to home redirects to login', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overridePreferencesWithRecording();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    serviceLocator<AppRouter>().router.goNamed('home');
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeastNWidgets(1));
  });

  testWidgets('booking a slot while logged out redirects to login', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overridePreferencesWithRecording();
    await bootAndPickTurf(tester);

    await tester.tap(find.text('Book Now').first);
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
  });

  testWidgets('login lands back on the schedule when started from a booking attempt', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    // Swap the keychain-backed token store for an in-memory fake before the
    // app first resolves AuthCubit (all registrations are lazy).
    overrideTokenStoreWithFake();
    overridePreferencesWithRecording();
    await bootAndPickTurf(tester);

    // Guest taps an available slot → redirected to login.
    await tester.tap(find.text('Book Now').first);
    await tester.pumpAndSettle();
    expect(find.text('Khelam Login'), findsOneWidget);

    // Demo credentials are pre-filled; sign in.
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    // Landed back on the schedule, guard now passing.
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Book Now'), findsWidgets);
  });

  testWidgets('logout from the schedule clears preferences and lands on login', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overrideTokenStoreWithFake();
    overridePreferencesWithRecording();
    await bootAndPickTurf(tester);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
    expect(preferences.cleared, isTrue);
    expect(preferences.storedTurfId, isNull);
  });
}
