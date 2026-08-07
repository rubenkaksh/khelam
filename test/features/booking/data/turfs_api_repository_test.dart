import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

import 'package:khelam/features/booking/data/mock_turfs_repository.dart';
import 'package:khelam/features/booking/data/turfs_api_repository.dart';

/// Always fails with a 404 — stands in for the not-yet-shipped GET /turfs
/// endpoint.
class _NotFoundAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(requestOptions: options, statusCode: 404),
    );
  }
}

void main() {
  group('TurfsApiRepository', () {
    test('falls back to the two known turfs while GET /turfs is missing', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _NotFoundAdapter();
      final TurfsApiRepository repository = TurfsApiRepository(
        apiClient: DioApiClient(baseUrl: 'http://localhost', dio: dio),
      );

      // The 404 surfaces as an ApiClientException from getJsonList; the
      // repository catches any Exception and serves the known turfs.
      final turfs = await repository.getTurfs();

      expect(turfs, hasLength(2));
      expect(turfs.first.id, MockTurfsRepository.firstTurfId);
      expect(turfs.last.id, MockTurfsRepository.secondTurfId);
    });
  });
}
