import 'package:get_it/get_it.dart';

import '../ui/features/auth/bloc/auth_cubit.dart';
import '../ui/features/home/bloc/home_cubit.dart';
import '../ui/navigation/app_router.dart';
import 'service_locator.dart';

class AppDependencies {
  AppDependencies._({
    required this.appRouter,
    required this.authCubit,
    required this.homeCubit,
  });

  factory AppDependencies.create({GetIt? getIt}) {
    final GetIt locator = getIt ?? serviceLocator;
    configureDependencies(getIt: locator);

    return AppDependencies._(
      appRouter: locator<AppRouter>(),
      authCubit: locator<AuthCubit>(),
      homeCubit: locator<HomeCubit>(),
    );
  }

  final AppRouter appRouter;
  final AuthCubit authCubit;
  final HomeCubit homeCubit;
}
