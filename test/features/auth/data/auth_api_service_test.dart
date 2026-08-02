import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';
import 'package:khelam/features/auth/data/auth_api_service.dart';
import 'package:khelam/features/auth/data/auth_exception.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

void main() {
  group('AuthApiService', () {
    final Map<String, dynamic> sessionJson = <String, dynamic>{
      'accessToken': 'eyJhbGciOiJIUzI1NiJ9.token',
      'user': <String, dynamic>{
        'id': '5cd72062-2be5-4bb5-b115-2f3e98563b76',
        'full_name': 'Showshant',
        'email': 'showshant716@gmail.com',
        'avatar_url': 'https://lh3.googleusercontent.com/abc',
        'phone_number': null,
        'is_active': true,
        'created_at': '2026-07-31T08:32:47.975Z',
        'updated_at': '2026-07-31T08:32:47.975Z',
      },
    };

    test('googleLogin POSTs the idToken and parses the session', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(sessionJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      final AuthSession session = await service.googleLogin(
        _googleResult(idToken: 'google-id-token'),
      );

      final RequestOptions? request = adapter.lastRequest;
      expect(request?.method, 'POST');
      expect(request?.path, '/auth/google');
      expect(request?.data, <String, dynamic>{'idToken': 'google-id-token'});

      expect(session.accessToken, 'eyJhbGciOiJIUzI1NiJ9.token');
      expect(session.user.id, '5cd72062-2be5-4bb5-b115-2f3e98563b76');
      expect(session.user.displayName, 'Showshant');
      expect(session.user.email, 'showshant716@gmail.com');
      expect(session.user.avatarUrl, 'https://lh3.googleusercontent.com/abc');
      expect(session.user.isActive, isTrue);
    });

    test('googleLogin attaches the bearer token to the shared client', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(sessionJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      await service.googleLogin(_googleResult(idToken: 'google-id-token'));

      // A follow-up request through the same client carries the header.
      await apiClient.getJson('/slots');
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer eyJhbGciOiJIUzI1NiJ9.token',
      );
    });

    test('googleLogin maps 401 to an invalid-token message', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(
          <String, dynamic>{'message': 'Invalid Google token'},
          statusCode: 401,
        ),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.googleLogin(_googleResult(idToken: 'bad-token')),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Invalid or expired Google token.',
          ),
        ),
      );
    });

    test('googleLogin maps 400 to a missing-idToken message', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(
          <String, dynamic>{'message': 'Missing idToken field'},
          statusCode: 400,
        ),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.googleLogin(_googleResult(idToken: 'x')),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Missing idToken field.',
          ),
        ),
      );
    });

    test('googleLogin rejects a result without an idToken', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(sessionJson),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.googleLogin(_googleResult(idToken: null)),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('GOOGLE_SERVER_CLIENT_ID'),
          ),
        ),
      );
    });

    test('init restores the stored session and re-attaches the token', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(sessionJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      // A previous sign-in persisted a session.
      final AuthSession stored = await service.googleLogin(
        _googleResult(idToken: 'google-id-token'),
      );
      final AuthTokenStore tokenStore = _tokenStore();
      await tokenStore.saveSession(stored);

      final AuthUser? restored = await AuthApiService(
        apiClient: apiClient,
        tokenStore: tokenStore,
      ).init();

      expect(restored?.email, 'showshant716@gmail.com');
      await apiClient.getJson('/slots');
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer ${stored.accessToken}',
      );
    });

    test('init returns null when no session was stored', () async {
      final AuthApiService service = _service(
        _apiClient(_RecordingAdapter((RequestOptions options) async {
          return _jsonResponse(<String, dynamic>{});
        })),
      );

      final AuthUser? restored = await service.init();

      expect(restored, isNull);
    });
  });
}

AuthApiService _service(DioApiClient apiClient) {
  return AuthApiService(apiClient: apiClient, tokenStore: _tokenStore());
}

AuthTokenStore _tokenStore() {
  // In-memory fake storage so no platform channel is touched.
  return AuthTokenStore(storage: _FakeSecureStorage());
}

DioApiClient _apiClient(_RecordingAdapter adapter) {
  final Dio dio = Dio()..httpClientAdapter = adapter;
  return DioApiClient(baseUrl: 'https://example.test', dio: dio);
}

GoogleSignInResult _googleResult({required String? idToken}) {
  return GoogleSignInResult(
    email: 'showshant716@gmail.com',
    displayName: 'Showshant',
    idToken: idToken,
  );
}

ResponseBody _jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastRequest = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Minimal in-memory [FlutterSecureStorage] stand-in for tests.
class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }
}
