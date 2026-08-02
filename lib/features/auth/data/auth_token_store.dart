import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';

/// Persists the authenticated session (`accessToken` + user) in platform
/// secure storage (Keychain / Keystore).
///
/// The session is stored as a single JSON entry so save and restore stay
/// atomic. Registered as a lazy singleton; injectable with a fake storage in
/// tests.
class AuthTokenStore {
  AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _sessionKey = 'auth_session';

  Future<void> saveSession(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(<String, Object?>{
        'access_token': session.accessToken,
        'user': session.user.toJson(),
      }),
    );
  }

  /// Returns the persisted session, or null when none is stored or the stored
  /// payload is unreadable.
  Future<AuthSession?> restoreSession() async {
    final String? raw = await _storage.read(key: _sessionKey);
    if (raw == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final Object? userJson = decoded['user'];
      final Object? accessToken = decoded['access_token'];
      if (userJson is! Map<String, dynamic> || accessToken is! String) {
        return null;
      }
      return AuthSession(
        accessToken: accessToken,
        user: AuthUser.fromJson(userJson),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
