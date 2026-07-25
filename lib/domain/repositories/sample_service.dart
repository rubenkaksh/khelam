import '../../domain/models/sample_status.dart';

abstract interface class SampleService {
  Future<SampleStatus> fetchStatus();
}
