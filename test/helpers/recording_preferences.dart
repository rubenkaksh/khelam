import 'package:khelam/data/storage/preferences.dart';

/// In-memory preferences for tests. Shared by all test files (AGENTS.md:
/// "Shared test fakes, not per-file copies") — widget tests must never hit
/// the real SharedPreferences platform channel, because those futures never
/// complete in tests and the app hangs on the boot spinner.
class RecordingPreferences implements Preferences {
  String? storedTurfId;
  bool cleared = false;

  /// When true, writes throw — lets tests exercise the persistence-failure
  /// paths (e.g. the turf-selection confirm error).
  bool failWrites = false;

  @override
  Future<String?> selectedTurfId() async => storedTurfId;

  @override
  Future<void> setSelectedTurfId(String turfId) async {
    if (failWrites) throw Exception('Write failed');
    storedTurfId = turfId;
  }

  @override
  Future<void> clear() async {
    if (failWrites) throw Exception('Write failed');
    cleared = true;
    storedTurfId = null;
  }
}
