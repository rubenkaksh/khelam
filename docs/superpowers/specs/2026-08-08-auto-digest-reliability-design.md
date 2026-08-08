# Design — Auto-digest reliability (catch-up + retry)

Date: 2026-08-08
Status: Approved (user + @architect review) — awaiting implementation
Scope: `com.khelam.daily-digest` launchd job hardening. Weekly review explicitly out of scope.

## Context

The daily digest (`com.khelam.daily-digest`, Mon–Fri 08:00 via launchd) is the user's **most important automation** — it drives daily decisions and tracking. The weekly review is a broader perf/cost analysis and is deliberately **not** hardened here.

Current gaps (all verified):
- `~/Library/LaunchAgents/` jobs only run in a logged-in GUI session. If the Mac is **powered off, logged out, or at the login screen at 08:00** → the digest is missed for that day. Past calendar intervals do not fire on load; `RunAtLoad=false`.
- A transient Discord/network failure at fire time → only a local `macos_notification` fallback, **no retry, no recovery**.
- **Friday is never covered** by the normal schedule: Mon–Fri 08:00 fires report Sun–Thu (Fri's fire reports Thu; Sat has no fire; Mon reports Sun). Friday's data reaches the daily digest only via a catch-up.

Sleep is already handled: `man launchd.plist` — *"Unlike cron which skips job invocations when the computer is asleep, launchd will start the job the next time the computer wakes up."*

## Locked requirements (user decisions)

1. Catch-up + retry are required; the digest is the foundation for a planned v2 (webhook → agent activation for day-to-day tasks).
2. **One digest per missed day**, oldest first, each labeled with its own date (no collapsing).
3. **Duplicate prevention is mandatory**: a given date is delivered at most once.
4. Delivery should stay deterministic + idempotent (v2 compatibility).

## Verified facts (this machine)

- All tools resolve in the plist PATH (`/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin`): python3, sqlite3, curl, awk, sed, paste, date (BSD), basename, osascript.
- Hard script deps: `report_sink.sh` next to the script (exit 1 if missing); `python3` at line 56 (`read <<< "$(python3 …)"` under `set -euo pipefail`).
- `opencode.db` at `~/.local/share/opencode/opencode.db` (665 MB, WAL mode → concurrent readers safe).
- E2E manual run verified ("daily digest sent: Daily overview — 2026-08-07").
- `/tmp/daily-digest.log` does not exist → launchd has never fired the job (first fire Mon 08-10).
- `RunAtLoad` + `StartCalendarInterval` coexist cleanly (independent; no suppression). `StartInterval` fires relative to load/completion (not wall-clock) → rejected for exact-08:00 delivery.

## Design (approach A, refined by @architect)

### 1. Plist change (template: forkable-first, sync to khelam, then update installed copy + reload)

```xml
<key>RunAtLoad</key>
<true/>
```

`StartCalendarInterval` (Mon–Fri 08:00), `EnvironmentVariables`, and log paths unchanged. State dir created by the script itself (no `StateDirectory` key needed — keep it simple).

### 2. Script structure (refactor `daily_digest.sh`)

Split the fixed-`YESTERDAY` assembly into a per-date parameterized function:

- `generate_body(D)` — pure: computes the local-midnight SQL window for `D`, token deltas, Open Actions, backlog, session-count for `D`. Returns the body (≤1900 chars).
- `is_due(D)` — pure predicate (due-set rule below).
- `send_with_retry(body, title)` — Discord send + backoff retry + marker write on success.
- `main()` — lock → catch-up scan → summary log.

### 3. Due-set rule (with the Friday exception)

`D` is due iff **all** of:
- `D` < today, and
- no marker exists for `D`, and
- `D` within the 14-day lookback, and
- (`D+1` is a weekday) **or** (`D` is Friday).

| Target D | D+1 | due? | Why |
|---|---|---|---|
| Sun–Thu | Mon–Fri | ✅ | normal-schedule coverage |
| **Fri** | Sat | ✅ | **exception — no normal fire covers Fri** |
| Sat | Sun | ❌ | matches normal schedule |

### 4. Marker scheme (persistent, at-most-once)

- Path: `~/Library/Application Support/khelam/daily-digest/markers/YYYY-MM-DD.sent` (empty file).
- Written **only after a successful send**. Post-send write only — a pre-send marker would create a data-loss window (crash between marker-write and post → day permanently skipped). Accepted trade-off: at most **1 duplicate** if a marker write fails after a successful post.
- **Not** `/tmp` (wiped on reboot → re-send duplicates).
- **Not** in the repo (`scripts/markers/` would be committed — runtime state must not live in git).

### 5. Race prevention (atomic lock)

- `mkdir "$STATE_DIR/.lock"` is atomic; on failure → another instance holds it → exit 0 silently (the holder does the full scan).
- `trap 'rmdir "$LOCKDIR"' EXIT` releases it.
- Covers the wake-coalesced 08:00 fire racing a login-triggered `RunAtLoad` fire.

### 6. Retry

3 attempts, delays 0s / 5s / 15s (exponential ×3), worst case ~65s per date. On final failure: no marker → next fire (login or next weekday) retries, plus `send_report_to agent-errors` error report.

### 7. Catch-up scan (main)

Backward scan over the 14-day lookback, oldest-first. For each due day: generate → send → marker. Missing `opencode.db`/repo files degrade gracefully as today (log + skip signal).

### 8. Logging

- Script LOG moves from the shared `/tmp/weekly-review.log` default to persistent `$STATE_DIR/daily-digest.log` (isolated, survives reboot).
- launchd stdout/stderr redirect stays at `/tmp/daily-digest.log` for ephemeral debugging.
- Guard skips do **not** log (no spam); summary line per fire: `N sent, M failed, K skipped`.

## Failure-mode contract

| Failure mode | Behavior | Never lose | Never dup |
|---|---|---|---|
| Off/logged-out at 08:00 | RunAtLoad catch-up on login | ✅ | ✅ lock+marker |
| Asleep at 08:00 | launchd wake-coalesced fire | ✅ | ✅ |
| Off entire weekend | Monday fire catches up Fri + Sun | ✅ | ✅ |
| Discord/network down | 3-attempt retry; no marker → next fire retries + agent-errors report | ✅ | ✅ |
| Script killed mid-run | trap releases lock; no marker → re-run delivers | ✅ | ✅ |
| Marker write fails after post | next fire re-sends → **1 duplicate max** | ✅ | ⚠️ ≤1 |
| Wake-fire vs login-fire race | mkdir lock → single writer | ✅ | ✅ |
| opencode.db live-written | WAL concurrent reads | ✅ | ✅ |
| python3 / sink missing | hard abort (ops issue, logged) | ❌ n/a | n/a |

## Decisions log (defaults confirmed at approval)

| # | Decision | Choice |
|---|---|---|
| 1 | Marker location | `~/Library/Application Support/khelam/daily-digest/` (macOS convention) |
| 2 | Lookback window | 14 days |
| 3 | Retry count/timing | 3 attempts (0/5/15s) |
| 4 | Saturday scope | excluded (matches normal coverage) |
| 5 | Weekly review | untouched (triggers a full LLM agent; catch-up there needs intent) |
| 6 | Marker format | empty file per date (JSON metadata → v2 if needed) |

## v2 compatibility

The parameterized entry points (`generate_body(D)`, `is_due(D)`, plus optional `--for-date D` flags) are exactly the seam a webhook → agent trigger needs. Deterministic body + idempotent delivery + marker history = safe foundation. No v2 design done here.

## Implementation plan (forkable-first)

1. **forkable**: edit `scripts/daily_digest.sh` (refactor + guard + markers + lock + retry + scan) and `scripts/com.khelam.daily-digest.plist` (`RunAtLoad=true`). Verify: `bash -n` + `shellcheck`.
2. **Sync** both to khelam `scripts/` (forkable-first policy — canonical lives in forkable).
3. **Install**: copy plist to `~/Library/LaunchAgents/` + reload (`launchctl bootout gui/$(id -u)/com.khelam.daily-digest` then `launchctl bootstrap gui/$(id -u) …`, or `kickstart -k`).
4. **Test** (temp `STATE_DIR` to avoid touching real markers):
   - idempotency: run twice → second run skips (markers present)
   - catch-up: seed missing markers for 2–3 past dates → verify one post per date, oldest-first
   - launchd E2E: `launchctl kickstart gui/$(id -u)/com.khelam.daily-digest` → post to #daily-overview + marker created + persistent log written
5. **Bookkeeping**: tasklog card, session file, review-memory if needed; commits pass the pre-commit gate (docs-only for the spec commit).

## Implementation notes (08-08 — executed, all verified live)

- **report_sink.sh contract addition (necessary for retry)**: `send_report_to` in `discord_webhook` mode now returns **1** when the Discord post fails (the macos_notification fallback still fires first — delivery never drops). Previously it always returned 0 (the fallback swallowed the failure), which would have made the retry design dead code. Backward-compatible: callers that ignore the status are unaffected; the two standalone callers (`weekly_review.sh`, `capture_screens.sh`) got explicit `|| true` guards so `set -e` behavior is unchanged. Doc-comment updated.
- **BSD `date -j -v` arg-order bug (caught by the live launchd E2E)**: `date -j -f '%Y-%m-%d' "$D" -v+1d '+%u'` (with `-v` AFTER the parsed date) prints the full default date string → `[: integer expression expected` → the weekday test silently failed for every day. The Friday-exception line (no `-v`) still worked, so the first bootstrap fire sent exactly the 2 Fridays (07-31, 08-07 — real posts, markers written). **Fix**: `is_due` now uses a python3 `day_info` helper (isoweekday; Mon=1..Sun=7) — single date-math source of truth alongside `local_midnight_window`.
- **Initial-state seeding**: at rollout, markers for all due days in the 14-day lookback were seeded (pre-service days are not "missed"; the digest only went live today). Catch-up applies to days missed *after* the job is live. Seeded: 07-26..07-30, 08-02..08-06 (10) + existing 07-31, 08-07 (2) = 12 markers.
- **Verified live**: due-set (12 sent / 2 Sat skipped via noop), idempotency (second run 0 sent / 14 skipped), catch-up (11 seeded markers → only the missing day attempted), retry backoff (3 attempts at 0/5/15s, marker NOT written on exhaustion → next fire retries, agent-errors report fired), real launchd kickstart (0 sent / 14 skipped, exit 0).
- **CONTENT CHANGE — body = live tasklog board (user 2026-08-08)**: the digest body is now the live board sections 🔴 Active / 🟡 Backlog / 🟠 Parked / ⚪ Descoped, rendered Discord-friendly (compact `##` headings + table rows; the 📋 Closed section, token/cost, OA/backlog counts, and session counts are all dropped — user: "counts mean nothing… token/cost is a weekly thing"). The digest is the daily decision surface, not a metrics report.
- **CONTENT CHANGE — 4-message layout (user 2026-08-08)**: one message per section heading; msg 1 = "Daily overview — \<date>" (title) + 🔴 Active, msgs 2–4 = 🟡/🟠/⚪ with empty titles. Required a backward-compatible **empty-title branch in `report_sink.sh`** (empty title → body posts as-is, no " — " prefix). No 2000-char cap pressure — the board can grow freely.
- **MARKER SCHEME — per-message (2026-08-08)**: markers are now `markers/<date>-<n>.sent` (one per message). A partial failure re-sends ONLY the missing messages — no duplicates, per the duplicate-prevention priority. The flat `<date>.sent` scheme is superseded; the 12 flat markers were migrated to 48 per-message markers (flat removed).
- **STALE-LOCK GUARD (real bug found live)**: the atomic `mkdir` lock had no staleness guard — a fire killed with SIGKILL (sleep/reboot skips EXIT traps) leaves `.lock` behind and the digest silently stops (observed: a kickstart after a killed fire exited 0 with no log lines, job "not running"). Guard added: a lock older than 30min is abandoned and taken over (`find -mmin +30`; fires take seconds).
- **Verified live (multi-message)**: kickstart fired 4 real Discord posts for 08-06 (13:35 — msg 1 date-titled, msgs 2–4 bare sections), 4 per-message markers written, lock cleaned, idempotent re-fire 0 sent / 14 skipped. First scheduled multi-message fire Mon 08-10 08:00.

## Out of scope

- Weekly review catch-up/hardening
- Saturday data in daily digest
- v2 webhook → agent trigger
- Google sign-in descope / other board items
