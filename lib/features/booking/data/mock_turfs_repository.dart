import '../models/turf_summary.dart';
import 'turfs_repository.dart';

/// Returns the two known turfs. Serves as the dev/mock-mode data source
/// (see booking_dependencies) — the real [TurfsApiRepository] talks only to
/// the backend `GET /turfs` endpoint.
class MockTurfsRepository implements TurfsRepository {
  MockTurfsRepository();

  static const String firstTurfId = '44444444-4444-4444-4444-444444444441';
  static const String secondTurfId = '2f293756-5cc8-41a4-be78-89e13c2d2ea6';

  @override
  Future<List<TurfSummary>> getTurfs() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const <TurfSummary>[
      TurfSummary(
        id: firstTurfId,
        name: 'Turf A',
        address: 'Sector 12, Sports Complex',
      ),
      TurfSummary(
        id: secondTurfId,
        name: 'Turf B',
        address: 'Sector 7, Futsal Court',
      ),
    ];
  }
}
