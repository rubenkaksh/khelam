import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/bloc/auth_cubit.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/data/mock_auth_service.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

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
        tokenStore: _RecordingTokenStore(),
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
        tokenStore: _RecordingTokenStore(),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.displayName, 'no-name');
    });

    test('persists the session after a successful sign-in', () async {
      final _RecordingTokenStore store = _RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(
          result: const GoogleSignInResult(
            email: 'player@khelam.dev',
            idToken: 'id-token',
          ),
        ),
        tokenStore: store,
      );

      await cubit.googleSignIn();

      expect(store.savedSession?.accessToken, 'mock-token');
      expect(store.savedSession?.user.email, 'player@khelam.dev');
    });

    test('returns to the initial state and saves nothing when canceled', () async {
      final _RecordingTokenStore store = _RecordingTokenStore();
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
        tokenStore: store,
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
        tokenStore: _RecordingTokenStore(),
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
        tokenStore: _RecordingTokenStore(),
      );

      cubit.restoreSession(
        const AuthUser(id: 'u1', email: 'a@b.dev', displayName: 'A B'),
      );

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.id, 'u1');
      expect(cubit.state.user?.email, 'a@b.dev');
    });
  });
}
