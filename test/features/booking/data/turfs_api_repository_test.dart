import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

import 'package:khelam/features/booking/data/mock_turfs_repository.dart';
import 'package:khelam/features/booking/data/turfs_api_repository.dart';

void main() {
  group('TurfsApiRepository', () {
    test('falls back to the two known turfs while GET /turfs is missing', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _ThrowingAdapter.failure(
        statusCode: 404,
      );
      final TurfsApiRepository repository = _repository(dio);

      // The 404 maps to an AppClientException; only that case serves the
      // known turfs (endpoint not shipped yet).
      final turfs = await repository.getTurfs();

      expect(turfs, hasLength(2));
      expect(turfs.first.id, MockTurfsRepository.firstTurfId);
      expect(turfs.last.id, MockTurfsRepository.secondTurfId);
    });

    test('propagates offline failures instead of serving stale dummy data', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _ThrowingAdapter.failure(
        type: DioExceptionType.connectionError,
      );
      final TurfsApiRepository repository = _repository(dio);

      await expectLater(
        () => repository.getTurfs(),
        throwsA(isA<AppOfflineException>()),
      );
    });

    test('propagates server failures instead of serving stale dummy data', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _ThrowingAdapter.failure(
        statusCode: 500,
      );
      final TurfsApiRepository repository = _repository(dio);

      await expectLater(
        () => repository.getTurfs(),
        throwsA(isA<AppServerException>()),
      );
    });
  });
}

TurfsApiRepository _repository(Dio dio) {
  return TurfsApiRepository(
    apiClient: DioApiClient(baseUrl: 'http://localhost', dio: dio),
  );
}

/// Adapter that always fails the request with the given dio error.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter({this.statusCode, this.type = DioExceptionType.badResponse});

  factory _ThrowingAdapter.failure({
    int? statusCode,
    DioExceptionType? type,
  }) {
    if (type != null) {
      return _ThrowingAdapter(type: type);
    }
    return _ThrowingAdapter(statusCode: statusCode);
  }

  final int? statusCode;
  final DioExceptionType type;

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
      type: type,
      response: type == DioExceptionType.badResponse
          ? Response<dynamic>(requestOptions: options, statusCode: statusCode)
          : null,
    );
  }
}
