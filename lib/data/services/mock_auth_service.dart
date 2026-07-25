import '../../../domain/models/auth_user.dart';
import '../../../domain/repositories/auth_service.dart';

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
}

class MockAuthException implements Exception {
  const MockAuthException(this.message);

  final String message;
}
