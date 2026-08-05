import 'package:commons/commons.dart';

import 'models/auth_session.dart';
import 'models/auth_user.dart';

abstract interface class AuthService {
  Future<AuthUser> login({required String email, required String password});

  /// Phone-number login against the live backend. The backend's users are
  /// identified by phone number, so the shared login screen's first field
  /// carries the phone number here.
  ///
  /// Returns a full [AuthSession] (`accessToken` + backend user profile) so
  /// callers can persist the bearer token.
  Future<AuthSession> phoneLogin({
    required String phoneNumber,
    required String password,
  });

  /// Registers a new phone-number account and returns the session minted by
  /// the backend (register auto-authenticates: the backend replies with an
  /// `accessToken` for the created user).
  Future<AuthSession> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  });

  /// Exchanges a Google sign-in result for an app [AuthSession] (bearer
  /// token + backend user profile).
  ///
  /// The Google SDK provides [GoogleSignInResult.idToken]; when it is null
  /// (e.g. missing `GOOGLE_SERVER_CLIENT_ID`), implementations should throw
  /// an [AuthException] with a guiding message.
  Future<AuthSession> googleLogin(GoogleSignInResult result);

  /// Restores a previously persisted session at app launch.
  ///
  /// Returns the authenticated user, or null when no session was stored.
  Future<AuthUser?> init();

  /// Clears client-side auth state (e.g. the bearer token attached to the
  /// HTTP client). Persisted sessions are cleared separately by the caller.
  Future<void> logout();
}
