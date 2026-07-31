import 'package:get_it/get_it.dart';

import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/services/booking_api_service.dart';
import '../../../../data/services/dio_api_client.dart';
import '../../../../data/services/mock_booking_service.dart';
import '../../../../di/env_config.dart';
import '../../../../domain/repositories/booking_service.dart';
import '../bloc/schedule_cubit.dart';

abstract final class ScheduleDependencies {
  static void register(GetIt locator) {
    // Use the mock service by default (fresh clones, widget tests). The
    // .env file opts into the real API by setting API_BASE_URL. Set
    // USE_MOCK_BOOKING=true to force the mock even when a base URL exists.
    final bool useMockBooking =
        envValue('USE_MOCK_BOOKING') == 'true' ||
        envValue('API_BASE_URL') == null;

    locator.registerLazySingleton<BookingService>(
      () => useMockBooking
          ? MockBookingService()
          : BookingApiService(apiClient: locator<DioApiClient>()),
    );
    locator.registerLazySingleton<BookingRepository>(
      () => BookingRepository(service: locator<BookingService>()),
    );
    locator.registerFactory<ScheduleCubit>(
      () => ScheduleCubit(repository: locator<BookingRepository>()),
    );
  }
}
