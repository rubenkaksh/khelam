import 'package:get_it/get_it.dart';

import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/services/mock_booking_service.dart';
import '../../../../domain/repositories/booking_service.dart';
import '../bloc/schedule_cubit.dart';

abstract final class ScheduleDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<BookingService>(
      () => MockBookingService(),
    );
    locator.registerLazySingleton<BookingRepository>(
      () => BookingRepository(service: locator<BookingService>()),
    );
    locator.registerFactory<ScheduleCubit>(
      () => ScheduleCubit(repository: locator<BookingRepository>()),
    );
  }
}
