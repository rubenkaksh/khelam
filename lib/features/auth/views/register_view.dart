import 'package:commons/commons.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/navigation/app_routes.dart';
import '../bloc/auth_cubit.dart';

/// Registration screen: full name + phone number + password.
///
/// The backend auto-authenticates on register (the reply includes an
/// `accessToken`), so on success the screen navigates straight home — the
/// same post-auth behaviour as login.
class RegisterView extends m.StatefulWidget {
  const RegisterView({super.key});

  @override
  m.State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends m.State<RegisterView> {
  final m.GlobalKey<m.FormState> _formKey = m.GlobalKey<m.FormState>();
  final m.TextEditingController _nameController = m.TextEditingController();
  final m.TextEditingController _phoneController = m.TextEditingController();
  final m.TextEditingController _passwordController = m.TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final m.FormState? formState = _formKey.currentState;
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
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      appBar: m.AppBar(title: const m.Text('Khelam Registration')),
      body: m.SafeArea(
        child: m.Center(
          child: m.SingleChildScrollView(
            padding: const m.EdgeInsets.all(24),
            child: m.ConstrainedBox(
              constraints: const m.BoxConstraints(maxWidth: 440),
              child: m.Form(
                key: _formKey,
                child: m.Column(
                  crossAxisAlignment: m.CrossAxisAlignment.stretch,
                  children: <m.Widget>[
                    m.Text(
                      'Create your account',
                      style: m.Theme.of(context).textTheme.headlineMedium,
                    ),
                    const m.SizedBox(height: 8),
                    m.Text(
                      'Sign up with your phone number — no email needed.',
                      style: m.Theme.of(context).textTheme.bodyLarge,
                    ),
                    const m.SizedBox(height: 24),
                    TextInput(
                      label: 'Full name',
                      keyboardType: m.TextInputType.name,
                      textInputAction: m.TextInputAction.next,
                      controller: _nameController,
                      validator: _validateName,
                    ),
                    const m.SizedBox(height: 16),
                    TextInput(
                      label: 'Phone number',
                      keyboardType: m.TextInputType.phone,
                      textInputAction: m.TextInputAction.next,
                      controller: _phoneController,
                      validator: _validatePhone,
                    ),
                    const m.SizedBox(height: 16),
                    PasswordInput(
                      label: 'Password',
                      textInputAction: m.TextInputAction.done,
                      controller: _passwordController,
                      validator: _validatePassword,
                      onFieldSubmitted: (String _) => _onSubmit(),
                    ),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (m.BuildContext c, AuthState state) {
                        if (state.isAuthenticated) {
                          c.goNamed(AppRoutes.home);
                        }
                      },
                      builder: (m.BuildContext c, AuthState state) {
                        final String? message = state.errorMessage;
                        return m.Column(
                          children: <m.Widget>[
                            if (message != null) ...<m.Widget>[
                              m.Padding(
                                padding: const m.EdgeInsets.only(top: 16),
                                child: m.Text(
                                  message,
                                  style: m.TextStyle(
                                    color: m.Theme.of(c).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                            const m.SizedBox(height: 24),
                            FilledButton(
                              text: 'Create account',
                              icon: state.isLoading
                                  ? null
                                  : const m.Icon(m.Icons.person_add),
                              isLoading: state.isLoading,
                              onPressed: state.isLoading ? null : _onSubmit,
                            ),
                          ],
                        );
                      },
                    ),
                    const m.SizedBox(height: 12),
                    m.TextButton(
                      onPressed: () => context.goNamed(AppRoutes.login),
                      child: const m.Text('Already have an account? Sign in'),
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
