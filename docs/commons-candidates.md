# Commons Migration — Phase 1 Candidate Manifest

Generated: 2026-08-01 · Scope: shared-code locations in khelam (`lib/ui/common/`,
`lib/core/network/`, `lib/ui/core/`, `lib/ui/navigation/`) compared against
forkable (base) — rename-aware per Phase 1 rules.

## Slice 1 — `lib/ui/common/` (the atomic widget catalog, 9 files)

| File | Bucket | Reasoning |
|---|---|---|
| `buttons.dart` | **MIGRATE (dedup)** | byte-identical to base copy → commons becomes canonical; delete both |
| `inputs.dart` | **MIGRATE (dedup)** | byte-identical to base copy |
| `typography.dart` | **MIGRATE (dedup)** | byte-identical to base copy |
| `feedback.dart` | **MIGRATE (divergent)** | base copy uses `message!` force-unwrap; child is `!`-free (`if case final String text`) — child version is canonical (AGENTS.md rule) |
| `bottom_sheet.dart` | **NEW** | absent in base; child-only; has test (`test/ui/common/bottom_sheet_test.dart`) |
| `phone_input.dart` | **NEW** | absent in base; child-only; has test |
| `section_header.dart` | **NEW** | absent in base; child-only; no test |
| `stat_card.dart` | **NEW** | absent in base; child-only; no test |
| `status_badge.dart` | **NEW** | absent in base; child-only; no test |

Coupling: all 9 import only `package:flutter/material.dart` → **clean**.
Hardcoded values: none (no app name, URLs, or colors).
Tests: 2 of 9 have tests (`bottom_sheet`, `phone_input`) — they travel with the code.

## Slice 2 — `lib/core/network/` (1 file)

| File | Bucket | Reasoning |
|---|---|---|
| `dio_api_client.dart` | **MIGRATE (divergent)** | base copy lives at `lib/data/services/dio_api_client.dart` (pre-ADR-0004 path); child moved it to `lib/core/network/` and extended it (`getJsonList()`, `_expectObject()`). Imports only `dio` → **clean**. `baseUrl` is an injected constructor param (no hardcoded URL). Child version is canonical. |

## Slice 3 — `lib/ui/core/` theme (4 files)

| File | Bucket | Reasoning |
|---|---|---|
| `app_component_themes.dart` | **MIGRATE (dedup)** | byte-identical to base copy |
| `app_typography.dart` | **MIGRATE (dedup)** | byte-identical to base copy |
| `app_theme.dart` | **MIGRATE (divergent)** | differs only in doc comments ("forkable" vs "khelam" wording) → neutralize wording in commons |
| `theme/app_palette.dart` | **MIGRATE (divergent)** | differs only in doc-comment brand wording; values identical. The `Color(0x…)` constants ARE the shared design tokens (palette is the API, not a hardcoded-value violation) |

## Slice 4 — `lib/ui/navigation/` (2 files)

| File | Bucket | Reasoning |
|---|---|---|
| `app_routes.dart` | **MIGRATE (divergent)** — *decision needed* | child adds `schedule`/`schedulePath`; otherwise identical. Route-name constants are arguably fork-specific; move or leave per Phase 2 |
| `app_router.dart` | **COUPLED** — *decision needed* | imports 6 feature files (`auth_cubit`, `login_view`, `schedule_cubit`, `schedule_view`, `home_view`, `theme_preview_view`) → cannot move as-is. Recommended: **leave in child** (router is app composition; features are fork-owned per ADR-0004) |

## BASE-LEGACY (base-only — out of scope this pass, delete during base's commons adoption)

| File (in forkable) | Reasoning |
|---|---|
| `lib/data/services/local_sample_storage_service.dart` | pre-ADR-0004 leftover; no child counterpart |
| `lib/data/services/mock_auth_service.dart` | same |
| `lib/data/services/sample_api_service.dart` | same |
| `lib/data/services/template_catalog_service.dart` | same |
| `lib/data/services/dio_api_client.dart` | superseded by commons Slice 2 (delete when base adopts) |

## Recommendations
1. **Phase 3 executes Slice 1 only** (9 widgets) — cleanest first pass, real test gate (2 tests travel).
2. Slice 2 (DioApiClient) next; Slice 3 (theme) after; both are coupling-clean.
3. `app_router.dart`: leave in child. `app_routes.dart`: leave in child unless commons wants template route names.
4. Base adoption deletes: `lib/ui/common/{buttons,feedback,inputs,typography}.dart`, `lib/data/services/dio_api_client.dart`, plus the 4 BASE-LEGACY services.
