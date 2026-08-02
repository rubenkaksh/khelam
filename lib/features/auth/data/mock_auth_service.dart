import 'package:commons/commons.dart';

import '../auth_service.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';

class MockAuthService implements AuthService {
  const MockAuthService();

  static const String demoEmail = 'demo@khelam.dev';
  static const String demoPassword = 'password123';

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const MockAuthException('Invalid demo credentials.');
    }

    return const AuthUser(
      id: 'demo-user',
      email: demoEmail,
      displayName: 'Khelam Demo',
    );
  }

  @override
  Future<AuthSession> googleLogin(GoogleSignInResult result) async {
    // Dev mode: no backend involved; build the session from the Google
    // result exactly like the pre-backend flow did.
    return AuthSession(
      accessToken: 'mock-token',
      user: AuthUser(
        id: 'google:${result.email}',
        email: result.email,
        displayName: result.displayName ?? result.email.split('@').first,
      ),
    );
  }

  @override
  Future<AuthUser?> init() async {
    // Mock mode stores nothing, so there is nothing to restore.
    return null;
  }
}

class MockAuthException implements Exception {
  const MockAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
