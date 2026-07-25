import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/data/services/dio_api_client.dart';

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
  });
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
