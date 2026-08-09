# Design — Theme config implementation (gemini-code JSON → AppTheme)

Date: 2026-08-09 · Status: approved by user (brainstorming gate, 2 questions) · Implementation: khelam-only

## 1. Problem

The app theme (`lib/ui/core/app_theme.dart` + `lib/ui/core/theme/app_palette.dart`) is seed-based: `ColorScheme.fromSeed` derives everything from brand seeds (`#1A5F7A` etc.). A new light theme config was delivered as JSON (`docs/superpowers/specs/2026-08-09-theme-config.json`, originally `~/Downloads/gemini-code-1786262983859.json`): an explicit Material 3 light `colorScheme` (17 slots), 6 typography style overrides, and card/elevated-button/outlined-button component styles. The design must be implemented **into the app theme** without breaking the existing app pattern (commons = palette-agnostic shared layer; khelam owns palette + composition).

## 2. Scope

**In:** light `colorScheme` slots, typography overrides, `cardTheme` + `elevatedButtonTheme` + `outlinedButtonTheme`, `scaffoldBackgroundColor` → JSON `background` (#F9FAFA). Files touched: khelam `app_palette.dart`, `app_theme.dart`. Plus spec + JSON copy.

**Out (user decision, brainstorming Q1):** the JSON's custom `containerTheme` (timeSlotContainer / dateTileSelected / dateTileUnselected) is **documented here only** — the booking widgets (`DateChip`, `AvailableSlotCard`) are NOT edited in this pass. Values captured in §7 for a follow-up widget pass. No widget edits, no commons/pubspec changes, dark theme untouched.

## 3. Architecture (unchanged — pattern preserved)

```
AppPalette (khelam, raw color constants)
   └─ AppTheme.lightColorScheme()  ColorScheme.fromSeed(seed #097339) + explicit JSON slots
   └─ AppTheme typography layer    copyWith over commons AppTypography.textTheme()
   └─ AppTheme component layer     copyWith over commons ComponentThemes.build()
        └─ commons (untouched): palette-agnostic AppTypography + ComponentThemes
```

The existing roles hold: `AppPalette` = single color store; `AppTheme` = single composer (`app_theme.dart` doc comment: "Single source of truth for khelam ThemeData"); commons = shared, palette-agnostic, parameterized (`borderRadius`, `buttonShape`). The JSON overrides are applied **after** commons build so commons never knows about them.

## 4. Color scheme (light)

`AppTheme.lightColorScheme` becomes:

```dart
ColorScheme.fromSeed(
  seedColor: AppPalette.primary,      // #097339 (JSON primary → new light seed)
  brightness: Brightness.light,
  primary: AppPalette.primary,        // #097339
  onPrimary: AppPalette.onPrimary,    // #FFFFFF
  primaryContainer: AppPalette.primaryContainer,      // #E6F2EB
  onPrimaryContainer: AppPalette.onPrimaryContainer,  // #097339
  secondary: AppPalette.secondary,    // #FFFFFF
  onSecondary: AppPalette.onSecondary,// #1A1A1A
  background: AppPalette.background,  // #F9FAFA
  onBackground: AppPalette.onBackground, // #1A1A1A
  surface: AppPalette.surface,        // #FFFFFF
  onSurface: AppPalette.onSurface,    // #1A1A1A
  surfaceVariant: AppPalette.surfaceVariant,        // #F3F4F3
  onSurfaceVariant: AppPalette.onSurfaceVariant,    // #6B7280
  error: AppPalette.error,            // #D9534F
  onError: AppPalette.onError,        // #FFFFFF
  errorContainer: AppPalette.errorContainer,        // #FDEAEA
  onErrorContainer: AppPalette.onErrorContainer,    // #D9534F
  outline: AppPalette.outline,        // #E5E7EB
)
```

- `fromSeed` still generates the unmentioned slots (`surfaceContainerLow` — consumed by commons `canvasColor`, `outlineVariant` — consumed by commons `dividerColor`, `surfaceContainer*`, `inverse*`, `surfaceTint`) from seed #097339, so `ComponentThemes.build` keeps working.
- **Dark scheme: untouched.** `darkColorScheme` keeps seed `#1A5F7A`, `primary: surfaceTintDark`, `error: errorDark`. JSON is light-only (`"brightness": "light"`).
- `AppPalette.error` value changes `#BA1A1A` → `#D9534F`. Verified light-only: dark's error slot uses `AppPalette.errorDark` (#FFB4AB); `AppPalette.error` has no consumers outside `app_theme.dart` (grep-verified).
- `AppPalette.seed` (#1A5F7A), `secondarySeed`, `tertiarySeed`, `surfaceTintLight` (currently unused), `surfaceTintDark` remain; they back the dark scheme. `seed`'s light-scheme role moves to `AppPalette.primary`.

### 4.1 Scaffold background (user-approved adjustment)

`scaffoldBackgroundColor` → `AppPalette.background` (#F9FAFA) via a khelam `copyWith` (commons hardcodes `colorScheme.surface` — leave commons alone; the khelam override wins). The JSON's `background` slot is therefore **not** inert; the app canvas becomes the warm off-white. `canvasColor` (surfaceContainerLow, generated) stays as commons sets it.

## 5. Typography

Applied as a khelam layer in `AppTheme` (private helper) on top of `commons.AppTypography.textTheme(colorScheme)`:

| Style | fontSize | fontWeight | color (role) | vs commons today |
|---|---|---|---|---|
| headlineSmall | 18 | w700 | onSurface | size 24→18, w500→w700 |
| titleMedium | 16 | w600 | onSurface | ≈unchanged |
| titleSmall | 14 | w600 | onSurface | ≈unchanged |
| bodyMedium | 13 | w400 | onSurfaceVariant | size 14→13, color onSurface→onSurfaceVariant |
| labelLarge | 16 | w700 | onPrimary | size 14→16, w600→w700, color→onPrimary |
| labelSmall | 11 | w500 | onSurfaceVariant | w600→w500, color→onSurfaceVariant |

- Colors are **role references** (resolved from the active `ColorScheme`), so the same layer is brightness-safe and is applied to both light and dark `ThemeData` (dark's roles resolve against the dark scheme).
- `fontFamily: "System"` (JSON) is skipped — the platform default font is System; setting the literal string adds nothing.
- JSON `description` fields are documentation-only (already captured in the JSON copy).

## 6. Material components (khelam copyWith layer)

Added in `AppTheme` after `ComponentThemes.build(...)`:

- **cardTheme**: `CardThemeData(color: colorScheme.surface, elevation: 2, shadowColor: Color(0x1A000000), shape: RoundedRectangleBorder(borderRadius: 24))`
- **elevatedButtonTheme**: bg `primary` / fg `onPrimary`, elevation `0`, `padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24)`, `shape: RoundedRectangleBorder(borderRadius: 100)` (pill)
- **outlinedButtonTheme**: bg `surface` / fg `primary`, `side: BorderSide(color: outline, width: 1)`, `padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16)`, pill (radius 100)

Deliberately **scoped**: commons defaults (radius-12 inputs/lists/snackbars, pill-20 elsewhere) stay put — the JSON only specifies card + buttons. `borderRadius`/`buttonShape` params of `ComponentThemes.build` are NOT repurposed (they'd bleed into inputs/lists).

## 7. Captured follow-up (out of scope this pass)

JSON `containerTheme` — booking screen containers, current state in parentheses:

| Slot | Value | Current widget state |
|---|---|---|
| defaultShape | radius 16 | n/a |
| timeSlotContainer | bg surfaceVariant #F3F4F3, radius 16, padding v16/h20 | `AvailableSlotCard`: Card, radius 12, outline border, bg surface |
| dateTileSelected | bg primary, radius 16 | `DateChip` selected: bg primary ✓, radius 24 |
| dateTileUnselected | bg surfaceVariant, radius 16 | `DateChip` unselected: bg surfaceContainerHighest, radius 24 |

Follow-up pass: restyle `DateChip` + `AvailableSlotCard` to consume these (likely as a khelam `ThemeExtension`), per user's "theme layer only" scope decision.

## 8. Files

- `lib/ui/core/theme/app_palette.dart` — add 18 constants (17 slots + `cardShadow`), change `error` value.
- `lib/ui/core/app_theme.dart` — light scheme rewrite (§4), typography layer (§5), component layer (§6), scaffold bg (§4.1). Private helpers keep the composer readable.
- `docs/superpowers/specs/2026-08-09-theme-config.json` — source-of-truth copy (provenance; Downloads is ephemeral).
- No changes to: commons, pubspec, widgets, tests (no theme tests exist).

## 9. Verification

- `flutter analyze` (khelam only — commons and pubspec untouched, no consumer check required).
- Full test suite via the pre-commit gate (`scripts/pre_commit_check.sh`: analyze + `flutter test`).
- Eyeball: `ThemePreviewView` (theme preview feature) + booking screen (optional screenshot via `capture_screens.sh` if the user wants).

## 10. Rollout

Single commit batch (spec commit separate, per repo practice of doc commits). No feature-branch dance; khelam `main`; push deferred unless user asks (global rule).
