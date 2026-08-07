import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';
import 'package:khelam/features/auth/data/auth_api_service.dart';
import 'package:khelam/features/auth/data/auth_exception.dart';
import 'package:khelam/features/auth/data/auth_token_store.dart';
import 'package:khelam/features/auth/models/auth_session.dart';
import 'package:khelam/features/auth/models/auth_user.dart';

import '../../../helpers/fake_secure_storage.dart';

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

  group('AuthApiService.phoneLogin', () {
    final Map<String, dynamic> phoneSessionJson = <String, dynamic>{
      'accessToken': 'phone-token',
      'user': <String, dynamic>{
        'id': 'u-phone-1',
        'full_name': 'Phone Player',
        'email': null,
        'avatar_url': null,
        'phone_number': '9801237986',
        'is_active': true,
        'created_at': '2026-08-03T09:54:11.902Z',
        'updated_at': '2026-08-03T09:54:11.902Z',
      },
    };

    test('POSTs phone credentials and parses the session', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(phoneSessionJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      final AuthSession session = await service.phoneLogin(
        phoneNumber: '9801237986',
        password: 'lovesainju',
      );

      final RequestOptions? request = adapter.lastRequest;
      expect(request?.method, 'POST');
      expect(request?.path, '/auth/users/login');
      expect(
        request?.data,
        <String, dynamic>{
          'phoneNumber': '9801237986',
          'password': 'lovesainju',
        },
      );
      expect(session.accessToken, 'phone-token');
      expect(session.user.id, 'u-phone-1');
      expect(session.user.phoneNumber, '9801237986');
      expect(session.user.displayName, 'Phone Player');
    });

    test('attaches the bearer token to the shared client', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(phoneSessionJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      await service.phoneLogin(phoneNumber: '9801237986', password: 'x');

      // A follow-up request through the same client carries the header.
      await apiClient.getJson('/slots');
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer phone-token',
      );
    });

    test('maps 401 to an invalid-credentials message', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(
          <String, dynamic>{'message': 'Invalid credentials'},
          statusCode: 401,
        ),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.phoneLogin(phoneNumber: '9801237986', password: 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Invalid phone number or password.',
          ),
        ),
      );
    });
  });

  group('AuthApiService.register', () {
    final Map<String, dynamic> registeredJson = <String, dynamic>{
      'accessToken': 'reg-token',
      'user': <String, dynamic>{
        'id': 'u-reg-1',
        'full_name': 'New Player',
        'email': null,
        'avatar_url': null,
        'phone_number': '9800000001',
        'is_active': true,
        'created_at': '2026-08-03T09:54:11.902Z',
        'updated_at': '2026-08-03T09:54:11.902Z',
      },
    };

    test('POSTs the registration payload and parses the session', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(registeredJson),
      );
      final DioApiClient apiClient = _apiClient(adapter);
      final AuthApiService service = _service(apiClient);

      final AuthSession session = await service.register(
        phoneNumber: '9800000001',
        fullName: 'New Player',
        password: 'khelam123',
      );

      final RequestOptions? request = adapter.lastRequest;
      expect(request?.method, 'POST');
      expect(request?.path, '/auth/users/register');
      expect(
        request?.data,
        <String, dynamic>{
          'phoneNumber': '9800000001',
          'fullName': 'New Player',
          'password': 'khelam123',
        },
      );
      expect(session.accessToken, 'reg-token');
      expect(session.user.displayName, 'New Player');
      expect(session.user.phoneNumber, '9800000001');
    });

    test('maps 409 to an already-registered message', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(
          <String, dynamic>{'message': 'Phone number already registered'},
          statusCode: 409,
        ),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.register(
          phoneNumber: '9800000001',
          fullName: 'New Player',
          password: 'khelam123',
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Phone number already registered.',
          ),
        ),
      );
    });

    test('surfaces the backend message on 400', () async {
      final _RecordingAdapter adapter = _RecordingAdapter(
        (RequestOptions options) async => _jsonResponse(
          <String, dynamic>{'message': 'Invalid phone number'},
          statusCode: 400,
        ),
      );
      final AuthApiService service = _service(_apiClient(adapter));

      expect(
        () => service.register(
          phoneNumber: 'abc',
          fullName: 'New Player',
          password: 'khelam123',
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            'Invalid phone number',
          ),
        ),
      );
    });
  });
}

AuthApiService _service(DioApiClient apiClient) {
  return AuthApiService(apiClient: apiClient, tokenStore: _tokenStore());
}

AuthTokenStore _tokenStore() {
  // In-memory fake storage so no platform channel is touched.
  return AuthTokenStore(storage: FakeSecureStorage());
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
