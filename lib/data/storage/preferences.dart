/// Typed accessors for session-level, non-sensitive preferences.
///
/// Backed by a [StoreService] (SharedPreferences today, a typed store
/// Hive/Isar later). New preferences land here as typed getters/setters.
abstract interface class Preferences {
  Future<String?> selectedTurfId();

  Future<void> setSelectedTurfId(String turfId);

  /// Resets all stored preferences (e.g. on logout).
  Future<void> clear();
}
