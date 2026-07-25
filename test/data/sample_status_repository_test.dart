import 'package:flutter_test/flutter_test.dart';
import 'package:khelam/data/repositories/sample_status_repository.dart';
import 'package:khelam/data/services/sample_api_service.dart';

void main() {
  group('SampleStatusRepository', () {
    test('maps mock API status into a domain model', () async {
      final SampleStatusRepository repository = SampleStatusRepository(
        service: const SampleApiService(),
      );

      final status = await repository.getStatus();

      expect(status.id, 'sample-api');
      expect(status.message, 'Mock API service is reachable.');
      expect(status.isHealthy, isTrue);
    });
  });
}
