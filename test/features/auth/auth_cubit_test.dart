import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/bloc/auth_cubit.dart';
import 'package:khelam/features/auth/data/mock_auth_service.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

import '../../helpers/recording_preferences.dart';
import '../../helpers/recording_token_store.dart';

class FakeGoogleSignInService implements GoogleSignInService {
  FakeGoogleSignInService({this.result, this.error});

  GoogleSignInResult? result;
  Object? error;

  @override
  Future<GoogleSignInResult?> signIn() async {
    final Object? e = error;
    if (e != null) {
      throw e;
    }
    return result;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AuthCubit.googleSignIn', () {
    test('authenticates with the backend-mapped Google user', () async {
      final FakeGoogleSignInService fake = FakeGoogleSignInService(
        result: const GoogleSignInResult(
          email: 'player@khelam.dev',
          displayName: 'Khelam Player',
          idToken: 'id-token',
        ),
      );
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: fake,
        tokenStore: RecordingTokenStore(),
        preferences: RecordingPreferences(),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.email, 'player@khelam.dev');
      expect(cubit.state.user?.displayName, 'Khelam Player');
      expect(cubit.state.user?.id, 'google:player@khelam.dev');
    });

    test('falls back to the email local part as display name', () async {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(
          result: const GoogleSignInResult(email: 'no-name@khelam.dev'),
        ),
        tokenStore: RecordingTokenStore(),
        preferences: RecordingPreferences(),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.displayName, 'no-name');
    });

    test('persists the session after a successful sign-in', () async {
      final RecordingTokenStore store = RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(
          result: const GoogleSignInResult(
            email: 'player@khelam.dev',
            idToken: 'id-token',
          ),
        ),
        tokenStore: store,
        preferences: RecordingPreferences(),
      );

      await cubit.googleSignIn();

      expect(store.savedSession?.accessToken, 'mock-token');
      expect(store.savedSession?.user.email, 'player@khelam.dev');
    });

    test('returns to the initial state and saves nothing when canceled', () async {
      final RecordingTokenStore store = RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: store,
        preferences: RecordingPreferences(),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(store.savedSession, isNull);
    });

    test('surfaces failures as an error message', () async {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(
          error: const MockAuthException('Google sign-in failed.'),
        ),
        tokenStore: RecordingTokenStore(),
        preferences: RecordingPreferences(),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.errorMessage, 'Google sign-in failed.');
    });
  });

  group('AuthCubit.restoreSession', () {
    test('emits authenticated with the restored user', () {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: RecordingTokenStore(),
        preferences: RecordingPreferences(),
      );

      cubit.restoreSession(
        const AuthUser(id: 'u1', email: 'a@b.dev', displayName: 'A B'),
      );

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.id, 'u1');
      expect(cubit.state.user?.email, 'a@b.dev');
    });
  });

  group('AuthCubit phone login & register', () {
    test('phone login authenticates and persists the session', () async {
      final RecordingTokenStore store = RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: store,
        preferences: RecordingPreferences(),
      );

      await cubit.login(
        email: MockAuthService.demoEmail,
        password: MockAuthService.demoPassword,
      );

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.phoneNumber, MockAuthService.demoEmail);
      expect(cubit.state.user?.displayName, 'Khelam Demo');
      expect(store.savedSession?.accessToken, 'mock-token');
      expect(store.savedSession?.user.id, 'demo-user');
    });

    test('phone login failure surfaces as an error message', () async {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: RecordingTokenStore(),
        preferences: RecordingPreferences(),
      );

      await cubit.login(email: '9800000002', password: 'wrong');

      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.errorMessage, 'Invalid demo credentials.');
      expect(cubit.state.isLoading, isFalse);
    });

    test('register authenticates and persists the session', () async {
      final RecordingTokenStore store = RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: store,
        preferences: RecordingPreferences(),
      );

      await cubit.register(
        phoneNumber: '9801237999',
        fullName: 'New Player',
        password: 'khelam123',
      );

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.displayName, 'New Player');
      expect(cubit.state.user?.phoneNumber, '9801237999');
      expect(store.savedSession?.accessToken, 'mock-token');
    });
  });

  group('AuthCubit.logout', () {
    test('clears the persisted session and returns to the initial state', () async {
      final RecordingTokenStore store = RecordingTokenStore();
      final RecordingPreferences preferences = RecordingPreferences();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: store,
        preferences: preferences,
      );

      await cubit.login(
        email: MockAuthService.demoEmail,
        password: MockAuthService.demoPassword,
      );
      expect(cubit.state.isAuthenticated, isTrue);
      expect(store.savedSession, isNotNull);

      await cubit.logout();

      expect(store.cleared, isTrue);
      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.isAuthenticated, isFalse);
      expect(cubit.state.user, isNull);
    });

    test('clears preferences alongside the session', () async {
      final RecordingPreferences preferences = RecordingPreferences();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: RecordingTokenStore(),
        preferences: preferences,
      );

      await preferences.setSelectedTurfId('turf-1');
      expect(await preferences.selectedTurfId(), 'turf-1');

      await cubit.logout();

      expect(preferences.cleared, isTrue);
      expect(await preferences.selectedTurfId(), isNull);
    });
  });
}
