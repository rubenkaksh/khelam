import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_cubit.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/booking/bloc/schedule_cubit.dart';
import '../../features/booking/bloc/turf_selection_cubit.dart';
import '../../features/booking/views/schedule_view.dart';
import '../../features/booking/views/turf_selection_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/theme_preview/views/theme_preview_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({
    required bool Function() isAuthenticated,
    required AuthCubit Function() authCubit,
    required ScheduleCubit Function(String turfId) scheduleCubit,
    required TurfSelectionCubit Function() turfSelectionCubit,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _isAuthenticated = isAuthenticated,
       _authCubit = authCubit,
       _scheduleCubit = scheduleCubit,
       _turfSelectionCubit = turfSelectionCubit,
       _navigatorKey = navigatorKey;

  final bool Function() _isAuthenticated;
  final AuthCubit Function() _authCubit;
  final ScheduleCubit Function(String turfId) _scheduleCubit;
  final TurfSelectionCubit Function() _turfSelectionCubit;
  final GlobalKey<NavigatorState>? _navigatorKey;

  late final GoRouter router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: AppRoutes.turfSelectionPath,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _isAuthenticated();
      // Turf selection, schedule, login and registration stay public: anyone
      // can pick a turf, browse the schedule, or sign up; booking and home
      // require authentication.
      final bool isPublic =
          state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.turfSelectionPath ||
          state.matchedLocation == AppRoutes.schedulePath ||
          state.matchedLocation == AppRoutes.registerPath;

      if (!loggedIn && !isPublic) {
        return AppRoutes.loginPath;
      }

      // The schedule needs a turf id to load; deep-linking /schedule without
      // one bounces back to the turf-selection screen.
      if (state.matchedLocation == AppRoutes.schedulePath &&
          state.uri.queryParameters['turfId'] == null) {
        return AppRoutes.turfSelectionPath;
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
        path: AppRoutes.turfSelectionPath,
        name: AppRoutes.turfSelection,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<TurfSelectionCubit>(
            create: (BuildContext context) => _turfSelectionCubit(),
            child: const TurfSelectionView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.schedulePath,
        name: AppRoutes.schedule,
        builder: (BuildContext context, GoRouterState state) {
          final String? turfId = state.uri.queryParameters['turfId'];
          // The redirect guard above routes here only with a turf id; the
          // fallback keeps the screen safe if one ever slips through.
          if (turfId == null) {
            return BlocProvider<TurfSelectionCubit>(
              create: (BuildContext context) => _turfSelectionCubit(),
              child: const TurfSelectionView(),
            );
          }
          return BlocProvider<ScheduleCubit>(
            create: (BuildContext context) => _scheduleCubit(turfId),
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
