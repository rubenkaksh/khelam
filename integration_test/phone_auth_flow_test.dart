import 'package:commons/commons.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/auth/data/auth_api_service.dart';
import 'package:khelam/features/auth/data/auth_exception.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';

/// Exercises the real phone auth flow end-to-end against the live NestJS
/// backend (`rms-futsal-backend` on branch `feature/login-auth`, port 8000).
///
/// From the Android emulator the host machine is reachable at `10.0.2.2`, so
/// the base URL matches the app's `.env` (`API_BASE_URL`) and the backend
/// must be running on the host:
///
///     cd rms-futsal-backend && npm run start:dev
///
/// Run with:
///
///     flutter test integration_test/phone_auth_flow_test.dart -d <device>
void main() {
  const String baseUrl = 'http://10.0.2.2:8000';
  const String phoneNumber = '9800000001';
  const String password = 'khelam123';
  const String fullName = 'Khelam Integration Test';

  testWidgets('register then login against the live backend', (tester) async {
    final DioApiClient apiClient = DioApiClient(baseUrl: baseUrl);
    final AuthTokenStore tokenStore = AuthTokenStore();
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

    // A persisted session restores at "launch".
    await tokenStore.saveSession(session);
    final AuthSession? restored = await tokenStore.restoreSession();
    expect(restored?.accessToken, session.accessToken);
    expect(restored?.user.phoneNumber, phoneNumber);
  });
}