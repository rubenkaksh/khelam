import 'package:commons/commons.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:khelam/features/auth/bloc/auth_cubit.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/data/mock_auth_service.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/auth/views/register_view.dart';
import 'package:khelam/ui/navigation/app_routes.dart';

class FakeGoogleSignInService implements GoogleSignInService {
  @override
  Future<GoogleSignInResult?> signIn() async => null;

  @override
  Future<void> signOut() async {}
}

/// Records persisted sessions without touching the platform keychain.
class _RecordingTokenStore extends AuthTokenStore {
  AuthSession? savedSession;

  @override
  Future<void> saveSession(AuthSession session) async {
    savedSession = session;
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> clear() async {}
}

void main() {
  late AuthCubit cubit;
  late _RecordingTokenStore store;

  setUp(() {
    store = _RecordingTokenStore();
    cubit = AuthCubit(
      service: const MockAuthService(),
      googleService: FakeGoogleSignInService(),
      tokenStore: store,
    );
  });

  m.Widget app() {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.registerPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.login,
          builder: (m.BuildContext c, GoRouterState s) =>
              const m.Scaffold(body: m.Text('LOGIN_PLACEHOLDER')),
        ),
        GoRoute(
          path: AppRoutes.registerPath,
          name: AppRoutes.register,
          builder: (m.BuildContext c, GoRouterState s) =>
              BlocProvider<AuthCubit>.value(value: cubit, child: const RegisterView()),
        ),
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.home,
          builder: (m.BuildContext c, GoRouterState s) =>
              const m.Scaffold(body: m.Text('HOME_PLACEHOLDER')),
        ),
      ],
    );
    return m.MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders the registration form fields', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });

  testWidgets('validates fields before submitting', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter a phone number.'), findsOneWidget);
    expect(find.text('Enter at least 6 characters.'), findsOneWidget);
  });

  testWidgets('registers and navigates home on success', (tester) async {
    await tester.pumpWidget(app());

    await tester.enterText(
      find.byType(m.TextFormField).at(0),
      'New Player',
    );
    await tester.enterText(
      find.byType(m.TextFormField).at(1),
      '9801237999',
    );
    await tester.enterText(
      find.byType(m.TextFormField).at(2),
      'khelam123',
    );
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('HOME_PLACEHOLDER'), findsOneWidget);
    expect(store.savedSession?.user.displayName, 'New Player');
    expect(store.savedSession?.user.phoneNumber, '9801237999');
  });

  testWidgets('sign-in link returns to the login screen', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_PLACEHOLDER'), findsOneWidget);
  });
}
