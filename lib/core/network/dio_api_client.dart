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
    return _expectObject(response.data);
  }

  /// GET a JSON array of objects, e.g. list endpoints.
  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final Object? data = response.data;
      if (data is List) {
        final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
        for (final Object? item in data) {
          if (item is Map<String, dynamic>) {
            items.add(item);
          } else {
            throw const ApiClientException('Expected JSON array of objects.');
          }
        }
        return items;
      }
      throw const ApiClientException('Expected JSON array response.');
    } catch (e) {
      throw ApiClientException('Error getting JSON list: $e');
    }
  }

  /// POST a JSON body and return the JSON object response.
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      path,
      data: body,
    );
    return _expectObject(response.data);
  }

  Map<String, dynamic> _expectObject(Object? data) {
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
