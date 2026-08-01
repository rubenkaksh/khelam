import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_service.dart';
import '../models/auth_user.dart';

enum AuthStatus { initial, loading, authenticated, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthService service})
    : _service = service,
      super(const AuthState());

  final AuthService _service;

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final AuthUser user = await _service.login(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Use demo@khelam.dev and password123.',
        ),
      );
    }
  }
}
