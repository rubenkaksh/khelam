# Khelam Project Memory

This repository is a Flutter starter template meant to be forked into new app projects. The goal is not to add every possible production feature immediately. The goal is to keep a small, runnable baseline that can grow into a scalable app without redoing architecture decisions.

## Current Intent

- Keep the main khelam branch ready for all Flutter-supported platforms: Android, iOS, web, macOS, Windows, and Linux.
- Later create a separate mobile-only branch for Android and iOS focused apps.
- Keep the app runnable at every phase.
- Prefer simple, documented extension points over heavy boilerplate.
- Start with a login module as the first real feature.
- When the app runs, it should show the login module and allow review of theme, API service behavior through a mock repository/service, and local database behavior through sample tests.

## Existing Baseline

The project already has:

- A layered Flutter structure:
  - `lib/ui`
  - `lib/domain`
  - `lib/data`
  - `lib/di`
- Centralized theme files under `lib/ui/core/theme`.
- `AppTheme` under `lib/ui/core/app_theme.dart`.
- A home feature using `flutter_bloc`.
- Manual dependency wiring in `lib/di/app_dependencies.dart`.
- A basic widget test in `test/widget_test.dart`.
- A local `material_3_demo` path dependency for theme/component preview.

## Architecture Direction

Use layered architecture:

- UI layer: screens, widgets, Cubits/Blocs for presentation state.
- Domain layer: clean models, use cases, business rules.
- Data layer: API models, local database models, services, repositories.
- DI layer: app-wide dependency registration and environment wiring.

The current code uses Bloc/Cubit. Keep Bloc/Cubit for Phase 1 to avoid unnecessary churn. The project is open to Riverpod later, but Riverpod should be evaluated as a deliberate migration or module-specific decision, not introduced casually.

Dependency injection should move from manual `AppDependencies` to `get_it` plus `injectable`.

Model generation should use:

- `freezed`
- `json_serializable`
- `build_runner`

## Package Decisions

Use `dio` for HTTP networking. Dio is suitable for the template because it supports interceptors, cancellation, upload/download, timeouts, adapters, and global configuration.

Use `drift` for SQLite. Drift is a reactive persistence library built on SQLite and is a strong default for scalable local relational data. Pair it with `sqlite3_flutter_libs` where needed for Flutter native SQLite support.

Use Hive for lightweight local key-value/object storage where relational querying is not needed.

Use `flutter_secure_storage` for secrets such as auth tokens.

Use `go_router` for routing and auth-aware navigation.

Use Firebase support as plug-ready services, not mandatory app behavior in Phase 1:

- Crashlytics
- Firestore
- Remote Config
- Cloud Messaging / notifications

Use Pigeon for type-safe native platform communication when a feature needs native APIs that should not be handled through ad hoc method channels.

## Desired Core Capabilities

The khelam template should eventually provide:

- Login module with email/password.
- Auth session management.
- API client with interceptors and mockable services.
- Local persistence with Hive, Drift, and secure storage.
- Firebase service wrappers.
- Routing with protected routes.
- Basic localization support.
- Environment/flavor setup for dev, staging, and prod.
- Central error handling and typed failures.
- Feature flags and Remote Config bridge.
- App settings module.
- User profile module.
- Onboarding module.
- Notifications module.
- Deep links.
- Analytics abstraction.
- Crash reporting abstraction.
- Permission handling.
- Test examples for each layer.
- CI plan.
- Melos scripts for common commands and template operations.
- Optional feature/module removal through a YAML configuration and Melos script.
- Module-wise dependency scoping so optional modules can own their package
  requirements, setup instructions, generated files, and removal path.
- Branding replacement script for app name, package name, bundle id, icon, and splash.

## Phase Strategy

Organize work by phases, not by large module plans. Modules can get their own plans later.

Recommended phase direction:

- Phase 1: Minimal khelam foundation with login screen, mock API service, local DB sample, DI, routing, generated models, and tests.
- Phase 2: Firebase plug-ready services and environment/flavor setup.
- Phase 3: Template automation with Melos, branding script, module toggle YAML, and branch strategy.
- Phase 4: Production hardening with CI, analytics, crash reporting, notifications, localization, integration tests, and release workflows.
- Phase 5: Optional mobile-only branch that removes desktop/web concerns and tightens mobile release tooling.

## Testing Standard

The project should provide a detailed reference module pattern so future agents and developers can copy it.

Each feature should show how to test:

- Domain models and use cases.
- API models and JSON serialization.
- Repository behavior with fake services.
- Cubit/Bloc state transitions.
- Widget rendering and interactions.
- Local database operations.
- Routing behavior where relevant.

Golden tests and integration tests are desirable after the baseline is stable. Phase 1 should prioritize fast unit/widget tests with clear examples.

## Agent Guidelines

When adding features:

1. Keep the app runnable.
2. Avoid large boilerplate until the project needs it.
3. Follow the existing layered structure.
4. Register dependencies through the chosen DI path.
5. Add tests that demonstrate the intended pattern for future work.
6. Prefer mock/fake services for template examples.
7. Keep platform-specific code isolated.
8. Document any required setup in the relevant checklist or README.
9. Do not remove all-platform support from the main branch.
10. Do not introduce module-specific plans into the main phase checklist unless they are part of the current phase.

## Open Todos For Later

- Add Google sign-in.
- Add Apple sign-in.
- Add phone auth.
- Add magic link auth.
- Add real backend auth adapter.
- Add real Firebase wiring.
- Add app branding CLI/script.
- Add module removal config and script.
- Add mobile-only branch plan.
- Add full CI/CD workflows.
- Add release signing documentation.
- Add integration tests.
- Add golden tests for theme-critical widgets.

## Source Notes

Package choices should be periodically checked against current official package pages before implementation. As of the planning pass, pub.dev describes `dio` as a powerful HTTP networking package with interceptors and related HTTP features, `drift` as a reactive persistence library built on SQLite, and `pigeon` as a Flutter code generator for type-safe host platform communication.
