import 'dart:io' show Platform;

import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/data/auth_api_service.dart';
import 'package:khelam/features/auth/data/auth_exception.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';

/// Exercises the real phone auth flow end-to-end against the live NestJS
/// backend (`rms-futsal-backend` on branch `feature/login-auth`, port 8000).
///
/// The Android emulator reaches the host machine at `10.0.2.2`; the iOS
/// simulator and macOS desktop share the host network, so `localhost` works
/// there. The backend must be running on the host:
///
///     cd rms-futsal-backend && npm run start:dev
///
/// Run with:
///
///     flutter test integration_test/phone_auth_flow_test.dart -d <device>
void main() {
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : 'http://localhost:8000';
  const String phoneNumber = '9800000001';
  const String password = 'khelam123';
  const String fullName = 'Khelam Integration Test';

  testWidgets('register then login against the live backend', (tester) async {
    final DioApiClient apiClient = DioApiClient(baseUrl: baseUrl);
    // On macOS the store keeps the session in memory only (the ad-hoc-signed
    // release build cannot use the keychain), so no platform channel is hit.
    final AuthTokenStore tokenStore = AuthTokenStore(
      persist: !Platform.isMacOS,
    );
    final AuthApiService service = AuthApiService(
      apiClient: apiClient,
      tokenStore: tokenStore,
    );

    // Register: first run creates the account; later runs hit the 409
    // conflict guard, which is the expected idempotent behaviour.
    try {
      final AuthSession registered = await service.register(
        phoneNumber: phoneNumber,
        fullName: fullName,
        password: password,
      );
      expect(registered.accessToken, isNotEmpty);
      expect(registered.user.phoneNumber, phoneNumber);
      expect(registered.user.displayName, fullName);
    } on AuthException catch (e) {
      expect(e.message, contains('already registered'));
    }

    // Login with the same credentials must always succeed.
    final AuthSession session = await service.phoneLogin(
      phoneNumber: phoneNumber,
      password: password,
    );
    expect(session.accessToken, isNotEmpty);
    expect(session.user.phoneNumber, phoneNumber);
    expect(session.user.displayName, isNotEmpty);

    // Bearer-token attachment to the shared client is unit-tested
    // (auth_api_service_test.dart, recording adapter). The live slots
    // endpoints are out of scope here: the shared Supabase schema is behind
    // the local schema (slots.locked_by missing) until the drift is resolved.

    // A persisted session restores at "launch" — except on macOS, where the
    // store is a no-op pass-through and nothing is restored.
    await tokenStore.saveSession(session);
    if (Platform.isMacOS) {
      expect(await tokenStore.restoreSession(), isNull);
    } else {
      final AuthSession? restored = await tokenStore.restoreSession();
      expect(restored?.accessToken, session.accessToken);
      expect(restored?.user.phoneNumber, phoneNumber);
    }
  });
}