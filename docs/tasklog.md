# Task Log — khelam (live task board)

> Trello-style status board. **This is the single live view of all pending work.** Updated continuously — every session opens this file, moves cards as state changes, and commits it with the day's work.
> Statuses: 🔴 Active / 🟡 Backlog / 🟠 Parked / ⚪ Descoped / ⚠️ User actions / 📋 Closed.
> Source of detail: `docs/backlog.md` (per-item history) + `docs/reviews/review-memory.md` (Open Actions). Cards here link back; do not duplicate their full text.
> **Discord comms must mirror this structure** (`#daily-overview` + `#weekly-reviews`) so the channels read like this board.

_Last updated: 2026-08-08_

## 🔴 Active queue
| Card | Scope | Effort | Status |
|---|---|---|---|
| **Auto-digest reliability — catch-up + retry** (from 2026-08-08 brainstorm; spec `docs/superpowers/specs/2026-08-08-auto-digest-reliability-design.md`) | ops/scripts (forkable-first) | S | **Design approved 08-08** (user + @architect) — implement: RunAtLoad + marker/lock + retry + 14-day catch-up (parallel ops thread, no Flutter impact) |
| **Theme + real-user-flow pass** (post-robustness; from 2026-08-08 session objective) | khelam | M | **NEXT pickup** — spec the theme/real-user-flow slice first |

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
| **T4 — Analytics** (was DESCOPED → parked 08-07) | **2026-08-16** | plan properly or drop |
| **T6 — Perf/rebuild hygiene + Samseer-in-prod gate** (was DESCOPED → parked 08-07) | **2026-08-16** | re-add when needed |
| **macOS DMG verification** | **2026-08-16** | release DMG launches to a **blank screen** (user 08-07) — diagnose or drop macOS distribution |

## ⚪ Descoped (reopen when user decides)
- **Google sign-in + credential rotation (Action #1)** — DESCOPED 2026-08-08 (user: google_sign_in had issues, low priority; pick up when he decides). Server client ID `91250679358-frejgd…` is **still leaked in git history + live** — rotation NOT done; reopen this card with the rotation runbook when Google login returns.

## 📋 Closed / superseded (2026-08-07)
- **Real auth/JWT wiring** (07-31) — CLOSED: `setBearerToken` wired (`auth_api_service.dart:107,143`); `booking_flow` integration 2/2 live on iOS sim.
- **UI screenshot verification** (08-06) — CLOSED: superseded by OA#6 `capture_screens.sh` (`ec178eb`, `b815d6c`).
- **Discord go-live** (08-08) — CLOSED: `~/.config/opencode/discord.env` filled (mode 600), `REPORT_SINK=discord_webhook` in both plists (forkable `acbbf04`, khelam `d072c6c`), digest plist installed + weekly plist reloaded, E2E digest run. **All 5 webhooks live-verified 08-08**: daily-overview ✅, weekly-reviews ✅, screenshots ✅ (multipart — real 1320×2868 screenshot uploaded), agent-errors ✅, default ✅ (after fixing missing leading `h` in `DISCORD_WEBHOOK_URL` → `curl: Protocol "ttps" not supported`). First auto-digest: Mon 08-10 08:00.
- **[T1] Security gate** — CLOSED: `.env` de-tracked + gitignored (khelam `9445e2d`, forkable `c067908`).
- **T2 — Shared error mapping** (08-08) — CLOSED: `AppException` sealed hierarchy + `DioApiClient.mapDioException` (commons v0.7.0 `827f940`), cubit/service surface `e.message`, EmptyView; khelam `b1ecd81`; suites green.
- **T3 — Retry + connectivity-aware** (08-08) — CLOSED: commons `RetryInterceptor` GET-only retry (v0.7.1 `203af79`), TurfsApiRepository 404-only fallback (offline/5xx now propagate typed), wired in DI; khelam `d513184`; suites green.
- **T5 — In-session GET cache** (08-08) — CLOSED: `DioApiClient` GET cache, 30s TTL, keyed path+query, flushed on successful POST (booking visibility) + token change (account boundary); commons v0.7.2 `a8f1211`; khelam no change needed (transparent); 93/93 + 57/57. **Robustness batch T2→T3→T5 COMPLETE.**
