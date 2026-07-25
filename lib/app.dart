import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/app_dependencies.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/auth/bloc/auth_cubit.dart';
import 'ui/features/home/bloc/home_cubit.dart';

class KhelamApp extends StatelessWidget {
  const KhelamApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<AuthCubit>.value(value: dependencies.authCubit),
        BlocProvider<HomeCubit>.value(value: dependencies.homeCubit),
      ],
      child: MaterialApp.router(
        title: 'Khelam Flutter Template',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: dependencies.appRouter.router,
      ),
    );
  }
}
