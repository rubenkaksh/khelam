import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/views/login_view.dart';
import '../features/home/views/home_view.dart';
import '../features/schedule/views/schedule_view.dart';
import '../features/theme_preview/views/theme_preview_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({required bool Function() isAuthenticated})
    : _isAuthenticated = isAuthenticated;

  final bool Function() _isAuthenticated;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.schedulePath,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _isAuthenticated();
      final bool isPublic = state.matchedLocation == AppRoutes.loginPath ||
          state.matchedLocation == AppRoutes.schedulePath;

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
          return const LoginView();
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
          return const ScheduleView();
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
