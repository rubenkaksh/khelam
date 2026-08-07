# Turf Selection Screen + Shared Preferences Store — Implementation Plan

> **Spec:** `docs/superpowers/specs/2026-08-07-turf-selection-design.md` (LOCKED 2026-08-07, decisions #1–#12)

**Goal:** Replace the hardcoded turf id in the slots API call with a user-picked turf: entry turf-selection screen (dropdown of 2 raw UUIDs → Continue → persist), generic interface-driven `Preferences` store built forkable-first, logout clears it.

**Architecture (3 repos):** forkable (canonical `lib/data/storage/`) → pulled byte-identical into khelam + commons `DropdownInput<T>` widget → khelam turf feature (repo → cubit → view) → router/ScheduleCubit wiring.

**Order:** forkable storage → khelam pull + auth wiring → commons widget → khelam turf feature → khelam tests → full verification → commits (forkable first).

## Global Constraints
- No `!` / `as T` in hand-written Dart (type-promotion / `is` checks instead)
- Forkable-first: storage layer edited only in forkable; khelam copies byte-identical
- `.env` never staged; graphify-out/build/.dart_tool never staged
- Pre-commit gate runs analyze + full suite on Dart commits — don't bypass

---

## File Map

### forkable (canonical)
| File | Action |
|------|--------|
| `pubspec.yaml` | Add `shared_preferences` |
| `lib/data/storage/store_service.dart` | **Create** — `StoreService` interface (readString/writeString/delete/contains/clearAll) |
| `lib/data/storage/shared_prefs_store_service.dart` | **Create** — `SharedPrefsStoreService implements StoreService` (SharedPreferencesAsync) |
| `lib/data/storage/preferences.dart` | **Create** — `Preferences` interface (selectedTurfId/setSelectedTurfId/clear) |
| `lib/data/storage/preferences_impl.dart` | **Create** — `PreferencesImpl implements Preferences` (wraps StoreService) |
| `lib/di/service_locator.dart` | Register `StoreService` + `Preferences` (shared infra) |
| `test/data/storage/store_service_test.dart` | **Create** — round-trip/delete/contains/clearAll (setMockInitialValues) |
| `test/data/storage/preferences_impl_test.dart` | **Create** — typed accessors + clear |

### commons
| File | Action |
|------|--------|
| `lib/src/widgets/dropdown_input.dart` | **Create** — `DropdownInput<T>` (label/hint/error/enabled/items/value/onChanged) |
| `lib/commons.dart` | Export dropdown_input.dart |
| `test/dropdown_input_test.dart` | **Create** — renders label, items, onChanged, error, disabled |

### khelam
| File | Action |
|------|--------|
| `pubspec.yaml` | Add `shared_preferences` |
| `lib/data/storage/{store_service,shared_prefs_store_service,preferences,preferences_impl}.dart` | **Copy** byte-identical from forkable |
| `lib/di/service_locator.dart` | Register `StoreService` + `Preferences`; `scheduleCubit: (turfId) => …`; add `turfSelectionCubit` |
| `lib/features/auth/bloc/auth_cubit.dart` | Constructor + `preferences`; `logout()` clears `Preferences` |
| `lib/features/auth/di/auth_dependencies.dart` | Wire `preferences: locator<Preferences>()` |
| `test/helpers/recording_preferences.dart` | **Create** — `RecordingPreferences implements Preferences` |
| `lib/features/booking/data/turfs_repository.dart` | **Create** — interface `getTurfs()` |
| `lib/features/booking/data/mock_turfs_repository.dart` | **Create** — two UUIDs |
| `lib/features/booking/data/turfs_api_repository.dart` | **Create** — GET /turfs + dummy fallback |
| `lib/features/booking/bloc/turf_selection_cubit.dart` | **Create** — initialize/selectTurf/confirm + state |
| `lib/features/booking/views/turf_selection_view.dart` | **Create** — dropdown + Continue, auto-advance, Loading/Error |
| `lib/features/booking/di/booking_dependencies.dart` | `USE_MOCK_TURFS` switch; TurfsRepository; TurfSelectionCubit factory |
| `lib/ui/navigation/app_routes.dart` | Add `turfSelection`/`/select-turf` |
| `lib/ui/navigation/app_router.dart` | initialLocation → select-turf; public; schedule extra turfId; `ScheduleCubit Function(String)` |
| `lib/features/booking/bloc/schedule_cubit.dart` | `required String turfId` ctor; delete `_defaultTurfId`; use `_turfId` in selectDate/bookSlot |
| `lib/features/booking/views/schedule_view.dart` | Read turfId from route extra → `load(turfId:)` |
| `test/features/booking/turf_selection_cubit_test.dart` | **Create** — stored-pick/load/select/confirm |
| `test/features/booking/widgets/turf_selection_view_test.dart` | **Create** — two UUIDs, Continue gating, retry |
| `test/features/booking/data/mock_turfs_repository_test.dart` | **Create** |
| `test/features/booking/schedule_cubit_test.dart` | Update — constructor turfId |
| `test/features/auth/auth_cubit_test.dart` | Update — preferences fake; logout clears test |
| `test/widget_test.dart` | Check — boot path with RecordingPreferences |

## Verification sequence
1. forkable: `flutter analyze` + `flutter test` → commit + push (canonical)
2. commons: `flutter analyze` + `flutter test test/dropdown_input_test.dart` → commit + push
3. khelam: targeted tests per feature → full `flutter analyze` + `flutter test` (gate) → commit + push
4. Consumer check: after commons change, analyze khelam + forkable (both resolve commons)
5. Tripwire: `diff -rq -x __pycache__ forkable/scripts khelam/scripts` stays clean
