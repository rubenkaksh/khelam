import 'preferences.dart';
import 'shared_prefs_store_service.dart';
import 'store_service.dart';

/// Default [Preferences] implementation backed by a [StoreService].
///
/// The store is injectable so tests can substitute an in-memory fake, and so
/// a future typed store (Hive/Isar) can be swapped in via DI without touching
/// callers.
class PreferencesImpl implements Preferences {
  PreferencesImpl({StoreService? store})
    : _store = store ?? SharedPrefsStoreService();

  final StoreService _store;

  static const String _selectedTurfIdKey = 'selected_turf_id';

  @override
  Future<String?> selectedTurfId() => _store.readString(_selectedTurfIdKey);

  @override
  Future<void> setSelectedTurfId(String turfId) =>
      _store.writeString(_selectedTurfIdKey, turfId);

  @override
  Future<void> clear() => _store.clearAll();
}
