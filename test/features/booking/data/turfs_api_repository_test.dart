import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commons/commons.dart';

import 'package:khelam/features/booking/data/turfs_api_repository.dart';

void main() {
  group('TurfsApiRepository', () {
    test('propagates a 404 as AppClientException (no dummy fallback)', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _ThrowingAdapter.failure(
        statusCode: 404,
      );
      final TurfsApiRepository repository = _repository(dio);

      // The real GET /turfs endpoint is the only source: a 404 surfaces the
      // typed client error instead of stale dummy turfs.
      await expectLater(
        () => repository.getTurfs(),
        throwsA(isA<AppClientException>()),
      );
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
