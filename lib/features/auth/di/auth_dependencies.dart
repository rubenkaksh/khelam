import 'package:get_it/get_it.dart';

import '../auth_service.dart';
import '../bloc/auth_cubit.dart';
import '../data/mock_auth_service.dart';

abstract final class AuthDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<AuthService>(() => const MockAuthService());
    locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(service: locator<AuthService>()),
    );
  }
}
