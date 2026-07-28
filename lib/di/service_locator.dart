import 'package:get_it/get_it.dart';

import '../ui/features/auth/bloc/auth_cubit.dart';
import '../ui/features/auth/di/auth_dependencies.dart';
import '../ui/features/home/di/home_dependencies.dart';
import '../ui/features/schedule/di/schedule_dependencies.dart';
import '../ui/navigation/app_router.dart';
import 'data_dependencies.dart';

final GetIt serviceLocator = GetIt.instance;

void configureDependencies({GetIt? getIt}) {
  final GetIt locator = getIt ?? serviceLocator;
  if (locator.isRegistered<AppRouter>()) {
    return;
  }

  AuthDependencies.register(locator);
  HomeDependencies.register(locator);
  ScheduleDependencies.register(locator);
  DataDependencies.register(locator);

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(isAuthenticated: () => locator<AuthCubit>().state.isAuthenticated),
  );
}
