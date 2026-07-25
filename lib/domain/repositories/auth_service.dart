import '../../domain/models/auth_user.dart';

abstract interface class AuthService {
  Future<AuthUser> login({required String email, required String password});
}
