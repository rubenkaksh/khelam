import 'package:shared_preferences/shared_preferences.dart';

import 'store_service.dart';

/// [StoreService] backed by SharedPreferences (async API).
class SharedPrefsStoreService implements StoreService {
  SharedPrefsStoreService({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> readString(String key) => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);

  @override
  Future<bool> contains(String key) => _prefs.containsKey(key);

  @override
  Future<void> clearAll() => _prefs.clear();
}
