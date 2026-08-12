# Task Log — khelam (live task board)

> Trello-style status board. **This is the single live view of all pending work.** Updated continuously — every session opens this file, moves cards as state changes, and commits it with the day's work.
> Statuses: 🔴 Active / 🟡 Backlog / 🟠 Parked / ⚪ Descoped / ⚠️ User actions / 📋 Closed.
> Source of detail: `docs/backlog.md` (per-item history) + `docs/reviews/review-memory.md` (Open Actions). Cards here link back; do not duplicate their full text.
> **Discord comms must mirror this structure** (`#daily-overview` + `#weekly-reviews`) so the channels read like this board.

_Last updated: 2026-08-12_

## 🔴 Active queue
| Card | Scope | Effort | Status |
|---|---|---|---|
| **Theme + real-user-flow pass** (post-robustness; from 2026-08-08 session objective) | khelam | M | **Theme-config slice DONE 08-09** (spec `2026-08-09-theme-config-design.md` — light palette #097339, typography, card/button themes, canvas #F9FAFA; dark untouched; containerTheme follow-up DESCOPED 08-12 — see ⚪). Remaining: **real-user-flow pass** |

## 🟡 Backlog (open, not scheduled)
| Card | Source | Status |
|---|---|---|
| **Auth-sync debt** — forkable lacks `AuthTokenStore`/secure storage; sync when auth lands forkable-first | backlog 08-07 | Open |
| **[C5] BookingService drift (remaining)** — `getTurf` hardcoded until backend endpoint exists | backlog 08-01 | Waits on backend |
| **Turfs endpoint (backend)** — `GET /turfs/:id` missing; `BookingApiService.getTurf` hardcoded | backlog 07-31 | Open — backend gap, blocks [C5] close |
| **Navigation slice (low priority)** — shared router skeleton, revisit only if wanted | backlog 08-01 | Open (low) |
| **Theme monolith watchpoint** — split `app_component_themes.dart` if `build()` > ~600 lines / feature variants appear | backlog 06-22 | Watchpoint |

## 🔧 Self-improvement — agent-tools/loop E2E (from 2026-08-11 improve-codebase-architecture run; **pick up only with user approval, by priority**)
| Priority | Card | Test verdict | Status |
|---|---|---|---|
| **HIGH** | **C2 — `loop_verify.sh` has NO test harness** (the only verifier with zero tests; P1's 9 fixtures were throwaway). **TOP RECOMMENDATION** | ADD — extract fixture-driven harness (P1 9-fixture suite → re-runnable) | ⏳ Awaiting approval → ✅ **DONE 08-11** (agent-tools `7b7d73a`) |
| **HIGH** | **C1 — `VERSION` file is stale/redundant pin** (agent-tools `VERSION=18dbd2a-cut` never updated; real pins live in consumers' `agent-tools.version`; README cites VERSION as the source) | DELETE — zero behavioral impact | ⏳ Awaiting approval → ✅ **DONE 08-11** (agent-tools `7b7d73a`) |
| **HIGH** | **C3 — stale "forkable-first" prose** (khelam + forkable AGENTS.md still say canonical = forkable; superseded by the agent-tools pivot 08-11; also misroutes the tripwire doc) | DELETE — docs-only, safe | ⏳ Awaiting approval → ✅ **DONE 08-11** (agent-tools `7b7d73a`) |
| **HIGH** | **C4 — daily_triage skill-chain bypass + budget unenforced** (loop-triage skill references loop-constraints/loop-budget, but the L1 default run loads neither; `loop status` says budget.present=true but nothing enforces the 80% cap) | REFACTOR — enforce in `daily_triage.sh` | ⏳ Awaiting approval → ✅ **DONE 08-11** (agent-tools `7b7d73a`) |
| **MED-HIGH** | **C5 — `weekly_review.sh` cohesion** (900+ lines, 18 computed lines / 6 helpers / prompt built across 4 functions, runs against two repos; phase boundaries unclear) | REFACTOR — extract review-else branch to module | ⏳ Awaiting approval |
| **MEDIUM** | **C6 — wrapper collapse** (16 thin wrappers per consumer; merge back to direct `exec`? — needs Grill Gate, user decision) | GRILL GATE before any change | ⏳ Awaiting approval |
| **MEDIUM** | **C7 — melos workspace machine-local** (`melos.yaml` at `~/projects/khel-service/`, not a git repo — parked 08-08, revisit 08-16) | — (revisit at 08-16 review) | ⏳ Awaiting approval |
| **MEDIUM** | **C8 — `sync_loop_state.sh` awk coupling** (STATE.md splice via awk getline — fragile) | REFACTOR — python splice | ⏳ Awaiting approval |
| **LOW** | **C9 — `LOOP.md` broken links** (references missing `../patterns/daily-triage.md` etc. — targets verified nonexistent 08-12) | FIX — trivial → **autonomous card C11 (🤖 queue)** | ⏳ Awaiting approval → ✅ **DONE 08-12** (autonomous C11, draft-PR) |
| **LOW** | **C10 — routing sync tripwire + zoom-out gap** (weekly routing-check greps bare `skill` — misses zoom-out/others; no zoom-out callout in routing doc) | REFINE — tripwire operational; refine copy + routing | ⏳ Awaiting approval |

## 🤖 Autonomous queue (executor-owned — user flips ⏳ → ✅ Approved + fills Estimate + Done when)
| Card | Scope | Estimate (min) | Depends on | Done when | Status |
|---|---|---|---|---|---|
| C11 | khelam | 5 | | LOOP.md Links section cleaned: remove the two dead entries (`../../patterns/daily-triage.md`, `../../docs/loop-design-checklist.md` — targets verified nonexistent) or re-point to live docs; commit to a new feature branch + draft-PR only; resolves tasklog C9 | ✅ Done 08-12 — re-pointed to `skills/loop-triage/SKILL.md` + `docs/superpowers/specs/2026-08-11-loop-engineering-design.md` (draft-PR)
| C12 | khelam + commons | 60 | | LoadingView (commons `lib/src/widgets/feedback.dart`) stops showing the old loader: add `flutter_skeletonizer` to commons pubspec and refactor LoadingView to render a skeleton; create a skeleton widget for the BookingTimeline use case (khelam `lib/features/booking/widgets/booking_timeline.dart`, rendered at `schedule_view.dart:89`/`104-108`) and replace the existing loader usage; `flutter analyze` clean in commons + khelam (+ forkable — commons consumer check); tests green; commit to a new feature branch + draft-PR only; screenshot of the schedule screen posted to #screenshots (`capture_screens.sh schedule` — registry entry exists, initial route, no auth/backend; note the loading state is brief with MockBookingService) | ✅ Approved |

## 🟠 Parked (revisit at the 2026-08-16 review unless noted)
| Card | Revisit | Note |
|---|---|---|
| **T4 — Analytics** (was DESCOPED → parked 08-07) | **2026-08-16** | plan properly or drop |
| **T6 — Perf/rebuild hygiene + Samseer-in-prod gate** (was DESCOPED → parked 08-07) | **2026-08-16** | re-add when needed |
| **macOS DMG verification** | **2026-08-16** | release DMG launches to a **blank screen** (user 08-07) — diagnose or drop macOS distribution |
| **Melos workspace → generic/cross-device** (parked 08-08) | **2026-08-16** | melos.yaml/pubspec.yaml currently machine-local at `~/projects/khel-service/` (not a git repo). Parked for: commit canonical config to forkable + make it **generic so any device that clones forkable/khelam can bootstrap** (paths/env-var indirection for repo locations, not just this machine) — see session 08-08 Decisions |

## ⚪ Descoped (reopen when user decides)
- **containerTheme widget pass** (theme spec §7 follow-up — JSON timeSlot/dateTile values → `DateChip`/`AvailableSlotCard`) — DESCOPED 2026-08-12 (user decision: replaced by the autonomous skeletonizer card, see 🤖 queue C12).
- **Google sign-in + credential rotation (Action #1)** — DESCOPED 2026-08-08 (user: google_sign_in had issues, low priority; pick up when he decides). Server client ID `91250679358-frejgd…` is **still leaked in git history + live** — rotation NOT done; reopen this card with the rotation runbook when Google login returns.
- **Revenue stat ₹0 in API mode** — DESCOPED 2026-08-11 (user decision — backend gap: the slots list endpoint returns no booking object, so revenue sums to ₹0 in API mode). Reopen when the backend includes booking details/amounts on list slots (backlog item 08-01).
- **Real home experience** — DESCOPED 2026-08-11 (user decision — `home_view.dart` is a placeholder, needs design). Reopen when the post-login home is designed (backlog item 08-01).

## 📋 Closed / superseded (2026-08-07)
- **Theme config implementation** (08-09) — CLOSED: user's `gemini-code-1786262983859.json` light Material 3 theme → khelam AppTheme via brainstorming gate (spec `docs/superpowers/specs/2026-08-09-theme-config-design.md`, JSON copy `2026-08-09-theme-config.json`). AppPalette +18 constants (17 JSON slots + cardShadow; `error` → #D9534F); `lightColorScheme` fromSeed(seed #097339) + 14 explicit slots; typography layer (6 styles, role-colored, both brightnesses); light-only card (r24/e2/shadow 0x1A000000)/elevated (pill-100, e0, v16/h24)/outlined (pill-100, outline side, v8/h16) overrides; scaffold canvas #F9FAFA. **SDK deviation**: Flutter 3.32 deprecates `ColorScheme` `background`/`onBackground`/`surfaceVariant` — skipped (inert, zero consumers), background via scaffold, surfaceVariant kept for containerTheme follow-up. Dark untouched; commons untouched. Analyze clean + pre-commit gate green. **Follow-up**: containerTheme widget pass (DateChip/AvailableSlotCard) on the Active card.
- **Task dashboard (standalone Flutter + Supabase queue)** — CLOSED 2026-08-08 (user: "we won't be picking it"): the 08-16 DROP criterion fired — Discord comms (`#daily-overview` + `#weekly-reviews`, spec `2026-08-07-comms-discord-design.md`) cover the review surface. **Spec RETAINED for revival**: `docs/superpowers/specs/2026-08-06-task-dashboard-design.md` (195 lines, v2 Supabase pivot, decisions 1–10 locked — auth email/password, `~/.config/khelam/sb.env`, seed manual v1). Reopen = user decides to revisit; no re-design needed.
- **Real auth/JWT wiring** (07-31) — CLOSED: `setBearerToken` wired (`auth_api_service.dart:107,143`); `booking_flow` integration 2/2 live on iOS sim.
- **UI screenshot verification** (08-06) — CLOSED: superseded by OA#6 `capture_screens.sh` (`ec178eb`, `b815d6c`).
- **Auto-digest reliability — catch-up + retry** (08-08) — CLOSED: spec `docs/superpowers/specs/2026-08-08-auto-digest-reliability-design.md` (approved by user + @architect). Forkable-first impl: `daily_digest.sh` refactor (per-date body, 14-day oldest-first catch-up, persistent markers `~/Library/Application Support/khelam/daily-digest/markers/<date>.sent`, atomic mkdir lock, 3×backoff retry), `report_sink.sh` `send_report_to` returns 1 on Discord failure (fallback kept), `weekly_review.sh`/`capture_screens.sh` `|| true` guards, plist `RunAtLoad=true`. **Live launchd E2E caught a real bug**: BSD `date -j -v` arg order → weekday test silently failed → fixed with python3 `day_info`. Verified: due-set 12/2, idempotency, catch-up, retry exhaustion (no marker → retries next fire), kickstart 0/14. 10 pre-service markers seeded; 2 real Friday posts (07-31, 08-07) went out on first bootstrap. Job live; first scheduled fire Mon 08-10 08:00.
- **Daily digest = live tasklog board, 4 messages** (08-08) — CLOSED: per user feedback ("I want the actual tasklog in the daily digest as we discussed, nothing else. Count means nothing to me; token/cost is a weekly thing"), the digest body became the **live board sections** 🔴 Active / 🟡 Backlog / 🟠 Parked / ⚪ Descoped (compact `##` headings + rows); 📋 Closed + token/backlog/session signals dropped. User decision: **split into 4 messages** — msg 1 = `Daily overview — <date>` + 🔴 Active, msgs 2–4 = 🟡/🟠/⚪ (empty-title posts, no " — " prefix) — no 2000-char cap pressure (board may grow freely). Markers became **per-message** `markers/<date>-<n>.sent` (partial failure re-sends only missing messages); `report_sink.sh` gained the empty-title branch; **stale-lock takeover guard** (>30min, SIGKILL-proof — a killed fire had stuck the lock, blocking the next fire); flat→per-message marker migration (12 days). Live E2E: 4 real Discord posts for 08-06 (13:35) + idempotent re-fire 0/14. First scheduled multi-message fire Mon 08-10 08:00.
- **Daily digest = single trimmed message** (08-08) — CLOSED: user's final 6-point layout decision supersedes the 4-message split — **one message = one curated board**: cards TRIMMED to *italic title* + subtitle + **short status** + date (scope/effort/long notes dropped); 🔴 Active (all) + 🟡 Backlog (**top 5** only); 🟠 Parked + ⚪ Descoped render **only when Active AND Backlog are both empty**; blank-line section separators (**no `---` dividers**); **no `.md` attachment** (user: Discord shows it as a download chip, not glanceable — "if .md is not useful then we're not sending it"); full board stays in the repo (agent console). Body ≈ 726 chars vs 2000 cap — truncation moot. Markers stay `<date>-1` (backward-compatible with the per-message era). Live E2E 14:37: single real Discord post for 08-06, 0 artifacts; idempotent re-fire 0/14. First scheduled trimmed fire Mon 08-10 08:00.
- **Discord go-live** (08-08) — CLOSED: `~/.config/opencode/discord.env` filled (mode 600), `REPORT_SINK=discord_webhook` in both plists (forkable `acbbf04`, khelam `d072c6c`), digest plist installed + weekly plist reloaded, E2E digest run. **All 5 webhooks live-verified 08-08**: daily-overview ✅, weekly-reviews ✅, screenshots ✅ (multipart — real 1320×2868 screenshot uploaded), agent-errors ✅, default ✅ (after fixing missing leading `h` in `DISCORD_WEBHOOK_URL` → `curl: Protocol "ttps" not supported`). First auto-digest: Mon 08-10 08:00.
- **[T1] Security gate** — CLOSED: `.env` de-tracked + gitignored (khelam `9445e2d`, forkable `c067908`).
- **T2 — Shared error mapping** (08-08) — CLOSED: `AppException` sealed hierarchy + `DioApiClient.mapDioException` (commons v0.7.0 `827f940`), cubit/service surface `e.message`, EmptyView; khelam `b1ecd81`; suites green.
- **T3 — Retry + connectivity-aware** (08-08) — CLOSED: commons `RetryInterceptor` GET-only retry (v0.7.1 `203af79`), TurfsApiRepository 404-only fallback (offline/5xx now propagate typed), wired in DI; khelam `d513184`; suites green.
- **T5 — In-session GET cache** (08-08) — CLOSED: `DioApiClient` GET cache, 30s TTL, keyed path+query, flushed on successful POST (booking visibility) + token change (account boundary); commons v0.7.2 `a8f1211`; khelam no change needed (transparent); 93/93 + 57/57. **Robustness batch T2→T3→T5 COMPLETE.**
