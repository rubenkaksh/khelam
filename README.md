# khelam

Reusable Flutter starter template following a clean architecture baseline for
future forked projects.

## Khelam Roadmap

Start with [`memory.md`](memory.md) for the project intent, architecture
direction, package decisions, and future module ideas. Use
[`phase-1-checklist.md`](phase-1-checklist.md) as the current execution
checklist.

Phase 1 keeps the template small: a themed email/password login module, mockable
API/auth examples, local storage samples, and reference tests. Firebase, Melos,
branding automation, CI/CD, and optional module removal are planned later so the
baseline stays easy to fork.

## Architecture

This project enforces a layered structure:

- `lib/ui`: presentation layer (views, view models, shared UI core)
- `lib/data`: services and repositories
- `lib/domain`: domain models and use cases
- `lib/di`: dependency wiring

## Project Structure

```text
lib/
├── app.dart
├── di/
│   └── app_dependencies.dart
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── models/
│   └── use_cases/
└── ui/
    ├── core/
    └── features/
        └── home/
            ├── bloc/
            └── views/
```

## Workflow For New Features

Use this checklist every time you add a feature:

1. Define domain models.
2. Implement service(s) for external access.
3. Implement repository to map service output to domain.
4. Add use case(s) when feature logic is non-trivial.
5. Build a `Cubit`/`Bloc` and expose immutable state.
6. Build the view layer and bind it with `BlocBuilder`/`BlocListener`.
7. Register dependencies in `lib/di/app_dependencies.dart`.
8. Add/adjust tests for repository and view model behavior.

## Theme preview

Khelam ships an elaborate Material 3 theme (`lib/ui/core/theme/`) centralized in
[`AppTheme`](lib/ui/core/app_theme.dart). The theme preview always applies
`AppTheme.forBrightness()` and `AppTheme.colorSchemeFor()` so components and color
palettes reflect khelam's design tokens.

The preview embeds the local [flutter_material_3_demo](../flutter_material_3_demo)
package via a path dependency. From the home screen, tap the palette icon in the
app bar to open the catalog.

## Getting Started

```bash
flutter pub get
flutter run
```

## Tests

See [`test/README.md`](test/README.md) for the test strategy that future agents
and developers should follow when adding modules.
