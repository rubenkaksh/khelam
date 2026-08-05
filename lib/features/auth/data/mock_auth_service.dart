import 'package:commons/commons.dart';

import '../auth_service.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';

/// In-memory implementation of [AuthService] for dev mode and widget tests.
///
/// The phone-number demo credentials mirror the shape the backend expects but
/// never touch a server. The shared login screen's first field is the phone
/// number, so the demo "email" value is a phone number even though the
/// commons contract names it `demoEmail`.
class MockAuthService implements AuthService {
  const MockAuthService();

  /// Demo phone number (the backend login's first field is the phone number).
  static const String demoEmail = '9800000001';
  static const String demoPassword = 'khelam123';

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (email.trim() != demoEmail || password != demoPassword) {
      throw const MockAuthException('Invalid demo credentials.');
    }

    return const AuthUser(
      id: 'demo-user',
      phoneNumber: demoEmail,
      displayName: 'Khelam Demo',
    );
  }

  @override
  Future<AuthSession> phoneLogin({
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (phoneNumber.trim() != demoEmail || password != demoPassword) {
      throw const MockAuthException('Invalid demo credentials.');
    }

    return const AuthSession(
      accessToken: 'mock-token',
      user: AuthUser(
        id: 'demo-user',
        phoneNumber: demoEmail,
        displayName: 'Khelam Demo',
      ),
    );
  }

  @override
  Future<AuthSession> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return AuthSession(
      accessToken: 'mock-token',
      user: AuthUser(
        id: 'demo-user',
        phoneNumber: phoneNumber,
        displayName: fullName,
      ),
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

  @override
  Future<void> logout() async {
    // Nothing to detach: mock mode keeps no HTTP client state.
  }
}

class MockAuthException implements Exception {
  const MockAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
