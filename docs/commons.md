# commons.md — Atomic Widgets Checklist (moved to `commons` package v0.1.0)

Status: migrated 2026-08-01 — all 21 widgets live in `~/projects/commons/lib/src/widgets/` and are exported via `package:commons/commons.dart`. This file is the roster manifest; keep it in sync with the commons package. Paths below point into the commons repo.

## v1 Widget Roster

### Buttons (5)

- [x] **PrimaryButton** — ElevatedButton wrapper. Primary action. `commons/src/widgets/buttons.dart`.
- [x] **FilledButton** — FilledButton wrapper. Secondary action. `commons/src/widgets/buttons.dart`.
- [x] **OutlineButton** — OutlinedButton wrapper. Tertiary action. `commons/src/widgets/buttons.dart`.
- [x] **GhostButton** — TextButton wrapper. Minimal/low-priority action. `commons/src/widgets/buttons.dart`. Renamed from `TextButton`.
- [x] **IconButton** — IconButton wrapper. Icon-only action. `commons/src/widgets/buttons.dart`.

### Inputs (5)

- [x] **TextInput** — TextFormField wrapper. Props: label, hint, error, enabled, obscure. `commons/src/widgets/inputs.dart`.
- [x] **PasswordInput** — TextFormField wrapper. Adds visibility toggle on obscure. `commons/src/widgets/inputs.dart`.
- [x] **SearchInput** — SearchBar wrapper. Props: hint, onChanged, controller. `commons/src/widgets/inputs.dart`.
- [x] **PhoneInput** — TextFormField wrapper with +977 prefix, 10-digit mobile validation. `commons/src/widgets/phone_input.dart`.

### Typography (4)

- [x] **Headline** — Typography widget. Size enum: `HeadlineSize.large | medium | small`. `commons/src/widgets/typography.dart`.
- [x] **Title** — Typography widget. Size enum: `TitleSize.large | medium | small`. `commons/src/widgets/typography.dart`.
- [x] **Body** — Typography widget. Size enum: `BodySize.large | medium | small`. `commons/src/widgets/typography.dart`.
- [x] **Label** — Typography widget. Size enum: `LabelSize.large | medium | small`. `commons/src/widgets/typography.dart`.

### Feedback / State (4)

- [x] **LoadingView** — Centered spinner + optional message. `commons/src/widgets/feedback.dart`.
- [x] **ErrorView** — Error icon + message + optional retry callback. `commons/src/widgets/feedback.dart`.
- [x] **EmptyView** — Empty icon + message + optional action button. `commons/src/widgets/feedback.dart`.
- [x] **StateSwitcher** — Generic state container. `LoadState` enum + 4 builders. Defaults to LoadingView/ErrorView/EmptyView. `commons/src/widgets/feedback.dart`.

### Status / Info (3)

- [x] **StatCard** — Compact metric tile (icon + label + value). `commons/src/widgets/stat_card.dart`.
- [x] **SectionHeader** — Row title + trailing chevron/action. `commons/src/widgets/section_header.dart`.
- [x] **StatusBadge** — Small status chip (check + "Booked"). Tone enum: `primary | success | warning | neutral`. `commons/src/widgets/status_badge.dart`.

### Containers (1)

- [x] **FormBottomSheet** — Modal bottom sheet with title, subtitle?, scrollable body, confirm/cancel CTAs, drag handle, keyboard safety. `commons/src/widgets/bottom_sheet.dart`. Use `showFormBottomSheet<T>()` to display.

### Total: 21 widgets

_All implemented. Selection widgets (checkbox, switch) cut — revisit later._

## Rename Decision

`TextButton` was renamed to `GhostButton` to avoid shadowing `flutter/material.dart` TextButton. Done.

## Design Notes

- All widgets in `commons/src/widgets/` derive theme from `AppComponentThemes` via context. No hardcoded colors.
- Follow existing convention: `as m` alias for `package:flutter/material.dart`.
- Props: required positional first, named optional after. `const` constructors.
- Typography widgets: thin Text wrappers, not rebuilds of TextTheme tokens. Compose via `Theme.of(context).textTheme`.

## Upcoming Sessions

- Research: more atomic widget patterns from production Flutter apps.
- Research: how `StateSwitcher` composes with BLoC/Cubit state classes.
- Dev: implement checklist items, TDD per project convention.
