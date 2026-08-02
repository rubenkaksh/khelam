import 'package:dio/dio.dart';

import 'package:commons/commons.dart';

import '../auth_service.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'auth_exception.dart';
import 'auth_token_store.dart';

/// Real backend implementation of [AuthService] for the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `POST /auth/google` — exchange the Google idToken for `{accessToken,
///   user}`. On success the bearer token is attached to the shared
///   [DioApiClient], so protected endpoints (e.g. `POST /slots/:id/book`)
///   automatically send `Authorization: Bearer <accessToken>`.
///
/// Error mapping per the backend contract: 401 → invalid/expired Google
/// token, 400 → missing idToken.
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
  }) {
    // No /auth/login contract exists yet — only /auth/google.
    throw const AuthException(
      'Email/password login is not wired to the backend yet.',
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

    final Map<String, dynamic> json;
    try {
      json = await _apiClient.postJson(
        '/auth/google',
        body: <String, dynamic>{'idToken': idToken},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    final Object? accessToken = json['accessToken'];
    final Object? userJson = json['user'];
    if (accessToken is! String || userJson is! Map<String, dynamic>) {
      throw const AuthException('Unexpected /auth/google response shape.');
    }

    final AuthSession session = AuthSession(
      accessToken: accessToken,
      user: AuthUser.fromJson(userJson),
    );

    // Protected endpoints read the token from the shared client's headers.
    _apiClient.setBearerToken(session.accessToken);
    return session;
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

  AuthException _mapDioError(DioException e) {
    final int? statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const AuthException('Invalid or expired Google token.');
    }
    if (statusCode == 400) {
      return const AuthException('Missing idToken field.');
    }
    final String suffix = statusCode == null ? '' : ' (HTTP $statusCode)';
    return AuthException('Google sign-in failed$suffix.');
  }
}
