# Task Log — khelam (live task board)

> Trello-style status board. **This is the single live view of all pending work.** Updated continuously — every session opens this file, moves cards as state changes, and commits it with the day's work.
> Statuses: 🔴 Active / 🟡 Backlog / 🟠 Parked / ⚪ Descoped / ⚠️ User actions / 📋 Closed.
> Source of detail: `docs/backlog.md` (per-item history) + `docs/reviews/review-memory.md` (Open Actions). Cards here link back; do not duplicate their full text.
> **Discord comms must mirror this structure** (`#daily-overview` + `#weekly-reviews`) so the channels read like this board.

_Last updated: 2026-08-07_

## 🔴 Active queue
| Card | Scope | Effort | Status |
|---|---|---|---|
| **T2 — Shared error mapping** (`AppException` + `DioApiClient` 4xx/5xx/timeout mapping; drop `catch (_)` in `schedule_cubit.dart:95,121,156` + `turf_selection_cubit.dart:78`; `EmptyView` for zero slots) | commons-first → khelam | M | **NEXT pickup** |
| **T3 — Retry + connectivity-aware** (`RetryInterceptor`, backoff; kill stale-turf masking in `TurfsApiRepository`) | commons-first | M | after T2 |
| **T5 — In-session GET cache** (~30s TTL, re-selects served from memory) | commons-first | M | after T3 |

## 🟡 Backlog (open, not scheduled)
| Card | Source | Status |
|---|---|---|
| **Turfs endpoint (backend)** — `GET /turfs/:id` missing; `BookingApiService.getTurf` hardcoded | backlog 07-31 | Open — backend gap, blocks [C5] close |
| **[C5] BookingService drift (remaining)** — `getTurf` hardcoded until backend endpoint exists | backlog 08-01 | Waits on backend |
| **Revenue stat ₹0 in API mode** — backend must include booking details on slots list | backlog 08-01 | Backend gap |
| **Real home experience** — `home_view.dart` placeholder; design post-login home | backlog 08-01 | Open — needs design |
| **Auth-sync debt** — forkable lacks `AuthTokenStore`/secure storage; sync when auth lands forkable-first | backlog 08-07 | Open |
| **Theme monolith watchpoint** — split `app_component_themes.dart` if `build()` > ~600 lines / feature variants appear | backlog 06-22 | Watchpoint |
| **Navigation slice (low priority)** — shared router skeleton, revisit only if wanted | backlog 08-01 | Open (low) |

## 🟠 Parked (revisit at the 2026-08-16 review unless noted)
| Card | Revisit | Note |
|---|---|---|
| **Task dashboard** (standalone Flutter + Supabase, est ~28–34k) | **2026-08-16** | DROP if Discord covers the review surface, else re-estimate |
| **Discord go-live steps** (env file, plist install, live E2E) | user request | OA#8 impl is the next queue; must mirror this board's structure |
| **T4 — Analytics** (was DESCOPED → parked 08-07) | **2026-08-16** | plan properly or drop |
| **T6 — Perf/rebuild hygiene + Samseer-in-prod gate** (was DESCOPED → parked 08-07) | **2026-08-16** | re-add when needed |
| **macOS DMG verification** | **2026-08-16** | release DMG launches to a **blank screen** (user 08-07) — diagnose or drop macOS distribution |

## ⚠️ User actions (flagged, not agent tasks)
1. **Rotate leaked Google SERVER client ID** on Google Cloud Console (from T1; optional `filter-repo` history purge later)
2. **Discord go-live**: create `~/.config/opencode/discord.env` + install digest plist (agent never auto-installs launchd jobs)

## 📋 Closed / superseded (2026-08-07)
- **Real auth/JWT wiring** (07-31) — CLOSED: `setBearerToken` wired (`auth_api_service.dart:107,143`); `booking_flow` integration 2/2 live on iOS sim.
- **UI screenshot verification** (08-06) — CLOSED: superseded by OA#6 `capture_screens.sh` (`ec178eb`, `b815d6c`).
- **[T1] Security gate** — CLOSED: `.env` de-tracked + gitignored (khelam `9445e2d`, forkable `c067908`).
