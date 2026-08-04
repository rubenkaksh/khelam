import 'package:dio/dio.dart';

import 'package:commons/commons.dart';

import '../auth_service.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_exception.dart';
import 'auth_token_store.dart';

/// The flow that produced a failed backend call, so error mapping can speak
/// the right language (Google-specific vs phone-specific).
enum _AuthFlow { google, login, register }

/// Real backend implementation of [AuthService] for the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `POST /auth/google` — exchange the Google idToken for `{accessToken,
///   user}`.
/// - `POST /auth/users/login` — phone-number login → `{accessToken, user}`.
/// - `POST /auth/users/register` — create account + auto-login →
///   `{accessToken, user}`.
///
/// On success the bearer token is attached to the shared [DioApiClient], so
/// protected endpoints (e.g. `POST /slots/:id/book`) automatically send
/// `Authorization: Bearer <accessToken>`.
///
/// Error mapping per the backend contract: 409 → phone number already
/// registered (register), 401 → invalid credentials (login/Google), 400 →
/// validation failure.
class AuthApiService implements AuthService {
  AuthApiService({required DioApiClient apiClient, required AuthTokenStore tokenStore})
    : _apiClient = apiClient,
      _tokenStore = tokenStore;

  final DioApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // The shared login screen's first field is the phone number; the legacy
    // entry point delegates to the real phone login.
    final AuthSession session = await phoneLogin(
      phoneNumber: email,
      password: password,
    );
    return session.user;
  }

  @override
  Future<AuthSession> phoneLogin({
    required String phoneNumber,
    required String password,
  }) {
    return _exchange(
      '/auth/users/login',
      body: <String, dynamic>{
        'phoneNumber': phoneNumber,
        'password': password,
      },
      flow: _AuthFlow.login,
    );
  }

  @override
  Future<AuthSession> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) {
    return _exchange(
      '/auth/users/register',
      body: <String, dynamic>{
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'password': password,
      },
      flow: _AuthFlow.register,
    );
  }

  @override
  Future<AuthSession> googleLogin(GoogleSignInResult result) async {
    final String? idToken = result.idToken;
    if (idToken == null) {
      throw const AuthException(
        'Google sign-in returned no ID token (is GOOGLE_SERVER_CLIENT_ID set?).',
      );
    }
    return _exchange(
      '/auth/google',
      body: <String, dynamic>{'idToken': idToken},
      flow: _AuthFlow.google,
    );
  }

  @override
  Future<AuthUser?> init() async {
    final AuthSession? session = await _tokenStore.restoreSession();
    if (session == null) {
      return null;
    }
    _apiClient.setBearerToken(session.accessToken);
    return session.user;
  }

  /// POSTs [body] to [path], parses the backend's `{accessToken, user}`
  /// response into an [AuthSession] and attaches the bearer token to the
  /// shared client.
  Future<AuthSession> _exchange(
    String path, {
    required Map<String, dynamic> body,
    required _AuthFlow flow,
  }) async {
    final Map<String, dynamic> json;
    try {
      json = await _apiClient.postJson(path, body: body);
    } on DioException catch (e) {
      throw _mapDioError(e, flow: flow);
    }

    final Object? accessToken = json['accessToken'];
    final Object? userJson = json['user'];
    if (accessToken is! String || userJson is! Map<String, dynamic>) {
      throw AuthException('Unexpected $path response shape.');
    }

    final AuthSession session = AuthSession(
      accessToken: accessToken,
      user: AuthUser.fromJson(userJson),
    );

    // Protected endpoints read the token from the shared client's headers.
    _apiClient.setBearerToken(session.accessToken);
    return session;
  }

  AuthException _mapDioError(DioException e, {required _AuthFlow flow}) {
    final int? statusCode = e.response?.statusCode;
    final String suffix = statusCode == null ? '' : ' (HTTP $statusCode)';
    switch (flow) {
      case _AuthFlow.google:
        if (statusCode == 401) {
          return const AuthException('Invalid or expired Google token.');
        }
        if (statusCode == 400) {
          return const AuthException('Missing idToken field.');
        }
        return AuthException('Google sign-in failed$suffix.');
      case _AuthFlow.login:
        if (statusCode == 401 || statusCode == 400) {
          return const AuthException('Invalid phone number or password.');
        }
        return AuthException('Login failed$suffix.');
      case _AuthFlow.register:
        if (statusCode == 409) {
          return const AuthException('Phone number already registered.');
        }
        if (statusCode == 400) {
          final Map<String, dynamic>? data = e.response?.data;
          final Object? message = data is Map<String, dynamic>
              ? data['message']
              : null;
          if (message is String && message.isNotEmpty) {
            return AuthException(message);
          }
          return const AuthException('Invalid registration details.');
        }
        return AuthException('Registration failed$suffix.');
    }
  }
}