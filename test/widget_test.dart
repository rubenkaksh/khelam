import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/di/service_locator.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/ui/navigation/app_router.dart';

import 'helpers/recording_token_store.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
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

  testWidgets('App starts on the schedule screen', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Schedule'), findsOneWidget);
  });

  testWidgets('Unauthenticated access to home redirects to login', (
    WidgetTester tester,
  ) async {
    configureDependencies();
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
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('+ Available').first);
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
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Guest taps an available slot → redirected to login.
    await tester.tap(find.text('+ Available').first);
    await tester.pumpAndSettle();
    expect(find.text('Khelam Login'), findsOneWidget);

    // Demo credentials are pre-filled; sign in.
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    // Landed back on the schedule, guard now passing.
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('+ Available'), findsWidgets);
  });

  testWidgets('logout from the schedule lands on the login screen', (
    WidgetTester tester,
  ) async {
    configureDependencies();
    overrideTokenStoreWithFake();
    await tester.pumpWidget(
      KhelamApp(router: serviceLocator<AppRouter>().router),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Khelam Login'), findsOneWidget);
  });
}
