# Architecture Review — khelam

**Date**: 2026-06-22  
**Commit**: `cad15d3`  
**Scope**: Full codebase structural review using codegraph + knowledge graph  

> Uses vocabulary from [improve-codebase-architecture](../../.agents/skills/improve-codebase-architecture/LANGUAGE.md):  
> **module**, **interface**, **seam**, **adapter**, **depth**, **leverage**, **locality**.

---

## Candidate 1 — Pass-through Use Cases

**Files**: `lib/domain/use_cases/*.dart` (5 files, ~13 lines each)  
**Strength**: 🔴 Strong

### Problem

All five use cases are pure **delegates** — each calls exactly one repository method and returns its result. No transformation, validation, composition, or side effects:

```
LoginWithEmailUseCase.execute(email, password) → _repository.login(email, password)
GetTemplateInfoUseCase.execute()               → _repository.getTemplateInfo()
GetSampleStatusUseCase.execute()               → _repository.getSampleStatus()
GetLocalSampleRecordUseCase.execute()          → _repository.getLocalSampleRecord()
SaveLocalSampleRecordUseCase.execute(record)   → _repository.save(record)
```

**Deletion test**: delete each use case. Complexity doesn't concentrate — it moves one line up to the Cubit. Nothing is lost. The interface is **as complex as the implementation** → shallow modules.

**Locality**: bugs, changes, knowledge spread across 3 layers (Cubit → UseCase → Repository) rather than concentrating at 1 seam.

### Solution

Delete the use case layer. Have Cubits depend directly on repository interfaces:

```
AuthCubit(loginRepository: LoginRepository)  // was: LoginWithEmailUseCase
HomeCubit(templateRepository: TemplateRepository) // was: GetTemplateInfoUseCase
```

If business logic later grows (e.g., `login` validating rate limits + audit logging + password hashing), *then* extract a use case. The seam (`UseCase` → `Cubit`) is **hypothetical** — no second adapter justifies it.

### Benefits

- **Locality**: Cubit contains the full orchestration flow in one file instead of 3
- **Leverage**: 5 files deleted, ~65 lines removed, 5 imports eliminated from `service_locator`
- **Test surface**: Cubit tests already cover the flow — use case tests are redundant (if they existed)
- **Seam clarity**: repository interface becomes the single seam between data and UI

### Before / After

```
Before (3-layer delegation, 5 files per feature):
  Cubit → UseCase → Repository → Service
  └ auth_cubit.dart
     └ login_with_email_use_case.dart  ← 13 lines, 1 delegation
        └ auth_repository.dart
           └ mock_auth_service.dart

After (2-layer, Cubit → Repository):
  Cubit → Repository → Service
  └ auth_cubit.dart        ← calls _repository.login() directly
     └ auth_repository.dart
        └ mock_auth_service.dart
```

---

## Candidate 2 — Service Locator Monolith

**Files**: `lib/di/service_locator.dart` (84 lines), `lib/di/app_dependencies.dart` (30 lines)  
**Strength**: 🔴 Strong

### Problem

`configureDependencies()` is a single function that knows about **every** module in the project. It imports from `data/repositories/`, `data/services/`, `domain/use_cases/`, `ui/features/`, `ui/navigation/` — spanning all 4 architecture layers. Adding one feature touches 3 lines here. With 5 features it's 84 lines; with 20 features it's 300+.

The module is **shallow**: the interface is `configureDependencies({GetIt? getIt})` — one function doing an unbounded amount of wiring behind a 1-param interface. This isn't depth; it's a single-file bottleneck masquerading as depth. Every new feature increases the interface complexity (which imports to add?) without improving leverage.

**Locality**: All wiring knowledge is in one file. Changes to any feature require touching this file. No feature can be understood in isolation — its wiring is always "somewhere in service_locator.dart."

### Solution

Split wiring into per-feature configuration modules. Each feature registers its own dependency chain:

```dart
// lib/ui/features/auth/di/auth_dependencies.dart
void configureAuthDependencies(GetIt locator) {
  locator.registerLazySingleton<MockAuthService>(() => const MockAuthService());
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(service: locator<MockAuthService>()),
  );
  locator.registerFactory<AuthCubit>(
    () => AuthCubit(loginRepository: locator<AuthRepository>()),
  );
}

// lib/di/service_locator.dart — reduced to registry aggregation
void configureDependencies({GetIt? getIt}) {
  final locator = getIt ?? serviceLocator;
  if (locator.isRegistered<AppRouter>()) return;

  configureAuthDependencies(locator);
  configureHomeDependencies(locator);
  configureSampleDependencies(locator);
  configureLocalSampleDependencies(locator);
  locator.registerLazySingleton<AppRouter>(AppRouter.new);
}
```

### Benefits

- **Locality**: Each feature's wiring lives with its feature code. Auth devs never see home wiring.
- **Leverage**: Adding a feature = adding a `configureX` call + a new file. Not modifying existing code.
- **Test surface**: Each feature's DI can be tested in isolation with a fresh `GetIt` instance.
- **Seam**: The `configureX` function becomes the external seam — 1-per-feature interface.

### Before / After

```
Before (monolith):
  service_locator.dart (84 lines)
  ├── AuthCubit wiring        (line 34-43)
  ├── HomeCubit wiring        (line 45-56)
  ├── SampleStatus wiring     (line 58-66)
  └── LocalSample wiring      (line 68-83)

After (per-feature):
  service_locator.dart (15 lines) — aggregation only
  auth/di/auth_dependencies.dart       — auth wiring
  home/di/home_dependencies.dart       — home wiring
  data/di/sample_dependencies.dart     — sample wiring
```

---

## Candidate 3 — Missing Auth Service Interface

