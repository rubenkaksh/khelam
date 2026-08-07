# Design — Turf Selection screen + shared Preferences store

> Date: 2026-08-07. Status: **LOCKED (user-approved 2026-08-07)** — after brainstorming round. Lives at `docs/superpowers/specs/` (matches the 2026-08-06/07 precedent for non-declared-feature specs).

## 1. Purpose

Replace the hardcoded turf id (`ScheduleCubit._defaultTurfId = '44444444-4444-4444-4444-444444444441'`, which today feeds the slots API call) with a user-picked turf. On entry the user lands on a turf-selection screen with a 2-option dropdown; picking one persists it and the current flow (schedule) begins with the selected id. The screen is the **foundation** for a future richer turf-selection screen (named accordingly), the dropdown is a shared commons widget, and the persistence layer is a **generic, interface-driven Preferences store built forkable-first** so it can later back onto a typed store (Hive/Isar).

## 2. Locked decisions (user, 2026-08-07)

| # | Decision | Constraint |
|---|----------|------------|
| 1 | **Forkable-first**: the generic storage layer (`StoreService`, `SharedPrefsStoreService`, `Preferences`, `PreferencesImpl`) is canonical in `forkable/lib/data/storage/`; khelam pulls byte-identical copies. khelam never edits it forkable-first. | forkable = base template; shared capabilities forkable-first (OA#5 policy) |
| 2 | **Persistence backing = `shared_preferences`** (new dependency, `SharedPreferencesAsync` API). Chosen over reusing `flutter_secure_storage`: non-sensitive preferences belong in a plain prefs store; secure storage stays for auth tokens only. | User: "shared_prefs" |
| 3 | **Interface-driven store, Hive/Isar-ready**: `StoreService` is a key-value contract; `SharedPrefsStoreService` is today's impl; a future `DbStoreService` (Hive/Isar typed store) swaps in via DI with zero caller changes. | User: "generic + interface driven (preferences-session helper + storeservice-db/shared-prefs)" |
| 4 | **Helper naming (user override)**: `Preferences` (interface) + `PreferencesImpl` (impl wrapping a `StoreService`). All other names as proposed: `StoreService`, `SharedPrefsStoreService`, `DropdownInput<T>`, `TurfSelectionView`, `TurfSelectionCubit`, `TurfsRepository`, `MockTurfsRepository`, `TurfsApiRepository`. | User: "Lets call the Preferences and PreferencesImpl. thats it all other name are approved." |
| 5 | **Auth session vs preferences stay separate**: tokens (secrets) remain in `AuthTokenStore` (secure storage); `Preferences` holds only non-sensitive preferences (e.g. `selectedTurfId`). | Security boundary |
| 6 | **Data layer = new `TurfsRepository`** (`getTurfs() → List<TurfSummary>`): `MockTurfsRepository` returns the two UUIDs; `TurfsApiRepository` hits `GET /turfs` with dummy-fallback until the backend ships it. Env switch `USE_MOCK_TURFS` mirrors `USE_MOCK_BOOKING`. | User: "cubit -> repo -> api" |
| 7 | **Dropdown labels = raw UUIDs** (`44444444-…4441`, `2f293756-…2ea6`). `TurfSummary.name` still exists in the model for future use. | User: "Show the raw UUIDs" |
| 8 | **`ScheduleCubit._defaultTurfId` deleted**; `ScheduleCubit` takes `required String turfId` (from the route). `load({String? turfId})` falls back to the constructor id. `selectDate`/`bookSlot` use it. | User: "Remove it (Recommended)" — its TODO asks exactly for this |
| 9 | **Entry flow**: new public route `turf-selection` becomes `initialLocation`. `TurfSelectionCubit.initialize()` reads `Preferences.selectedTurfId()`: stored pick → auto-advance to schedule; none (first-time) → dropdown + **Continue button** → persist → navigate. | User: "First time user lands on the dropdown screen… selects the id and moves ahead"; "continue" |
| 10 | **No `!`/`as` force operators** in hand-written Dart (global hard rule). Route `extra` read via `is String` promotion. | Global Flutter tier-1 rule |
| 11 | **Known debt (recorded, NOT now)**: khelam's auth has outgrown forkable (`AuthTokenStore`/secure storage absent in forkable). A future forkable-sync pass is required; logged in backlog + §9. | User: "this has to sync not right now but has to" |
| 12 | **Logout clears preferences too**: `AuthCubit.logout()` clears the persisted session **and** `Preferences.clear()` (khelam-only — forkable's AuthCubit adopts `Preferences` during the future auth-sync pass). Next launch after logout = first-time flow (dropdown again). | User: "On logout clear the preferences as well" |

## 3. Repositories & files

### forkable (canonical) — `lib/data/storage/`
- `store_service.dart` — `abstract interface class StoreService { Future<String?> readString(String key); Future<void> writeString(String key, String value); Future<void> delete(String key); Future<bool> contains(String key); Future<void> clearAll(); }` — `clearAll()` wipes the whole store (safe: `StoreService` holds only preference keys; auth tokens live in `AuthTokenStore`'s separate secure storage).
- `shared_prefs_store_service.dart` — `SharedPrefsStoreService implements StoreService` (wraps `SharedPreferencesAsync`).
- `preferences.dart` — `abstract interface class Preferences { Future<String?> selectedTurfId(); Future<void> setSelectedTurfId(String turfId); Future<void> clear(); }` (future typed properties land here).
- `preferences_impl.dart` — `PreferencesImpl implements Preferences` (wraps any `StoreService`, defaults to `SharedPrefsStoreService`); `clear()` delegates to `StoreService.clearAll()`.
- DI: shared-infra registrations in `lib/di/service_locator.dart` (`StoreService` → `SharedPrefsStoreService`; `Preferences` → `PreferencesImpl(store: locator<StoreService>())`).
- Deps: `shared_preferences` added to `pubspec.yaml`.
- Tests: `test/data/storage/` (`SharedPreferences.setMockInitialValues`).

### khelam — pulled copies + feature
- `lib/data/storage/` — byte-identical copies of the four forkable files; same DI registration; `shared_preferences` added.
- `lib/features/booking/data/turfs_repository.dart` — interface.
- `lib/features/booking/data/mock_turfs_repository.dart` — the two UUIDs (`TurfSummary(id: '44444444-4444-4444-4444-444444444441', …)`, `id: '2f293756-5cc8-41a4-be78-89e13c2d2ea6'`), 100ms-delay style of `MockBookingService`.
- `lib/features/booking/data/turfs_api_repository.dart` — `GET /turfs` via `DioApiClient`; dummy-fallback (same TODO pattern as `BookingApiService.getTurf`).
- `lib/features/booking/bloc/turf_selection_cubit.dart` — state `{turfs, selectedTurfId, isLoading, errorMessage, storedTurfId}`; `initialize()` / `selectTurf(id)` / `confirm()` (persists via `Preferences`).
- `lib/features/booking/views/turf_selection_view.dart` — `LoadingView` / `ErrorView(retry)` / `DropdownInput` + `Continue` button; auto-advance when `storedTurfId` present.
- `lib/features/booking/di/booking_dependencies.dart` — `USE_MOCK_TURFS` switch; `TurfsRepository` singleton; `TurfSelectionCubit` factory (`Preferences` + `TurfsRepository`).
- `lib/features/auth/bloc/auth_cubit.dart` — constructor gains `required Preferences preferences`; `logout()` calls `_preferences.clear()` alongside `_tokenStore.clear()` (best-effort, same try/catch). Wired in `lib/features/auth/di/auth_dependencies.dart` (`preferences: locator<Preferences>()`).
- Router (`lib/ui/navigation/app_router.dart` + `app_routes.dart`): `turfSelection`/`/select-turf` public, `initialLocation`; schedule route passes `turfId` via `extra`; `ScheduleCubit Function(String turfId)`.
- `test/helpers/recording_preferences.dart` — `RecordingPreferences implements Preferences` (mirrors `RecordingTokenStore`).

### commons — widget
- `lib/src/widgets/dropdown_input.dart` — `DropdownInput<T>`: `label`, `hint`, `error`, `enabled`, `items: List<(T value, String label)>`, `value: T?`, `onChanged: ValueChanged<T?>`. Built on `DropdownButtonFormField` with the `InputDecoration` style of the input family. Exported from `lib/commons.dart`.
- `test/dropdown_input_test.dart`.

## 4. Data flow

```
launch ──> /select-turf (initialLocation, public)
            TurfSelectionCubit.initialize()
              ├─ Preferences.selectedTurfId() != null ──> auto-advance
              │      context.goNamed(schedule, extra: storedTurfId)
              └─ null (first-time)
                     TurfsRepository.getTurfs()  ──> List<TurfSummary> (2 UUIDs)
                     DropdownInput (raw UUID labels)
                     Continue ──> confirm() ──> Preferences.setSelectedTurfId(id)
                            ──> context.goNamed(schedule, extra: id)
                                                    │
                                                    ▼
            ScheduleCubit(turfId: id) ──> load() ──> getTurf(id) + getSchedule(turfId, date)
            selectDate / bookSlot ──> turfId (constructor id)  [no hardcoded fallback]

logout ──> AuthCubit.logout() ──> _service.logout() + _tokenStore.clear()
                                        + Preferences.clear()   [decision #12]
        ──> next launch: /select-turf first-time flow again
```

## 5. Error handling
- Turf list load failure → `ErrorView(message, onRetry: initialize/load)` (mirrors `schedule_view.dart` retry pattern).
- Schedule errors: unchanged (`Could not load schedule.` etc.).
- `extra` missing on schedule route (defensive) → turfId null → `load(turfId: null)` falls back to constructor id; no crash.
- Persistence failures: `confirm()` surfaces `errorMessage` on the selection screen; selection retained for retry.

## 6. Testing

| Layer | Test | Notes |
|---|---|---|
| commons | `dropdown_input_test.dart` | renders label, shows items, onChanged fires, error shown, disabled |
| forkable | `store_service`/`preferences` tests | `SharedPreferences.setMockInitialValues`; round-trip, delete, contains |
| khelam | `turf_selection_cubit_test.dart` | stored-pick → auto-advance state; no-pick → list load; select; confirm persists |
| khelam | `turf_selection_view_test.dart` | two UUIDs in dropdown, Continue gating, retry path |
| khelam | `mock_turfs_repository_test.dart` | returns exactly the two UUIDs |
| khelam | `schedule_cubit_test.dart` (updated) | constructor `turfId` threaded through load/selectDate/bookSlot |
| khelam | `auth_cubit_test.dart` (updated) | logout clears `Preferences` (RecordingPreferences fake); constructors gain the fake |
| khelam | `test/widget_test.dart` (check) | app boot may now land on turf-selection; needs `RecordingPreferences` |

Validation before commit: `flutter analyze` + full suite in commons, khelam, forkable (pre-commit gate runs on Dart commits; commons-consumer check after any commons change).

## 7. Acceptance bar
- Launch with no stored pick → dropdown with exactly the two UUIDs; Continue disabled until a pick; Continue persists and lands on schedule showing that turf's slots.
- Second launch (stored pick) → skips straight to schedule with the persisted id.
- **Logout** clears the persisted session + preferences → next launch shows the dropdown again (first-time flow).
- `ScheduleCubit._defaultTurfId` gone; no hardcoded turf id remains in lib code.
- Storage layer exists byte-identical in forkable + khelam behind `StoreService`/`Preferences` interfaces.
- All tests green in three repos; analyze clean.

## 8. Naming — alternatives considered
- Helper: `PreferencesSession`/`SessionPreferences` → **user overrode to `Preferences`/`PreferencesImpl`** (decision #4).
- Widget: `DropdownInput<T>` over `SelectInput`/`DropdownField` — matches `TextInput`/`PasswordInput`/`SearchInput` family; generic for value/label separation.
- Screen: `TurfSelectionView`/`TurfSelectionCubit` — foundation-named so a future map/list turf picker replaces internals while the cubit contract stays.

## 9. Out of scope / known debt
- **Forkable auth sync** (decision #11): khelam's `AuthTokenStore`/secure-storage auth outgrew forkable — future sync pass, not now.
- **Real `GET /turfs` backend**: `TurfsApiRepository` dummy-fallback until the NestJS endpoint exists.
- **Hive/Isar `DbStoreService`**: interface reserved, not built.
- **Friendly turf labels / maps picker**: future turf-selection evolution (foundation in place).
