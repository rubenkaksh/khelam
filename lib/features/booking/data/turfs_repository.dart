import '../models/turf_summary.dart';

/// Source of the turf list shown on the turf-selection screen.
abstract interface class TurfsRepository {
  Future<List<TurfSummary>> getTurfs();
}
