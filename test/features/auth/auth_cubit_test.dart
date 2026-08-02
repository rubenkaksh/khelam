import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/bloc/auth_cubit.dart';
import 'package:khelam/features/auth/data/mock_auth_service.dart';

class FakeGoogleSignInService implements GoogleSignInService {
  FakeGoogleSignInService({this.result, this.error});

  GoogleSignInResult? result;
  Object? error;

  @override
  Future<GoogleSignInResult?> signIn() async {
    if (error != null) {
      throw error!;
    }
    return result;
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AuthCubit.googleSignIn', () {
    test('authenticates with the mapped Google user', () async {
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
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.displayName, 'no-name');
    });

    test('returns to the initial state when the user cancels', () async {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(result: null),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('surfaces failures as an error message', () async {
      final AuthCubit cubit = AuthCubit(
        service: const MockAuthService(),
        googleService: FakeGoogleSignInService(
          error: const MockAuthException('Google sign-in failed.'),
        ),
      );

      await cubit.googleSignIn();

      expect(cubit.state.status, AuthStatus.failure);
      expect(cubit.state.errorMessage, 'Google sign-in failed.');
    });
  });
}
