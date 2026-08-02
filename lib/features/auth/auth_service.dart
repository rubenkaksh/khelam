import 'package:commons/commons.dart';

import 'models/auth_session.dart';
import 'models/auth_user.dart';

abstract interface class AuthService {
  Future<AuthUser> login({required String email, required String password});

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
}
