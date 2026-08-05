import 'package:commons/commons.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/navigation/app_routes.dart';
import '../bloc/auth_cubit.dart';
import '../contracts/login_contract.dart';

/// Thin app-side wrapper: owns the [LoginAsyncDataImpl] lifecycle and feeds
/// the contract implementations into the shared commons [LoginScreen].
class LoginView extends m.StatefulWidget {
  const LoginView({super.key});

  @override
  m.State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends m.State<LoginView> {
  late final LoginAsyncDataImpl _asyncData;

  @override
  void initState() {
    super.initState();
    _asyncData = LoginAsyncDataImpl(context.read<AuthCubit>());
  }

  @override
  void dispose() {
    _asyncData.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    return LoginScreen(
      displayTexts: const LoginStringsImpl(),
      asyncData: _asyncData,
      callbacks: LoginServiceCallbacksImpl(),
      // Google sign-in is on hold; the phone + password flow is the entry
      // for now (see LoginServiceCallbacksImpl.login → phone login).
      enableGoogleSignIn: false,
      // Registration lives app-side; the shared screen just hops to it.
      // Carry the query params (e.g. redirectTo from the booking guard) so
      // registering lands the user back where they started too.
      onRegisterTap: () => context.goNamed(
        AppRoutes.register,
        queryParameters: GoRouterState.of(context).uri.queryParameters,
      ),
    );
  }
}
