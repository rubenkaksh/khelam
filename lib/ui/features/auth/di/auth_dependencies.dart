import 'package:get_it/get_it.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/mock_auth_service.dart';
import '../../../../domain/repositories/auth_service.dart';
import '../bloc/auth_cubit.dart';

abstract final class AuthDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<AuthService>(
      () => const MockAuthService(),
    );
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(service: locator<AuthService>()),
    );
    locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(repository: locator<AuthRepository>()),
    );
  }
}
