/// Key-value storage abstraction for non-sensitive app preferences.
///
/// Lets preferences/session data move between backends — SharedPreferences
/// today, a typed store (Hive/Isar) tomorrow — without touching callers.
/// Swap the backing by registering a different implementation of this
/// interface in DI.
///
/// Deliberately separate from auth-token storage: secrets live in secure
/// storage (the auth feature's token store), never here.
abstract interface class StoreService {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  Future<void> delete(String key);

  Future<bool> contains(String key);

  /// Wipes every key in the store. Safe to call on logout: this store only
  /// ever holds preference keys, never credentials.
  Future<void> clearAll();
}
