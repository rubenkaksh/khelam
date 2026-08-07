import 'package:commons/commons.dart';
import 'package:get_it/get_it.dart';

import '../../../data/storage/preferences.dart';
import '../../../di/env_config.dart';
import '../auth_service.dart';
import '../bloc/auth_cubit.dart';
import '../data/auth_api_service.dart';
import '../data/auth_token_store.dart';
import '../data/mock_auth_service.dart';

abstract final class AuthDependencies {
  static void register(GetIt locator) {
    // Mirrors the booking switch: mock by default (fresh clones, widget
    // tests); the .env file opts into the real API by setting API_BASE_URL.
    // Set USE_MOCK_AUTH=true to force the mock even when a base URL exists.
    final bool useMockAuth =
        envValue('USE_MOCK_AUTH') == 'true' || envValue('API_BASE_URL') == null;

    locator.registerLazySingleton<AuthTokenStore>(() => AuthTokenStore());
    locator.registerLazySingleton<AuthService>(
      () => useMockAuth
          ? const MockAuthService()
          : AuthApiService(
              apiClient: locator<DioApiClient>(),
              tokenStore: locator<AuthTokenStore>(),
            ),
    );
    locator.registerLazySingleton<GoogleSignInService>(
      () => GoogleSignInServiceImpl(
        clientId: envValue('GOOGLE_CLIENT_ID'),
        serverClientId: envValue('GOOGLE_SERVER_CLIENT_ID'),
      ),
    );
    locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        service: locator<AuthService>(),
        googleService: locator<GoogleSignInService>(),
        tokenStore: locator<AuthTokenStore>(),
        preferences: locator<Preferences>(),
      ),
    );
  }
}
