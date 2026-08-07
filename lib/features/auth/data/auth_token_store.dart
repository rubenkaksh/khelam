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
///
/// When [persist] is false the store is a no-op pass-through: `saveSession`
/// and `clear` do nothing and `restoreSession` always returns null. The
/// session then lives in memory only. This is how the macOS release build is
/// wired — the sandbox denies keychain access without a
/// `keychain-access-groups` entitlement, and that entitlement requires
/// signing with a development certificate (the release DMG is ad-hoc signed).
class AuthTokenStore {
  AuthTokenStore({FlutterSecureStorage? storage, bool persist = true})
    : _storage = storage ?? const FlutterSecureStorage(),
      _persist = persist;

  final FlutterSecureStorage _storage;
  final bool _persist;

  static const String _sessionKey = 'auth_session';

  Future<void> saveSession(AuthSession session) {
    if (!_persist) {
      return Future<void>.value();
    }
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
    if (!_persist) {
      return null;
    }
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

  Future<void> clear() {
    if (!_persist) {
      return Future<void>.value();
    }
    return _storage.delete(key: _sessionKey);
  }
}
