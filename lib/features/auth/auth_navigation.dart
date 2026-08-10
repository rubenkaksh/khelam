import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/navigation/app_routes.dart';

/// After a successful login/registration, return to the location the flow
/// started from (the `redirectTo` query parameter set by the booking guard)
/// or default to home.
///
/// The router's redirect guard re-evaluates on every navigation, so once the
/// cubit is authenticated the guarded destination passes.
void goAfterAuth(BuildContext context) {
  final GoRouterState state = GoRouterState.of(context);
  final String? redirectTo = state.uri.queryParameters['redirectTo'];
  if (redirectTo != null && redirectTo.isNotEmpty) {
    context.go(redirectTo);
    return;
  }
  context.goNamed(AppRoutes.home);
}
