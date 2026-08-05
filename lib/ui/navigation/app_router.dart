import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/booking/bloc/schedule_cubit.dart';
import '../../features/booking/views/schedule_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/theme_preview/views/theme_preview_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({
    required bool Function() isAuthenticated,
    required AuthCubit Function() authCubit,
    required ScheduleCubit Function() scheduleCubit,
  }) : _isAuthenticated = isAuthenticated,
       _authCubit = authCubit,
       _scheduleCubit = scheduleCubit;

  final bool Function() _isAuthenticated;
  final AuthCubit Function() _authCubit;
  final ScheduleCubit Function() _scheduleCubit;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.schedulePath,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _isAuthenticated();
      // Schedule, login and registration stay public: anyone can browse the
      // schedule or sign up; booking and home require authentication.
      final bool isPublic =
          state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.schedulePath ||
          state.matchedLocation == AppRoutes.registerPath;

      if (!loggedIn && !isPublic) {
        return AppRoutes.loginPath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<AuthCubit>.value(
            value: _authCubit(),
            child: const LoginView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<AuthCubit>.value(
            value: _authCubit(),
            child: const RegisterView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeView();
        },
      ),
      GoRoute(
        path: AppRoutes.schedulePath,
        name: AppRoutes.schedule,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<ScheduleCubit>(
            create: (BuildContext context) => _scheduleCubit(),
            child: const ScheduleView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.themePreviewPath,
        name: AppRoutes.themePreview,
        builder: (BuildContext context, GoRouterState state) {
          final Brightness brightness = switch (state.extra) {
            final Brightness b => b,
            _ => Theme.of(context).brightness,
          };
          return ThemePreviewView(brightness: brightness);
        },
      ),
    ],
  );
}
