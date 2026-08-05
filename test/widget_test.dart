import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/app.dart';
import 'package:khelam/di/service_locator.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/ui/navigation/app_router.dart';

/// Records persisted sessions without touching the platform keychain, which
/// has no implementation in widget tests (unmocked platform channel futures
/// never complete, so the login spinner would hang forever).
class _RecordingTokenStore extends AuthTokenStore {
  AuthSession? savedSession;

  @override
  Future<void> saveSession(AuthSession session) async {
    savedSession = session;
  }

  @override
  Future<AuthSession?> restoreSession() async => savedSession;

  @override
  Future<void> clear() async {
    savedSession = null;
  }
}

void main() {
  setUp(() {
    serviceLocator.reset();
  });

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
    serviceLocator.allowReassignment = true;
    serviceLocator.registerLazySingleton<AuthTokenStore>(
      () => _RecordingTokenStore(),
    );
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
}
