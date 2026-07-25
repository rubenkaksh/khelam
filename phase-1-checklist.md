# Phase 1 Checklist

Goal: create a minimal, runnable khelam foundation. The app should launch into a simple email/password login module, show the existing theme quality, and include working sample patterns for API access, mock repositories, local storage, and tests.

Keep Phase 1 small. Do not add full production Firebase, notifications, analytics, branding automation, or module-removal tooling yet. Document those as later-phase todos.

## 1. Project Baseline

- [ ] Confirm the main branch remains all-platform ready: Android, iOS, web, macOS, Windows, and Linux.
- [x] Keep the existing theme under `lib/ui/core/theme`.
- [x] Keep the current layered structure: `ui`, `domain`, `data`, `di`.
- [x] Update `README.md` to point agents to `memory.md` and this checklist.
- [x] Add a short "Phase 1 scope" section to `README.md`.

## 2. Dependencies

- [x] Add routing dependency: `go_router`.
- [ ] Add dependency injection dependencies: `get_it`, `injectable`.
- [ ] Add code generation dependencies: `freezed`, `freezed_annotation`, `json_serializable`, `build_runner`.
- [x] Add networking dependency: `dio`.
- [ ] Add local storage dependencies: `hive`, `hive_flutter`.
- [ ] Add SQLite dependency: `drift`.
- [ ] Add native SQLite support package where needed: `sqlite3_flutter_libs`.
- [ ] Add secure storage dependency: `flutter_secure_storage`.
- [ ] Add testing helpers as needed: `bloc_test`, `mocktail`.
- [ ] Add Pigeon as a dev dependency for future native bridge generation.

## 3. Dependency Injection

- [x] Replace or wrap manual `AppDependencies` with `get_it`.
- [ ] Add injectable configuration under `lib/di`.
- [ ] Add environment names for `dev`, `staging`, `prod`, and `test`.
- [ ] Keep dependency setup understandable for small apps.
- [ ] Ensure tests can override dependencies with fakes.

## 4. Routing

- [x] Add `go_router` setup.
- [x] Make the login screen the initial route.
- [x] Keep a route to the existing theme preview or home/template screen.
- [x] Add placeholder route protection design for authenticated routes.
- [x] Add a simple routing test or widget test that verifies initial login route.

## 5. Login Module

- [x] Create `lib/ui/features/auth`.
- [x] Add an email/password login screen.
- [x] Use existing app theme components and spacing.
- [x] Add form validation for email and password.
- [x] Add `AuthCubit` or equivalent Bloc/Cubit state.
- [x] Add loading, success, and failure states.
- [x] Keep authentication backed by a mock repository in Phase 1.
- [x] Add a visible way to open the theme preview from the login flow.
- [ ] Add todos for Google, Apple, phone auth, and magic link.

## 6. Auth Domain And Data

- [ ] Add an `AuthUser` domain model with `freezed`.
- [ ] Add an `AuthSession` or token/session domain model if needed.
- [x] Add an `AuthRepository` interface or implementation boundary.
- [x] Add a mock auth service that accepts a documented test email/password.
- [ ] Add JSON API model examples using `json_serializable`.
- [x] Add an auth login use case if it keeps Cubit logic clean.

## 7. API Client Sample

- [x] Add a `DioApiClient` wrapper under `lib/data/services`.
- [ ] Add base URL configuration from environment/app config.
- [x] Add request/response/error handling shape.
- [x] Add interceptor placeholder for auth token injection.
- [x] Add mock API service for a placeholder endpoint.
- [x] Add repository using the mock API service.
- [x] Add tests proving the placeholder API service/repository path works.

## 8. Local Storage Sample

- [ ] Add secure storage wrapper for secrets/tokens.
- [ ] Add Hive local service for lightweight storage.
- [ ] Add Drift database setup for SQLite sample data.
- [ ] Add a tiny sample table/entity for proving Drift works.
- [ ] Add repository or service tests for Hive behavior.
- [ ] Add repository or service tests for Drift behavior.
- [ ] Keep sample local storage isolated so it can be removed later.

## 9. Environment And Config

- [ ] Add a simple app config model.
- [ ] Support `dev`, `staging`, `prod`, and `test` values.
- [ ] Keep flavor/native setup minimal in Phase 1.
- [ ] Document future native flavor setup as Phase 2 work.
- [ ] Ensure mock services are easy to enable in `dev` and `test`.

## 10. Localization

