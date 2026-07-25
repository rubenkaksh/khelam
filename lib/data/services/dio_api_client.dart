import 'package:dio/dio.dart';

class DioApiClient {
  DioApiClient({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Dio get raw => _dio;

  void setBearerToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final Response<dynamic> response = await _dio.get<dynamic>(path);
    final Object? data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiClientException('Expected JSON object response.');
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;
}
