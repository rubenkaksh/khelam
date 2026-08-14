import 'package:dio/dio.dart';

import 'package:commons/commons.dart';

import '../models/turf_summary.dart';
import 'turfs_repository.dart';

/// Real API implementation of [TurfsRepository] backed by the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `GET /turfs` (public)
class TurfsApiRepository implements TurfsRepository {
  TurfsApiRepository({required DioApiClient apiClient})
    : _apiClient = apiClient;

  final DioApiClient _apiClient;

  @override
  Future<List<TurfSummary>> getTurfs() async {
    try {
      final List<Map<String, dynamic>> jsonList = await _apiClient.getJsonList(
        '/turfs',
      );
      return jsonList.map(TurfSummary.fromJson).toList();
    } on DioException catch (e) {
      throw _apiClient.mapDioException(e);
    }
  }
}
