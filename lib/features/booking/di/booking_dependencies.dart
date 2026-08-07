import 'package:get_it/get_it.dart';

import 'package:commons/commons.dart';
import '../../../data/storage/preferences.dart';
import '../../../di/env_config.dart';
import '../bloc/turf_selection_cubit.dart';
import '../booking_service.dart';
import '../data/booking_api_service.dart';
import '../data/mock_booking_service.dart';
import '../data/mock_turfs_repository.dart';
import '../data/turfs_api_repository.dart';
import '../data/turfs_repository.dart';

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

    // Turf list: mock by default, mirroring the booking switch. The backend
    // has no GET /turfs endpoint yet, so API mode falls back to the same
    // two turfs until it ships.
    final bool useMockTurfs =
        envValue('USE_MOCK_TURFS') == 'true' ||
        envValue('API_BASE_URL') == null;

    locator.registerLazySingleton<TurfsRepository>(
      () => useMockTurfs
          ? MockTurfsRepository()
          : TurfsApiRepository(apiClient: locator<DioApiClient>()),
    );
    locator.registerFactory<TurfSelectionCubit>(
      () => TurfSelectionCubit(
        repository: locator<TurfsRepository>(),
        preferences: locator<Preferences>(),
      ),
    );

    // ScheduleCubit is constructed per-route with the selected turf id (see
    // service_locator.dart's AppRouter wiring); it is not a plain factory
    // registration because the turf id arrives at navigation time.
  }
}
