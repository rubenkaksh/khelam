import 'package:get_it/get_it.dart';
import 'package:samseer/samseer.dart';

import 'package:commons/commons.dart';
import '../data/storage/preferences.dart';
import '../data/storage/preferences_impl.dart';
import '../data/storage/shared_prefs_store_service.dart';
import '../data/storage/store_service.dart';
import '../features/auth/bloc/auth_cubit.dart';
import '../features/auth/di/auth_dependencies.dart';
import '../features/booking/bloc/schedule_cubit.dart';
import '../features/booking/bloc/turf_selection_cubit.dart';
import '../features/booking/booking_service.dart';
import '../features/booking/di/booking_dependencies.dart';
import '../ui/navigation/app_router.dart';
import 'env_config.dart';

final GetIt serviceLocator = GetIt.instance;

/// Wires dependency injection. Pass a [samseer] instance (from `main()`) to
/// attach the HTTP inspector: its navigator key becomes the GoRouter key (so
/// `showInspector()` can push onto the app navigator) and its Dio interceptor
/// records every API call. When `null` (widget tests) everything behaves as
/// before.
void configureDependencies({GetIt? getIt, Samseer? samseer}) {
  final GetIt locator = getIt ?? serviceLocator;
  if (locator.isRegistered<AppRouter>()) {
    return;
  }

  // Shared infrastructure.
  locator.registerLazySingleton<DioApiClient>(
    () {
      final DioApiClient client = DioApiClient(
        baseUrl: envValue('API_BASE_URL') ?? 'https://example.invalid',
      );
      final Samseer? inspector = samseer;
      if (inspector != null) {
        client.raw.interceptors.add(inspector.dioInterceptor);
      }
      // Retry transient GET failures (timeouts, connection errors, HTTP >=
      // 500) once with backoff. Added last so its onError runs first; POSTs
      // are never retried (a retry could double-book a slot).
      client.raw.interceptors.add(
        RetryInterceptor(
          dio: client.raw,
          baseDelay: const Duration(milliseconds: 300),
        ),
      );
      return client;
    },
  );

  // Shared infrastructure: key-value preference store (SharedPreferences
  // today; a typed Hive/Isar store can swap in here later).
  locator.registerLazySingleton<StoreService>(() => SharedPrefsStoreService());
  locator.registerLazySingleton<Preferences>(
    () => PreferencesImpl(store: locator<StoreService>()),
  );

  // Per-feature registries (ADR-0003): each feature wires its own chain.
  AuthDependencies.register(locator);
  BookingDependencies.register(locator);

  locator.registerLazySingleton<AppRouter>(
    () => AppRouter(
      isAuthenticated: () => locator<AuthCubit>().state.isAuthenticated,
      authCubit: () => locator<AuthCubit>(),
      scheduleCubit: (String turfId) =>
          ScheduleCubit(service: locator<BookingService>(), turfId: turfId),
      turfSelectionCubit: () => locator<TurfSelectionCubit>(),
      navigatorKey: samseer?.navigatorKey,
    ),
  );
}