**Files**: `lib/data/repositories/auth_repository.dart`, `lib/data/services/mock_auth_service.dart`  
**Strength**: 🔴 Strong

### Problem

`AuthRepository` depends on the **concrete** `MockAuthService` — not an abstract `AuthService`:

```dart
class AuthRepository {
  const AuthRepository({required MockAuthService service}) : _service = service;
  final MockAuthService _service; // concrete class!
```

This means:
- No **seam** exists between `AuthRepository` and its auth service adapter
- Swapping to a real API auth service means editing `AuthRepository` — violating the open/closed principle
- The `MockAuthService` class (41 lines) IS the interface — every future adapter must match its exact method signature, exception types, and response shape
- Contrast with `PaginatedRepository` (the ONLY abstract interface in the data layer)

**One adapter = hypothetical seam**. `MockAuthService` is currently the only adapter. But this is a **starter template** — a real API adapter is the primary use case. The seam is implicit and will be extracted by the first forker anyway. Making it explicit now saves fork-drift.

### Solution

Extract an `AuthService` abstract class (interface) at the domain/data boundary:

```dart
// lib/domain/repositories/auth_service.dart (new)
abstract class AuthService {
  Future<AuthUser> login({required String email, required String password});
}

// lib/data/services/mock_auth_service.dart — becomes adapter
class MockAuthService implements AuthService { ... }

// lib/data/services/api_auth_service.dart — future adapter
class ApiAuthService implements AuthService { ... }

// lib/data/repositories/auth_repository.dart — depends on interface
class AuthRepository {
  const AuthRepository({required AuthService service}) : _service = service;
  final AuthService _service; // abstract!
```

Same pattern should apply to `TemplateCatalogService` / `SampleApiService` / `LocalSampleStorageService`.

### Benefits

- **Seam**: `AuthService` becomes the formal seam — tests use `MockAuthService`, production uses `ApiAuthService`
- **Leverage**: Forkers swap one adapter without touching repository or Cubit
- **Locality**: Implementation knowledge stays in adapters; repository doesn't know which adapter it's using
- **Test surface**: Repository tests can use a lightweight fake adapter, not the full mock service

### Before / After

```
Before (concrete dependency, no seam):
  AuthRepository
  └── MockAuthService (concrete) ← no substitution
  
After (interface dependency, explicit seam):
  AuthRepository
  └── AuthService (abstract) ← SEAM
      ├── MockAuthService (adapter)
      └── ApiAuthService  (future adapter)
```

---

## Candidate 4 — Theme Monolith (Observation)

**Files**: `lib/ui/core/theme/app_component_themes.dart` (471 lines)  
**Strength**: 🟡 Worth exploring

### Problem

`AppComponentThemes.build()` is a **deep** module — ~40 M3 component themes configured in one call behind a 3-param interface (`colorScheme`, `textTheme`, `brightness`). High leverage, good locality.

However, 471 lines is a large file. As the design system grows (custom card variants, feature-specific overrides, widget-specific padding), this file risks becoming a **god object** — the "one place for all theming." The incentive is to always add here because the seam is convenient.

### Solution

Not urgent. Two watch-points for future:
1. If a feature needs a custom theme variant (e.g., chat bubbles, dashboard cards), define it at the **feature level** using `Theme.of(context)`, not by adding methods to `AppComponentThemes`
2. If `build()` exceeds ~600 lines, split `buildThemeData()` into builder functions per component group: `_buildNavigationThemes()`, `_buildButtonThemes()`, `_buildInputThemes()`

No action needed now. Documenting as a future friction point.

---

## Candidate 5 — Use Case Naming Leaks Implementation

**Files**: `lib/domain/use_cases/*.dart`  
**Strength**: 🟡 Worth exploring (tied to Candidate 1)

### Problem

Use case names encode the operation rather than the domain intent:
- `LoginWithEmailUseCase` — "login" + "with email" + "use case" (4 tokens, 3 are boilerplate)
- `GetTemplateInfoUseCase` — "get" leaks that it's a query
- `GetSampleStatusUseCase` — "get" + "use case" framing

Domain names should convey **what** the module does, not **how**:
- `LoginWithEmail` → `Authenticate` or `SignIn`
- `GetTemplateInfo` → `TemplateInfo` (as a query object)

This is cosmetic if use cases are deleted (Candidate 1). If they stay, these names should be refactored to reflect domain concepts.

---

## Summary

| # | Candidate | Strength | Files affected | Impact |
|---|-----------|----------|---------------|--------|
| 1 | Pass-through use cases | Strong | 5 deleted, 2 cubits + service_locator modified | -65 lines, -1 layer |
| 2 | Service locator monolith | Strong | 1 split → ~5 files | +locality, -coupling |
| 3 | Missing auth service interface | Strong | 1 new interface, auth_repository + mock_auth modified | +seam, +substitutability |
| 4 | Theme monolith | ✅ Completed | `app_component_themes.dart` — split 440-line `build()` into 22 private methods | 519 insertions, no behavior change |
| 5 | Use case naming | Worth exploring | 0 if Candidate 1 accepted | Namespace clarity |

### Top Recommendation

**Tackle Candidate 1 + 2 + 3 together.** They form a single coherent refactor:
1. Delete use cases (Candidate 1) — removes the shallow layer
2. Split service_locator (Candidate 2) — gives each feature its own DI module
3. Extract AuthService interface (Candidate 3) — formalizes the seam that Candidate 2's feature DI files will wire

Combined diff: ~5 files deleted, ~3 files created, ~4 files modified. No behaviour change. All testable incrementally.

---

*Next: grilling loop. Pick a candidate (or combo) to deep-dive.*
