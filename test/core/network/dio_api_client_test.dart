import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/core/network/dio_api_client.dart';

void main() {
  group('DioApiClient', () {
    test('sets and clears bearer token header', () {
      final Dio dio = Dio();
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      client.setBearerToken('abc123');
      expect(dio.options.headers['Authorization'], 'Bearer abc123');

      client.setBearerToken(null);
      expect(dio.options.headers.containsKey('Authorization'), isFalse);
    });

    test('returns JSON object responses', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _StaticJsonAdapter(<String, dynamic>{
          'status': 'ok',
          'healthy': true,
        });
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      final Map<String, dynamic> json = await client.getJson('/status');

      expect(json['status'], 'ok');
      expect(json['healthy'], isTrue);
    });

    test(
      'getJsonList sends query parameters and returns a list of objects',
      () async {
        final _RecordingJsonAdapter adapter = _RecordingJsonAdapter((
          RequestOptions options,
        ) async {
          expect(options.path, '/slots');
          expect(options.queryParameters['turfId'], 'turf-1');
          expect(options.queryParameters['date'], '2026-07-31');
          return _jsonResponse(<dynamic>[
            <String, dynamic>{'id': 's1'},
            <String, dynamic>{'id': 's2'},
          ]);
        });
        final Dio dio = Dio()..httpClientAdapter = adapter;
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        final List<Map<String, dynamic>> items = await client.getJsonList(
          '/slots',
          queryParameters: <String, dynamic>{
            'turfId': 'turf-1',
            'date': '2026-07-31',
          },
        );

        expect(items, hasLength(2));
        expect(items.first['id'], 's1');
      },
    );

    test(
      'getJsonList throws ApiClientException when response is not a list',
      () async {
        final Dio dio = Dio()
          ..httpClientAdapter = _StaticJsonAdapter(<String, dynamic>{
            'status': 'ok',
          });
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        expect(
          () => client.getJsonList('/slots'),
          throwsA(isA<ApiClientException>()),
        );
      },
    );

    test(
      'postJson sends the body and returns the JSON object response',
      () async {
        final _RecordingJsonAdapter adapter = _RecordingJsonAdapter((
          RequestOptions options,
        ) async {
          expect(options.method, 'POST');
          expect(options.path, '/slots/s1/book');
          expect(options.data, <String, dynamic>{
            'customerPhone': '9876543210',
          });
          return _jsonResponse(<String, dynamic>{
            'booking': <String, dynamic>{'id': 'b1'},
            'slot': <String, dynamic>{'id': 's1', 'status': 'booked'},
          });
        });
        final Dio dio = Dio()..httpClientAdapter = adapter;
        final DioApiClient client = DioApiClient(
          baseUrl: 'https://example.test',
          dio: dio,
        );

        final Map<String, dynamic> json = await client.postJson(
          '/slots/s1/book',
          body: <String, dynamic>{'customerPhone': '9876543210'},
        );

        expect(json['booking'], <String, dynamic>{'id': 'b1'});
        expect(json['slot'], <String, dynamic>{'id': 's1', 'status': 'booked'});
      },
    );

    test('getJson rethrows DioException on non-2xx responses', () async {
      final Dio dio = Dio()
        ..httpClientAdapter = _RecordingJsonAdapter(
          (RequestOptions options) async => ResponseBody.fromString(
            'Unauthorized',
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          ),
        );
      final DioApiClient client = DioApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
      );

      expect(() => client.getJson('/slots'), throwsA(isA<DioException>()));
    });
  });
}

ResponseBody _jsonResponse(Object? body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

/// Adapter that lets each test decide the response for the request and keeps
/// the last [RequestOptions] for assertions.
class _RecordingJsonAdapter implements HttpClientAdapter {
  _RecordingJsonAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

class _StaticJsonAdapter implements HttpClientAdapter {
  const _StaticJsonAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
