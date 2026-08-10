import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

import '../../../helpers/fake_secure_storage.dart';

/// [FakeSecureStorage] whose keychain always fails like the iOS simulator
/// without a `keychain-access-groups` entitlement (`-34018`).
class _UnavailableKeychainStorage extends FakeSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(
      code: 'Unexpected security result code',
      message: 'A required entitlement isnt present.',
      details: -34018,
    );
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(
      code: 'Unexpected security result code',
      message: 'A required entitlement isnt present.',
      details: -34018,
    );
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(
      code: 'Unexpected security result code',
      message: 'A required entitlement isnt present.',
      details: -34018,
    );
  }
}

void main() {
  group('AuthTokenStore', () {
    final AuthSession session = AuthSession(
      accessToken: 'token-1',
      user: AuthUser.fromJson(<String, dynamic>{
        'id': 'u-1',
        'full_name': 'Player One',
        'email': null,
        'avatar_url': null,
        'phone_number': '9800000001',
        'is_active': true,
        'created_at': '2026-08-07T10:00:00.000Z',
        'updated_at': '2026-08-07T10:00:00.000Z',
      }),
    );

    test('persist=false is a no-op: nothing stored, restore returns null', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final AuthTokenStore store = AuthTokenStore(
        storage: storage,
        persist: false,
      );

      await store.saveSession(session);
      expect(storage.values, isEmpty);

      final AuthSession? restored = await store.restoreSession();
      expect(restored, isNull);

      await store.clear();
      expect(storage.values, isEmpty);
    });

    test('persist=true round-trips the session through storage', () async {
      final FakeSecureStorage storage = FakeSecureStorage();
      final AuthTokenStore store = AuthTokenStore(storage: storage);

      await store.saveSession(session);
      expect(storage.values, isNotEmpty);

      final AuthSession? restored = await store.restoreSession();
      expect(restored?.accessToken, 'token-1');
      expect(restored?.user.id, 'u-1');

      await store.clear();
      expect(storage.values, isEmpty);
      expect(await store.restoreSession(), isNull);
    });

    test('restoreSession returns null when nothing was stored', () async {
      final AuthTokenStore store = AuthTokenStore(
        storage: FakeSecureStorage(),
      );

      expect(await store.restoreSession(), isNull);
    });

    test('keychain PlatformException degrades to a no-op, not a crash', () async {
      final AuthTokenStore store = AuthTokenStore(
        storage: _UnavailableKeychainStorage(),
      );

      // Startup restore must not throw — the app starts logged-out instead.
      await expectLater(store.restoreSession(), completion(isNull));

      // Login-time save and logout clear must not throw either.
      await expectLater(store.saveSession(session), completes);
      await expectLater(store.clear(), completes);
    });
  });
}
