import 'package:get_it/get_it.dart';

import '../../../core/network/dio_api_client.dart';
import '../../../di/env_config.dart';
import '../bloc/schedule_cubit.dart';
import '../booking_service.dart';
import '../data/booking_api_service.dart';
import '../data/mock_booking_service.dart';

abstract final class BookingDependencies {
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
    locator.registerFactory<ScheduleCubit>(
      () => ScheduleCubit(service: locator<BookingService>()),
    );
  }
}
