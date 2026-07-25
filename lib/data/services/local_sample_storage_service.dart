abstract interface class LocalSampleStorageService {
  Future<void> write({required String key, required String value});

  Future<String?> read(String key);

  Future<void> delete(String key);
}

class InMemoryLocalSampleStorageService implements LocalSampleStorageService {
  InMemoryLocalSampleStorageService({Map<String, String>? initialValues})
    : _values = <String, String>{...?initialValues};

  final Map<String, String> _values;

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}
