import 'package:commons/commons.dart';
import 'package:get_it/get_it.dart';

import '../../../di/env_config.dart';
import '../auth_service.dart';
import '../bloc/auth_cubit.dart';
import '../data/mock_auth_service.dart';

abstract final class AuthDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<AuthService>(() => const MockAuthService());
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
      ),
    );
  }
}
