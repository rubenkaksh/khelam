import '../../domain/models/local_sample_record.dart';
import '../services/local_sample_storage_service.dart';

class LocalSampleRepository {
  const LocalSampleRepository({required LocalSampleStorageService storage})
    : _storage = storage;

  final LocalSampleStorageService _storage;

  Future<void> save(LocalSampleRecord record) {
    return _storage.write(key: record.key, value: record.value);
  }

  Future<LocalSampleRecord?> find(String key) async {
    final String? value = await _storage.read(key);
    if (value == null) {
      return null;
    }
    return LocalSampleRecord(key: key, value: value);
  }

  Future<void> remove(String key) {
    return _storage.delete(key);
  }
}
