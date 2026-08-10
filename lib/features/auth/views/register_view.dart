import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/navigation/app_routes.dart';
import '../auth_navigation.dart';
import '../bloc/auth_cubit.dart';

/// Registration screen: full name + phone number + password.
///
/// The backend auto-authenticates on register (the reply includes an
/// `accessToken`), so on success the screen navigates straight home — the
/// same post-auth behaviour as login.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    await context.read<AuthCubit>().register(
      phoneNumber: _phoneController.text.trim(),
      fullName: _nameController.text.trim(),
      password: _passwordController.text,
    );
  }

  String? _validateName(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter your full name.';
    }
    return null;
  }

  /// Mirrors the backend contract: 10–15 digits, optional leading `+`.
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

  /// The backend requires at least 6 characters (MinLength decorator).
  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Enter at least 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khelam Registration')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up with your phone number — no email needed.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextInput(
                      label: 'Full name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      controller: _nameController,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextInput(
                      label: 'Phone number',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      controller: _phoneController,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    PasswordInput(
                      label: 'Password',
                      textInputAction: TextInputAction.done,
                      controller: _passwordController,
                      validator: _validatePassword,
                      onFieldSubmitted: (String _) => _onSubmit(),
                    ),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (BuildContext c, AuthState state) {
                        if (state.isAuthenticated) {
                          // Registration auto-authenticates: return to where
                          // the flow started (booking guard) or go home.
                          goAfterAuth(c);
                        }
                      },
                      builder: (BuildContext c, AuthState state) {
                        final String? message = state.errorMessage;
                        return Column(
                          children: <Widget>[
                            if (message != null) ...<Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color: Theme.of(c).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            AppFilledButton(
                              text: 'Create account',
                              icon: state.isLoading
                                  ? null
                                  : const Icon(Icons.person_add),
                              isLoading: state.isLoading,
                              onPressed: state.isLoading ? null : _onSubmit,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.goNamed(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
