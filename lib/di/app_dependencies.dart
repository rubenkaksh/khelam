import 'package:get_it/get_it.dart';

import '../ui/features/auth/bloc/auth_cubit.dart';
import '../ui/features/home/bloc/home_cubit.dart';
import '../ui/features/schedule/bloc/schedule_cubit.dart';
import '../ui/navigation/app_router.dart';
import 'service_locator.dart';

class AppDependencies {
  AppDependencies._({
    required this.appRouter,
    required this.authCubit,
    required this.homeCubit,
    required this.scheduleCubit,
  });

  factory AppDependencies.create({GetIt? getIt}) {
    final GetIt locator = getIt ?? serviceLocator;
    configureDependencies(getIt: locator);

    return AppDependencies._(
      appRouter: locator<AppRouter>(),
      authCubit: locator<AuthCubit>(),
      homeCubit: locator<HomeCubit>(),
      scheduleCubit: locator<ScheduleCubit>(),
    );
  }

  final AppRouter appRouter;
  final AuthCubit authCubit;
  final HomeCubit homeCubit;
  final ScheduleCubit scheduleCubit;
}
