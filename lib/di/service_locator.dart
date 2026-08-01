import 'package:get_it/get_it.dart';

import 'package:commons/commons.dart';
import '../features/auth/bloc/auth_cubit.dart';
import '../features/auth/di/auth_dependencies.dart';
import '../features/booking/bloc/schedule_cubit.dart';
import '../features/booking/di/booking_dependencies.dart';
import '../ui/navigation/app_router.dart';
import 'env_config.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies({GetIt? getIt}) {
  final GetIt locator = getIt ?? serviceLocator;
  if (locator.isRegistered<AppRouter>()) {
    return;
  }

  // Shared infrastructure.
  locator.registerLazySingleton<DioApiClient>(
    () => DioApiClient(
      baseUrl: envValue('API_BASE_URL') ?? 'https://example.invalid',
    ),
  );

  // Per-feature registries (ADR-0003): each feature wires its own chain.
  AuthDependencies.register(locator);
  BookingDependencies.register(locator);

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(
      isAuthenticated: () => locator<AuthCubit>().state.isAuthenticated,
      authCubit: () => locator<AuthCubit>(),
      scheduleCubit: () => locator<ScheduleCubit>(),
    ),
  );
}