- [ ] Add simple localization support.
- [ ] Keep at least English strings wired through localization.
- [ ] Avoid translating every placeholder string in Phase 1.
- [ ] Document how future agents should add strings.

## 11. Pigeon Placeholder

- [ ] Add a `pigeons/` directory.
- [ ] Add a minimal sample Pigeon API only if it does not create unnecessary platform churn.
- [ ] Otherwise document the intended Pigeon structure and generation command.
- [ ] Add a todo for native bridge examples in a later phase.

## 12. Tests As Reference

- [ ] Add unit tests for auth use case or repository.
- [ ] Add Cubit/Bloc tests for login states.
- [ ] Add widget tests for login form validation and submit behavior.
- [x] Add API client/repository tests with fake service responses.
- [ ] Add Hive service tests.
- [ ] Add Drift database tests.
- [ ] Keep test names descriptive so future agents can copy the pattern.
- [x] Add a `test/README.md` explaining the test strategy.

## 13. Melos Planning Only

- [ ] Add a later-phase todo for Melos.
- [ ] Document desired future Melos commands:
  - `melos bootstrap`
  - `melos analyze`
  - `melos test`
  - `melos format`
  - `melos generate`
  - `melos rename_app`
  - `melos toggle_modules`
- [ ] Do not introduce Melos workspace complexity in Phase 1 unless needed.

## 14. Later-Phase Todos

- [ ] Module-wise dependency scoping plan so optional modules can own their
      packages, setup steps, generated files, and removal instructions.
- [ ] Firebase Crashlytics service wrapper.
- [ ] Firestore service wrapper.
- [ ] Remote Config service wrapper.
- [ ] Cloud Messaging and notifications.
- [ ] CI workflow for analyze and test.
- [ ] CI workflow for platform builds.
- [ ] Branding replacement script.
- [ ] Module toggle YAML and removal script.
- [ ] Analytics abstraction.
- [ ] Error reporting abstraction.
- [ ] Deep links.
- [ ] Permissions service.
- [ ] Onboarding module.
- [ ] Settings module.
- [ ] Profile module.
- [ ] Mobile-only branch plan.

## Phase 1 Acceptance Criteria

- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [x] App launches to the login screen.
- [x] Login screen uses the project theme.
- [x] Login flow can succeed through a mock auth repository.
- [x] Theme preview remains reachable.
- [x] Placeholder API service has at least one passing test.
- [ ] Hive or equivalent local key-value service has at least one passing test.
- [ ] Drift SQLite sample has at least one passing test.
- [ ] Future agents can understand the intended architecture from `memory.md`, `README.md`, and this checklist.
## 11. Extract Business Logic from Widgets

- [ ] Move API calls, validation, and business logic out of UI screens into domain layer use cases.
- [ ] Use Cubit/ViewModel pattern to keep UI thin.

## 12. State Management

- [x] Keep existing choice consistent (Riverpod or BLoC).
- [ ] Document state management decision rationale in memory.md.

## 13. Error Handling

- [ ] Add retry logic with exponential backoff for transient failures.
- [ ] Handle network timeouts, invalid responses, and empty states consistently.
- [ ] Show graceful failures instead of crashes.

## 14. Performance Optimization

- [ ] Use const constructors wherever possible.
- [ ] Avoid unnecessary rebuilds by isolating state changes.
- [ ] Profile before optimizing.

## 15. Pagination

- [ ] Add cursor-based pagination for list views.
- [ ] Implement infinite scrolling with proper loading states.
- [ ] Lazy load content to reduce memory pressure.

## 16. API Caching

- [ ] Add cache layer to prevent duplicate requests during same lifecycle.
- [ ] Dedupe redundant API calls in list screens.

## 17. Offline First Support

- [ ] Cache critical content for offline viewing.
- [ ] Add retry mechanism with clear user feedback.
- [ ] Queue pending actions when offline.

## 18. Analytics Integration

- [ ] Add analytics event tracking from day one.
- [ ] Document key events to track (onboarding, feature usage, drop-offs).

## 19. Centralized Configuration

- [ ] Move API URLs and feature flags into centralized env-config package.
- [ ] Separate dev/staging/prod config values.

## 20. Architectural Foundation

- [ ] Confirm clean separation: ui -> domain (models/use cases) -> data (repositories).
- [ ] Ensure dependency injection wiring for all layers.
- [ ] Document architecture decisions in memory.md and README.md.
