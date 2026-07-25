# commons.md — Atomic Widgets Checklist

Status: dev in progress. Buttons (5), Typography (4), Inputs (3), Feedback (4) implemented.

## v1 Widget Roster

### Buttons (5)

- [x] **PrimaryButton** — ElevatedButton wrapper. Primary action. `lib/ui/common/buttons.dart`.
- [x] **FilledButton** — FilledButton wrapper. Secondary action. `lib/ui/common/buttons.dart`.
- [x] **OutlineButton** — OutlinedButton wrapper. Tertiary action. `lib/ui/common/buttons.dart`.
- [x] **GhostButton** — TextButton wrapper. Minimal/low-priority action. `lib/ui/common/buttons.dart`. Renamed from `TextButton`.
- [x] **IconButton** — IconButton wrapper. Icon-only action. `lib/ui/common/buttons.dart`.

### Inputs (3)

- [x] **TextInput** — TextFormField wrapper. Props: label, hint, error, enabled, obscure. `lib/ui/common/inputs.dart`.
- [x] **PasswordInput** — TextFormField wrapper. Adds visibility toggle on obscure. `lib/ui/common/inputs.dart`.
- [x] **SearchInput** — SearchBar wrapper. Props: hint, onChanged, controller. `lib/ui/common/inputs.dart`.

### Typography (4)

- [x] **Headline** — Typography widget. Size enum: `HeadlineSize.large | medium | small`. `lib/ui/common/typography.dart`.
- [x] **Title** — Typography widget. Size enum: `TitleSize.large | medium | small`. `lib/ui/common/typography.dart`.
- [x] **Body** — Typography widget. Size enum: `BodySize.large | medium | small`. `lib/ui/common/typography.dart`.
- [x] **Label** — Typography widget. Size enum: `LabelSize.large | medium | small`. `lib/ui/common/typography.dart`.

### Feedback / State (4)

- [x] **LoadingView** — Centered spinner + optional message. `lib/ui/common/feedback.dart`.
- [x] **ErrorView** — Error icon + message + optional retry callback. `lib/ui/common/feedback.dart`.
- [x] **EmptyView** — Empty icon + message + optional action button. `lib/ui/common/feedback.dart`.
- [x] **StateSwitcher** — Generic state container. `LoadState` enum + 4 builders. Defaults to LoadingView/ErrorView/EmptyView. `lib/ui/common/feedback.dart`.

### Total: 16 widgets

_All implemented. Selection widgets (checkbox, switch) cut — revisit later._

## Rename Decision

`TextButton` was renamed to `GhostButton` to avoid shadowing `flutter/material.dart` TextButton. Done.

## Design Notes

- All widgets in `lib/ui/common/` derive theme from `AppComponentThemes` via context. No hardcoded colors.
- Follow existing convention: `as m` alias for `package:flutter/material.dart`.
- Props: required positional first, named optional after. `const` constructors.
- Typography widgets: thin Text wrappers, not rebuilds of TextTheme tokens. Compose via `Theme.of(context).textTheme`.

## Upcoming Sessions

- Research: more atomic widget patterns from production Flutter apps.
- Research: how `StateSwitcher` composes with BLoC/Cubit state classes.
- Dev: implement checklist items, TDD per project convention.
