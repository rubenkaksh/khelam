import 'auth_user.dart';

/// A successful backend authentication: the bearer [accessToken] for
/// protected endpoints plus the authenticated [AuthUser].
///
/// Assembled by `AuthService` implementations (mock and API) and persisted
/// whole by `AuthTokenStore`; never parsed directly from JSON.
class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;
}
