import '../../../domain/models/sample_status.dart';
import '../../../domain/repositories/sample_service.dart';

class SampleApiService implements SampleService {
  const SampleApiService();

  @override
  Future<SampleStatus> fetchStatus() async {
    return const SampleStatus(
      id: 'sample-api',
      message: 'Mock API service is reachable.',
      isHealthy: true,
    );
  }
}
