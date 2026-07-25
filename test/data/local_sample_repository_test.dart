import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/data/repositories/local_sample_repository.dart';
import 'package:khelam/data/services/local_sample_storage_service.dart';
import 'package:khelam/domain/models/local_sample_record.dart';

void main() {
  group('LocalSampleRepository', () {
    test('saves and reads a local sample record', () async {
      final LocalSampleRepository repository = LocalSampleRepository(
        storage: InMemoryLocalSampleStorageService(),
      );
      const LocalSampleRecord record = LocalSampleRecord(
        key: 'api-cache-status',
        value: 'healthy',
      );

      await repository.save(record);
      final LocalSampleRecord? savedRecord = await repository.find(record.key);

      expect(savedRecord?.key, record.key);
      expect(savedRecord?.value, record.value);
    });

    test('removes a local sample record', () async {
      final LocalSampleRepository repository = LocalSampleRepository(
        storage: InMemoryLocalSampleStorageService(
          initialValues: <String, String>{'session': 'demo'},
        ),
      );

      await repository.remove('session');

      expect(await repository.find('session'), isNull);
    });
  });
}
