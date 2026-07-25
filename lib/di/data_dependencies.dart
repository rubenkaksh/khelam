import 'package:get_it/get_it.dart';

import '../data/repositories/local_sample_repository.dart';
import '../data/repositories/sample_status_repository.dart';
import '../data/services/dio_api_client.dart';
import '../data/services/local_sample_storage_service.dart';
import '../data/services/sample_api_service.dart';
import '../domain/repositories/sample_service.dart';

abstract final class DataDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<DioApiClient>(
      () => DioApiClient(baseUrl: 'https://example.invalid'),
    );

    locator.registerLazySingleton<SampleService>(
      () => const SampleApiService(),
    );
    locator.registerLazySingleton<SampleStatusRepository>(
      () => SampleStatusRepository(service: locator<SampleService>()),
    );

    locator.registerLazySingleton<LocalSampleStorageService>(
      InMemoryLocalSampleStorageService.new,
    );
    locator.registerLazySingleton<LocalSampleRepository>(
      () => LocalSampleRepository(storage: locator<LocalSampleStorageService>()),
    );
  }
}
