import '../../domain/models/sample_status.dart';
import '../../domain/repositories/sample_service.dart';

class SampleStatusRepository {
  const SampleStatusRepository({required SampleService service})
    : _service = service;

  final SampleService _service;

  Future<SampleStatus> getStatus() {
    return _service.fetchStatus();
  }
}
