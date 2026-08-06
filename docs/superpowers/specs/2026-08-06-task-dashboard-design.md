# Design — Task/Ticket Breakdown Dashboard (v2, standalone project, Supabase pivot)

> Date: 2026-08-06. Status: PROPOSED — awaiting approval. Spec lives at `docs/superpowers/specs/` (not a declared feature; matches the 2026-08-06 screenshot-verification precedent). Implementation target: **standalone Flutter project** at `~/projects/task-dashboard`.
>
> **Changelog** (2026-08-06, user decisions):
> - **v1** (user pivot): storage moved **local Isar → Supabase** to enable a *bidirectional* task queue (user flips a ticket in the app → status lands in the DB → the agent picks it up as the worker).
> - **v2** (user): **location moved OUT of khelam** — the dashboard is a **separate simple Flutter project** (`~/projects/task-dashboard`, own repo), NOT a khelam feature slice. It serves **all agentic tasks that require user review/decisions going forward** (khelam, forkable, backend, commons, cross-project), not just khelam's. Open questions 1–3 answered with architect's leanings: **auth = email/password signup**, **service key = `~/.config/khelam/sb.env`**, **seed = manual/on-demand v1**.
>
> Locked UI/form-factor decisions (§2 #1–#5) are unchanged; three-column kanban identical. Only the data plane + project location change: supabase client + local JSON cache in a standalone app.

## Pivot (Supabase) — executive summary

| Question | Old (v0) | New (v1) | Rationale |
|---|---|---|---|
| Storage | local isar (one-way mirror) | **Supabase `tickets` table** (queue) + local JSON cache (offline) | Bidirectional sync is impossible without a shared backend. The app and the agent are different processes on (possibly) different machines — only a cloud table bridges them. |
| Source of truth | markdown (script reads) | **markdown = audit trail; Supabase `tickets.status` = queue state** | The external gate signs resolutions in markdown; the live "what to work on" lives in the queue. Two-way, directional (§9). |
| Agent learns a flip | n/a (mirror only) | **`scripts/check_queue.sh`** polled at session start | Shell-first, 0-token poll (curl to PostgREST). No daemon/webhook — single-user, cheap. |
| App writes | never | **optimistic local update + upsert via anon key + user JWT** | User drives todo→ready / blocked; agent drives ready→inProgress→done via service_role. RLS separates the two write paths. |

**Evidence base for the storage verdict** (verified 2026-08-06):
- `Dart SDK 3.8.0` caps `supabase_flutter` at **2.15.4** — `2.16.0+` requires SDK ≥3.9.0 (pub resolution fails on `sdk: ^3.8.0`). Resolved stack: `supabase 2.13.4` / `postgrest 2.8.0` / `realtime_client 2.10.0` / `gotrue 2.25.0`. Compatible; no upgrade needed.
- Supabase free tier (500 MB, 50 k MAU, **2 concurrent connections**, pauses after 7 d idle) is ample for a single-user tool. The 2-conn cap is honoured by design: 1 for the app, 1 for the poll script; no realtime listener (saves a websocket connection).
- `supabase` CLI is installable via `npx --yes supabase@2.111.0` for local dev (`supabase start` → local Postgres/gotrue/postgrest/realtime); no global install required.
- Standalone project uses `flutter_secure_storage` + `flutter_dotenv` (JWT + env persistence, standard deps) and `supabase_flutter 2.15.4` for the Supabase client. No dio, no commons dependency — the dashboard talks only to Supabase REST (via supabase_flutter), never to the NestJS API. khelam's pubspec is untouched by this project.
- `.env` is **tracked** in git (`git ls-files .env` → confirmed); it is safe to hold the **anon** key (public-by-design). The **service_role** key is the real secret and lives only in `~/.config/khelam/sb.env` (never committed).

---

## 1. Purpose

A personal, macOS-only **controller** over the project's markdown memory. The user advances a ticket in the three-column kanban (todo / in-progress / done) → the status change is written to a Supabase `tickets` row → the agent (the worker) picks up `ready` tickets and drives them to `done`, writing `completedAt` + actual tokens back so the board reflects execution in real time. Markdown (`review-memory.md`, backlog, day-plan, learnings) stays the **audit trail** the external gate signs; the queue is the **live state**.

## 2. Locked decisions (user, 2026-08-06) — unchanged by pivot

| # | Decision | Constraint |
|---|---|---|
| 1 | Form factor | Flutter (house growth path), macOS surface |
| 2 | Layout | Row of Expanded, each a ListView of Cards (todo / in-progress / done) |
| 3 | In-progress card | step counter ("Step 2/5") + `LinearProgressIndicator` |
| 4 | Done card | subtle opacity dip + completed timestamp |
| 5 | Status marker | `Container`+`BoxDecoration` circle, no icon assets; colors red=blocked, amber=in-progress, green=done, gray=todo |
| 6 | Storage | **REVISED** → Supabase (was: local DB hive/isar); a local JSON cache backs offline + optimistic updates |
| 7 | Project location | **REVISED (v2)** → standalone Flutter project `~/projects/task-dashboard` (own repo, NOT a khelam slice). Scope: **all agentic tasks requiring user review/decisions** — cross-project (khelam, forkable, backend, commons, future repos) |
| 8 | Auth | email/password one-time signup, JWT in secure storage (architect lean, user 2026-08-06) |
| 9 | Service key storage | `~/.config/khelam/sb.env`, never committed (architect lean, user 2026-08-06) |
| 10 | Seed frequency | manual/on-demand `sync_tasks.sh` v1; automate into weekly_review only if drift shows (architect lean, user 2026-08-06) |

## 3. App form factor & location — LOCKED (v2, standalone)

Decision — **standalone Flutter project** at `~/projects/task-dashboard` (own git repo, simple structure: `lib/` with `main.dart` + minimal feature folders; macOS run target). NOT a khelam feature slice — khelam stays a pure mobile/desktop app; the dashboard is a separate tool that may consume data from any project's markdown. Run with `flutter run -d macos`. No commons dependency, no khelam pubspec change → **no commons-consumer check triggered** (forkable unaffected). Supabase client + local JSON cache only.

Implications of standalone (vs v0's in-khelam):
- Sync scripts live in the dashboard repo (`scripts/check_queue.sh`, `ticket_queue.sh`, `sync_tasks.sh`) — they read markdown from ANY repo path passed as an argument (e.g. `--source ~/projects/khel-service/khelam/docs/reviews/review-memory.md`), defaulting to khelam's paths.
- Write-back appends to the source repo's `review-memory.md` — the external audit gate stays per-project; each project's weekly review reads its own markdown.
- No route-guard needed (no mobile target); macOS is the only target.

## 4. Storage: Supabase vs local cache (re-evaluated)

| | Supabase (`tickets` table) | Local JSON cache |
|---|---|---|
| Role | **shared queue** — app + agent both read/write | **offline mirror + optimistic writes** — personal tool survives DB pause/offline |
| Free-tier hit | 1 of 2 concurrent conns; REST only | zero cost; file in app-support dir |
| Dart 3.8 fit | `supabase_flutter 2.15.4` (max; 2.16+ needs Dart 3.9) — OK | none (dart:io read/write) |
| When it degrades | 7-d pause → slow cold first request; retry + cache banner | used automatically when POST/GET fails |

**Verdict — full Supabase queue + JSON local cache.** Not a hybrid that "falls back to pure local" (that was the old one-way design and cannot satisfy bidirectional). The cache is a *read+write-through* fallback: every successful fetch overwrites `data/task_cache.json`; failed app writes stage into `data/task_pending.json` and flush on next online fetch. The existing markdown pipeline (`ccusage_collect.sh`, `weekly_review.sh`, `opencode.db`) never touches Supabase → no single point of failure for the review cadence.

## 5. Entity model — `Ticket` (Supabase row)

Maps 1:1 to the `tickets` table row. Stored via `supabase_flutter` (freezed `@JsonSerializable` ↔ `fromJson`/`toJson`) — **not** isar `@collection` (codegen swap; same `build_runner` step, now emits `ticket.g.dart` for JSON not isar).

| Field | Type | Source |
|---|---|---|
| `id` | uuid | Supabase `uuid_generate()` (app-stable; Finder reveal, writes) |
| `owner_id` | uuid | `auth.uid()` — single-user JWT anchor for RLS |
| `status` | enum `todo\|ready\|inProgress\|done` | **queue state machine** (was 3-value; +`ready` for agent claim) |
| `source_id` | String? | seed dedupe key (e.g. `oa-5`, `bl-revenue`, `dp-2026-08-06`) |
| `title` | String | OA / backlog bullet / batch step / learning |
| `type` | enum `openAction\|backlogItem\|dayPlan\|learning` | row origin |
| `isBlocked` | bool | red dot (§8) |
| `priority` | enum `p0\|p1\|p2\|p3` | severity / urgency / backlog priority |
| `sourcePath` | String | `file:LiN` (tap → reveal in Finder) |
| `estTokens`,`actualTokens` | int? | day-plan batch line; OA screenshot-verify ~7k |
| `stepIndex`,`stepCount` | int? | active batch / batch-log count |
| `progress` | double 0..1 | stepIndex/stepCount |
| `trust` | String? | "L1\|L2\|L3" (day-plan) |
| `scope` | String? | "clean\|dirty" (day-plan) |
| `deferralCount` | int | "(Review: …, add #N)" count; external gate max 2 |
| `notes` | String? | deferral history / body excerpt |
| `createdAt`,`updatedAt`,`completedAt` | DateTime | `now()` / trigger / set on done |

**State machine + who transits:**
| From → To | Who | Channel |
|---|---|---|
| `todo` ↔ `ready` | user | app (anon key + JWT) |
| `ready` → `inProgress` | agent | `scripts/check_queue.sh` → `ticket_queue.sh claim` (service_role) |
| `inProgress` step / token updates | agent | same worker script |
| `inProgress` → `done` | agent | `ticket_queue.sh complete` (sets `completedAt` + `actualTokens`) |
| any → `isBlocked`=true | user | app |

## 6. Artifact → entity mapping — LOCKED (unchanged)

(Same as v0 §6.) Seed mapping by `source_id`; active-execution detection sets `status=inProgress`, `stepIndex=current_batch`, `stepCount` from the batch log. At the 2026-08-06 snapshot the day-plan is complete → in-progress column renders the "no active execution" placeholder.

## 7. Ingestion/sync — bidirectional bridge

The DB is now cloud-native (no local binaries to author); the bash/python boundary inverts — scripts write to the table directly via PostgREST REST.

```
docs/reviews/review-memory.md ─┐
docs/backlog.md               ├─→ scripts/sync_tasks.sh ──→ Supabase REST (POST /tickets, UPSERT
docs/sessions/*-status.md     │    service_role)           by source_id; status NOT clobbered)
docs/sessions/<date>.md §4    └─>                          → tickets.status is the live queue
                                                                   app reads anon key+JWT; agent reads service_role
agent (this process) ──────> scripts/ticket_queue.sh claim/complete ──→ Supabase REST (inProgress/done)
agent completion ──────> scripts/ticket_queue.sh complete ──→ append resolution line ──→ docs/reviews/review-memory.md (write-back)
```

- **Seed (md→supabase)**: `sync_tasks.sh` is idempotent (UPSERT by `source_id`); it only **inserts new** rows and **updates non-status metadata** (title, sourcePath, estTokens when changed) — never resets `status`, `completedAt`, or `actualTokens`. Re-running is a safe no-op. `bash -n` + `python3 -m json.tool` smoke.
- **App read/write (supabase↔local cache)**: `DashboardCubit` fetches `tickets` on load + on focus; writes optimistically to `task_cache.json` **and** upserts to Supabase; on failure, stages to `task_pending.json` and flushes later.
- **Agent read/write (queue→agent→supabase)**: `check_queue.sh` lists `status='ready'` (service_role, ordered by priority/createdAt). The agent claims one (PATCH `status=ready→inProgress`), updates steps, then `complete` (PATCH `status=done` + `completedAt` + `actualTokens`).
- **Write-back (supabase→md)**: on `complete` of an `openAction` ticket, `ticket_queue.sh` appends an idempotent `+ [done YYYY-MM-DD] <source_id> — agent-completed (queue id <uuid>)` line to `review-memory.md` so the weekly review sees the resolution and signs off. For `dayPlan`/`backlogItem` the completion marker lands in the owning status file / bullet. Markdown stays the audit trail; Supabase stays the queue.

## 8. UI structure — LOCKED (unchanged; only data source shifts)

(Identical to v0 §8: column header dot + count badge; todo card; in-progress "Step X/N" + `LinearProgressIndicator` + est→actual tokens; done opacity 0.6 + `completedAt`; tap→bottom sheet with notes + sourcePath "reveal in Finder"; `DashboardCubit extends Cubit<DashboardState>` holding `List<Ticket>` + `isLoading`.) Data source note: the cubit now fetches from the Supabase client (via `ticket_repository.dart`) and seeds the local cache, instead of importing `task_manifest.json` into isar. The "Refresh" button re-fetches; a "Reveal in Finder" tap still uses `dart:io Process.run('open', …)` (no new dep).

## 9. Governance: markdown (audit) vs Supabase (queue) — external gate flow

**Recommendation (a): Supabase = queue, markdown = audit trail, directional two-way sync.** (Rejects (b) purge-markdown and (c) status-only-in-DB.)

Why markdown stays a first-class record: `management-strategy.md` Ch. 5 makes **you** the external auditor; `review-memory.md` §6.1–6.6 Open Actions carry your signed resolutions, and the weekly review reads them. Scrapping markdown (option b) would orphan the audit gate. The queue (Supabase) is the *execution* state — it must be cloud (app↔agent differ). So:

1. **Seed** writes *content + metadata* into Supabase; status is **never** reset by the seed, so a user-advanced ticket keeps its live status across re-seeds.
2. The **external gate reads markdown** at every weekly review: your signed `fix / defer-with-date / drop` lives there; `ticket_queue.sh complete` only ever *appends* a resolution line, never rewrites your signature. The review sees both the markdown signature and the Supabase `completedAt`.
3. **Week-planning** (strategy Ch. 6): `check_queue.sh` output (`status='ready'`) is appended into the next day-plan's "Queued from dashboard" line — work still **enters via the day-plan contract**; the queue feeds the contract, it doesn't bypass it.

## 10. Token-cost preservation (user requirement, updated)

- **Shell polls = 0 tokens**: `check_queue.sh`, `sync_tasks.sh`, `ticket_queue.sh` are bash+curl; no LLM. (Matches `ccusage_collect.sh` house style.)
- **Per-pickup LLM cost**: ~300–500 tokens (script output ingested once per claim) — vs a 167.5 M token free-tier week; negligible.
- **Analytics pipeline untouched**: `ccusage_collect.sh`, `weekly_review.sh`, `opencode.db`, `~/analytics/` never reference Supabase. The in-progress token row still comes from `docs/sessions/*-status.md`.
- **App client**: compiled Dart (supabase_flutter); fetches the board via REST — no extra model calls.
- **Expected implementation cost**: ~28–34 k tokens across B1–B3, all free-tier ($0) — consistent with `performance-summary.md` Week 1 ($0).

## 11. Deliverables (files — all in the standalone project `~/projects/task-dashboard`)

| File | Purpose |
|---|---|
| `docs/superpowers/specs/2026-08-06-task-dashboard-design.md` | this spec (revised; lives in khelam's docs as the design record) |
| `supabase/migrations/20260806_create_tickets.sql` | `tickets` table + check enums + RLS + `updated_at` trigger |
| `supabase/.gitignore` (+ root `.gitignore` add) | `supabase/.env` (local service_role) never committed |
| `lib/models/ticket.dart` | freezed `@JsonSerializable` Ticket (supabase row), + enums |
| `lib/models/ticket.g.dart` | generated (`build_runner`) |
| `lib/data/supabase_client.dart` | `SupabaseClient` init from `.env` (URL + anon key) |
| `lib/data/ticket_repository.dart` | fetch upsert + local JSON cache (`task_cache.json` / `task_pending.json`) |
| `lib/bloc/dashboard_cubit.dart` | loads tickets → emits `List<Ticket>`; optimistic writes + refresh-on-focus |
| `lib/views/dashboard_view.dart` | LOCKED 3-column board |
| `lib/widgets/task_card.dart` | LOCKED card + dot + progress + opacity + sheet |
| `.env` | add `SUPABASE_URL` + `SUPABASE_ANON_KEY` (tracked, public anon key) |
| `scripts/sync_tasks.sh` | parses markdown → UPSERT `tickets` (idempotent, status-preserving); takes `--source <path>` for any repo |
| `scripts/check_queue.sh` | lists `status='ready'` via PostgREST (service_role from `~/.config/khelam/sb.env`) |
| `scripts/ticket_queue.sh` | `claim`/`complete`/`block` subcommands → REST PATCH + markdown write-back |

## 12. Batch breakdown (background-agent protocol)

- **Batch 1 [L2] — Supabase project + schema + seed**: `npx supabase init` + migration SQL (enums + RLS + trigger) + `sync_tasks.sh` (md→supabase UPSERT by `source_id`). Acceptance: `supabase db push` succeeds; seed writes ≥6 `oa-*` + 3 backlog + 1 dayplan + 9 learnings with `status=todo` (no status clobber); `bash -n` clean; script is idempotent. Est ~6 k.
- **Batch 2 [L1] — App client + board UI (standalone project)**: `flutter create` the project; add `supabase_flutter ^2.15.4` to pubspec; `supabase_client.dart` + `ticket.dart` (freezed) + `DashboardCubit` (fetch/cache/optimistic/refresh-on-focus); rebuild LOCKED 3-column UI. Acceptance: `flutter analyze` clean; `flutter run -d macos` renders 3 columns from seeded tickets; flipping todo→ready persists; offline renders cache. Est ~14 k.
- **Batch 3 [L2] — Agent loop + pickup + write-back**: `check_queue.sh` + `ticket_queue.sh` (claim/complete/block) using service_role; complete appends to `review-memory.md`. Acceptance: `supabase start` running; `check_queue` lists a ready ticket; claim → `inProgress` visible in app after refresh; complete → `done` + `completedAt` + markdown resolution line. Est ~8 k.

> **Commons-consumer check**: only khelam's pubspec changes (supabase_flutter); forkable does **not** build the dashboard → no forkable dep change. Per `AGENTS.md`, run `flutter analyze` in both khelam and forkable before committing any pubspec change.

## 13. Acceptance bar (full loop)

1. `supabase db push` applies `20260806_create_tickets.sql` (table + enums + RLS).
2. `bash scripts/sync_tasks.sh` seeds markdown artifacts into `tickets` (status-preserving, idempotent re-run = no dupes/status reset).
3. `dart pub get` resolves `supabase_flutter 2.15.4` on `sdk: ^3.8.0`; `flutter analyze` clean; `dart run build_runner build` emits `ticket.g.dart`.
4. `flutter run -d macos` renders exactly three columns with seeded tickets from Supabase.
5. **Full loop**: user flips a ticket todo→ready in the app → `bash scripts/check_queue.sh` lists it → agent claims it (ready→inProgress, visible in app after refresh) → agent completes it (done + `completedAt`) → `review-memory.md` gains a resolution line readable by the weekly review.
6. Offline: kill Supabase / cut network → app renders last `task_cache.json`; queued writes flush on reconnect.
7. `flutter analyze` clean in khelam + forkable after the pubspec change.

## 14. Deferred scope (V2)

- **Realtime listener**: a single-user websocket is not worth the free-tier conn cap; `check_queue.sh` poll + manual Refresh is the V1 surface. V2 if the user wants live push to the board.
- **Hive `4.0.0-dev.2` Map-box escape hatch**: if Supabase infra is rejected at the gate, revert to local isar/hive as a read-only mirror (revert `§5` status enum to 3-value, drop §7 bidirectional). Documented rollback path; not the recommended direction.
- **`supabase functions/` edge functions**: not needed V1 (worker is local shell + service_role).
- **`sync_to_forkable.sh`**: mirror `scripts/` + `supabase/migrations/` to forkable once the dashboard slice lands there (mirrors the screenshot-verification sync pattern).
- Gold/screenshot pipeline for the macOS dashboard board — out of scope (reuse §6 of the screenshot-verification spec if/when needed).

## 15. Open questions (for the external gate)

1. **Single-user auth** — accept the one-time email/password signup (supabase_flutter persists JWT in `flutter_secure_storage`)? Alternative: anon-key permissive writes (rejected — RLS should still scope to a user). Recommendation: email/password, one-time.
2. **Service key storage for scripts** — `~/.config/khelam/sb.env` created by a one-time `supabase secrets set` / manual paste. Accept the local-secrets convention, or does the user prefer macOS Keychain (`security` CLI) for the worker key? Recommendation: `~/.config/khelam/sb.env` (matches `ccusage_collect.sh` `~/.local/share/opencode` pattern; simplest to grep/rotate).
3. **Seed frequency** — keep `sync_tasks.sh` as an on-demand/manual refresh (V1), or also prepend it to `weekly_review.sh` cadence (V2)? Lean: manual + on-demand now.
