import 'package:commons/commons.dart';

import '../models/turf_summary.dart';
import 'mock_turfs_repository.dart';
import 'turfs_repository.dart';

/// Real API implementation of [TurfsRepository] backed by the NestJS
/// `rms-futsal-backend`.
///
/// Endpoints:
/// - `GET /turfs` (not shipped yet — until it exists the call fails with an
///   [ApiClientException] and [getTurfs] falls back to the two known turfs,
///   the same dummy data `MockTurfsRepository` serves; booking's `getTurf`
///   uses the same TODO-until-endpoint pattern).
class TurfsApiRepository implements TurfsRepository {
  TurfsApiRepository({required DioApiClient apiClient})
    : _apiClient = apiClient;

  final DioApiClient _apiClient;

  @override
  Future<List<TurfSummary>> getTurfs() async {
    // TODO: drop the fallback once the real GET /turfs endpoint ships.
    try {
      final List<Map<String, dynamic>> jsonList = await _apiClient.getJsonList(
        '/turfs',
      );
      return jsonList.map(TurfSummary.fromJson).toList();
    } on Exception {
      // Any failure (404 today, network, malformed payload) keeps the app
      // usable with the two known turfs until the endpoint ships.
      return const <TurfSummary>[
        TurfSummary(
          id: MockTurfsRepository.firstTurfId,
          name: 'Turf A',
          address: 'Sector 12, Sports Complex',
        ),
        TurfSummary(
          id: MockTurfsRepository.secondTurfId,
          name: 'Turf B',
          address: 'Sector 7, Futsal Court',
        ),
      ];
    }
  }
}
