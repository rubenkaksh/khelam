import 'package:commons/commons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_service.dart';
import '../data/auth_token_store.dart';
import '../models/auth_session.dart';
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
  AuthCubit({
    required AuthService service,
    required GoogleSignInService googleService,
    required AuthTokenStore tokenStore,
  }) : _service = service,
       _googleService = googleService,
       _tokenStore = tokenStore,
       super(const AuthState());

  final AuthService _service;
  final GoogleSignInService _googleService;
  final AuthTokenStore _tokenStore;

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
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Signs in with Google. A canceled flow returns to the initial state
  /// silently; any other failure surfaces as an error message.
  ///
  /// The backend exchange happens via [AuthService.googleLogin]; the
  /// resulting session is persisted so the token survives app restarts.
  Future<void> googleSignIn() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final GoogleSignInResult? result = await _googleService.signIn();
      if (result == null) {
        emit(state.copyWith(status: AuthStatus.initial, clearError: true));
        return;
      }
      final AuthSession session = await _service.googleLogin(result);
      await _tokenStore.saveSession(session);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Marks the session as restored from secure storage at app launch.
  void restoreSession(AuthUser user) {
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      ),
    );
  }
}
