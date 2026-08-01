# ADR-0003: Per-Feature Dependency Injection

**Date**: 2026-06-22  
**Status**: Accepted  
**Deciders**: @rubenk

## Context

`lib/di/service_locator.dart` was an 84-line monolith that knew about **every** module in the project — importing from `data/repositories/`, `data/services/`, `domain/use_cases/`, `ui/features/` (4 layers). Every new feature required editing this file. No feature could be understood in isolation.

## Decision

**Split dependency wiring into per-feature DI modules.** Each feature that has a UI directory (`lib/ui/features/<feature>/`) gets its own `di/` subdirectory with a `XXXDependencies` registry class.

### Pattern

```dart
// lib/ui/features/auth/di/auth_dependencies.dart
abstract final class AuthDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<AuthService>(() => const MockAuthService());
    locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(service: locator<AuthService>()),
    );
    locator.registerFactory<AuthCubit>(
      () => AuthCubit(repository: locator<AuthRepository>()),
    );
  }
}
```

### Central aggregator

`lib/di/service_locator.dart` becomes a ~15-line aggregator that delegates to feature registries:

```dart
void configureDependencies({GetIt? getIt}) {
  final GetIt locator = getIt ?? serviceLocator;
  if (locator.isRegistered<AppRouter>()) return;

  AuthDependencies.register(locator);
  HomeDependencies.register(locator);
  DataDependencies.register(locator);
  locator.registerLazySingleton<AppRouter>(AppRouter.new);
}
```

## Consequences

- **Feature DI files live with feature code** — auth devs never see home DI
- **New features add a file + one line in aggregator** — no modification of existing code
- **Testability**: each feature's DI can be tested with a fresh `GetIt` instance
- **Non-UI dependencies** (sample, local_sample) remain in a shared `DataDependencies` class in `lib/di/`
- **ADR compliance**: every new feature MUST register its dependencies in its own DI file, not in the central aggregator

## Superseded in part

**ADR-0004** (2026-08-01) relocated feature DI from `lib/ui/features/<feature>/di/`
to `lib/features/<feature>/di/` (the feature module owns its whole slice), and
removed the shared `DataDependencies` class. The pattern here — per-feature DI
registries + a thin central aggregator — remains the rule.

## Related

- ADR-0001: No shallow use-case layer
- ADR-0002: Service interfaces at domain/repositories layer
