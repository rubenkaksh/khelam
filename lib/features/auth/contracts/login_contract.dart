import 'dart:async';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../ui/navigation/app_routes.dart';
import '../bloc/auth_cubit.dart';
import '../data/mock_auth_service.dart';

/// khelam's implementation of the commons [LoginStrings] contract.
class LoginStringsImpl implements LoginStrings {
  const LoginStringsImpl();

  @override
  String get appBarTitle => 'Khelam Login';

  @override
  String get subtitle => 'Sign in';

  @override
  String get description =>
      'Sign in with your phone number and password.';

  @override
  String get emailLabel => 'Phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get submitLabel => 'Sign in';

  @override
  String get googleSignInLabel => 'Continue with Google';

  @override
  String get fillDemoLabel => 'Fill demo credentials';

  @override
  String get registerLabel => 'Create an account';

  @override
  String get demoEmail => MockAuthService.demoEmail;

  @override
  String get demoPassword => MockAuthService.demoPassword;

  @override
  m.FormFieldValidator<String> get emailValidator => _validatePhone;

  @override
  m.FormFieldValidator<String> get passwordValidator => _validatePassword;

  /// The shared screen's first field carries the phone number (the backend's
  /// users login with phone + password).
  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Enter a phone number.';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number (10-15 digits).';
    }
    return null;
  }

  // The backend requires at least 6 characters (MinLength decorator).
  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Enter at least 6 characters.';
    }
    return null;
  }
}

/// Bridges the [AuthCubit] stream into the commons ValueNotifier contracts.
class LoginAsyncDataImpl implements LoginAsyncData {
  LoginAsyncDataImpl(AuthCubit cubit) {
    _subscription = cubit.stream.listen(_sync);
    _sync(cubit.state);
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  final m.ValueNotifier<bool> isLoading = m.ValueNotifier<bool>(false);

  @override
  final m.ValueNotifier<String?> errorMessage = m.ValueNotifier<String?>(null);

  @override
  final m.ValueNotifier<bool> isAuthenticated = m.ValueNotifier<bool>(false);

  void _sync(AuthState state) {
    isLoading.value = state.isLoading;
    errorMessage.value = state.errorMessage;
    if (state.isAuthenticated) {
      isAuthenticated.value = true;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    isLoading.dispose();
    errorMessage.dispose();
    isAuthenticated.dispose();
  }
}

/// App-owned behaviour: submit through the shared [AuthCubit] and navigate
/// to home once authenticated. Google sign-in is wired through the cubit's
/// [AuthCubit.googleSignIn].
class LoginServiceCallbacksImpl extends LoginServiceCallbacks {
  LoginServiceCallbacksImpl();

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await serviceLocator<AuthCubit>().login(email: email, password: password);
  }

  @override
  Future<void> googleSignIn() async {
    await serviceLocator<AuthCubit>().googleSignIn();
  }

  @override
  void navigateForward(m.BuildContext context) {
    context.goNamed(AppRoutes.home);
  }
}
