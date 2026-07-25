import '../../domain/models/auth_user.dart';
import '../../domain/repositories/auth_service.dart';

class AuthRepository {
  const AuthRepository({required AuthService service}) : _service = service;

  final AuthService _service;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    return _service.login(email: email, password: password);
  }
}
