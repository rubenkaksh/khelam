# Design — Comms → Discord Integration (v1, report_sink.sh rewrite)

> Date: 2026-08-07. Status: **PROPOSED — awaiting approval.** Lives at `docs/superpowers/specs/` (not a declared feature; matches the 2026-08-06 screenshot-verification precedent for `docs/superpowers/specs/`). Canonical script edit is **forkable-first** (see §8).
>
> **Changelog** (2026-08-07, design session): v0 stub lived as a comment in `report_sink.sh` (`# v2 comms integration, see design`). This spec resolves it. The user's vision (v6) — *"deliver everything the agent produces into a Discord channel"* — subsumes the deferred task-dashboard's review surface (task-dashboard OA#7 was parked at the 2026-08-16 review *or sooner if Discord-comms ships first*). If this ships, the standalone dashboard is **DROP**-ed per its own criterion.

## 1. Purpose

When the agent tooling fires `send_report` / `send_error_report` (from `weekly_review.sh`, `capture_screens.sh`, and future session-close-out hooks), the result must land in a Discord channel — weekly review summary + artifact pointers, session close-outs, screenshot PR snippets (PNG attachment), and audibled error reports — so the user has **one** review surface and no separate task-dashboard app. `report_sink.sh` is the single delivery abstraction; the rewrite adds a real `discord_webhook` sink with graceful degradation back to `macos_notification` + log, and never silently drops an error report.

## 2. Locked decisions

| # | Decision | Constraint |
|---|---|---|
| 1 | **Forkable-first canonical edit** | `report_sink.sh` is canonical in `forkable/scripts/`; khelam pulls byte-identical. khelam never edits it first. |
| 2 | **Secret location + naming** | Webhook URL lives **only** in `~/.config/khelam/discord.env` (machine-local, outside all repos → never committed; gitignore N/A — confirmed absent from tree). Env var name `DISCORD_WEBHOOK_URL`; override file path via `DISCORD_ENV_FILE`. Mirrors the `sb.env` precedent (task-dashboard spec §2 #9 / §11). |
| 3 | **Delivery mechanics** | `curl -sS -f` POST to the webhook URL. JSON body built via `python3 json.dumps` (never hand-rolled `{"content":"..."}` — braces/quotes/backslashes silently break on Discord 400). `content` ≤ 2000c. Local files under 25 MiB → multipart `payload_json` + `files[]`; non-file tokens → text list. |
| 4 | **`capture_screens.sh fail()` → `send_error_report`** | Failures become audible (Sosumi) **and** posted to Discord — matches the screenshot-verification spec §5 ("Failures are audible: send_error_report, Sosumi"). `fail()` currently calls `send_report` (no sound); this locks the fix. |
| 5 | **`send_error_report` = Sosumi always + Discord best-effort** | Audibility is never suppressed by Discord. Discord post is swallowed on failure; Sosumi fires regardless. |
| 6 | **Keep `slack_webhook` stub** | Unchanged. No Slack work in scope; dropping it is unrelated scope creep. Reserved for v3. |
| 7 | **No rate-limit batching** | Weekly review = 1 msg; screenshot = 1 msg; error = 1 msg. Peak burst <5/min. 30/min/webhook budget is ample → no coalesce. V2 only if a future feature fans out >10 msgs/run. |
| 8 | **Review doc not inlined** | `docs/reviews/<date>.md` and `~/analytics/*` artifacts are referenced by **path** as text, never inlined — they exceed the 2000c `content` cap and aren't web-served. |

## 3. Mechanism — Discord webhook API (researched, verified 2026)

Incoming webhook = an HTTP endpoint. POST `{ "content": "..." }` to the webhook URL; message appears in-channel. No bot/persistence needed.

| Fact | Value | Source |
|---|---|---|
| Endpoint | `POST https://discord.com/api/webhooks/{id}/{token}` (use the full webhook URL as `DISCORD_WEBHOOK_URL`) | [docs.discord.com/webhooks](https://docs.discord.com/developers/resources/webhook) |
| Plain text field | `content`, **2000 chars** max | [docs.discord.com/webhook resource](https://docs.discord.com/developers/resources/webhook) + [discord-webhook.com guide](https://discord-webhook.com/en/discord-webhook-guide/) |
| File upload | `multipart/form-data`: `payload_json` (JSON string) + `files[]` (binary); **25 MB** per file free / 50 MB Nitro / 500 MB Boost; up to **10 files** | [discord-webhook.com/send-file (2026-04)](https://discord-webhook.com/en/blog/discord-webhook-send-file/) + [field limits](https://birdie0.github.io/discord-webhooks-guide/other/field_limits.html) |
| Embeds | ≤10 embeds/msg, **6000 total chars**, title 256, description 4096, field name 256, value 1024 | [discord-webhooks-guide field limits](https://birdie0.github.io/discord-webhooks-guide/other/field_limits.html) |
| Rate limit | **30 req/min per webhook** (~5/2s burst); 429 + `Retry-After` on breach | [discord-webhook.com rate limits](https://discord-webhook.com/en/discord-webhook-guide/) |
| `username` / `avatar_url` | supported overrides | [docs.discord.com/webhook resource](https://docs.discord.com/developers/resources/webhook) |
| Markdown | `**bold**`, `*italic*`/`_`, `` `code` ``, ``` ``` ``` fences, `~~strike~~`, `||spoiler||`, `>` quote blocks. **No HTML** — `<tag>` is literal text. | [discord-webhooks-guide](https://discord-webhook.com/en/discord-webhook-guide/) |
| Success | `204 No Content` (default) / `200` with message if `wait=true` | [docs.discord.com/webhook resource](https://docs.discord.com/developers/resources/webhook) |
| Failure | `400` (bad JSON/limits) / `401` (bad token) / `404` (deleted webhook) / `413` (oversize) / `429` (rate) | [hooklistener debugging (2026-03)](https://www.hooklistener.com/guides/discord-webhook-debugging) |

**Two findings that changed defaults from the v0 stub:**
1. The stub's commented `curl -d "{\"content\":\"...\"}"` is **unsafe** — a `body` containing a quote or backslash makes invalid JSON → Discord returns 400 silently and the report is dropped. **Default changed:** all JSON is produced by `python3 json.dumps`. (Decision #3.)
2. File upload is **multipart, not JSON**. `capture_screens.sh` produces a local PNG (avg ~255 KB, limit 25 MB) — the whole point of "screenshot PR snippets → Discord" is the user *sees* the image in-channel. **Default changed:** local-file artifacts are uploaded as attachments via `-F "files[]=@path;filename=…"`, not just listed as paths. (Decision #3.)

## 4. Recommended mechanism

```
REPORT_SINK=discord_webhook  (set machine-locally; see §7 enablement step 4)
DISCORD_WEBHOOK_URL=<from ~/.config/khelam/discord.env, sourced at shell start>
DISCORD_ENV_FILE=<override, defaults $HOME/.config/khelam/discord.env>
```

**Loading (sourced once, top of `report_sink.sh`):**
```bash
DISCORD_ENV_FILE="${DISCORD_ENV_FILE:-$HOME/.config/khelam/discord.env}"
if [ -f "$DISCORD_ENV_FILE" ]; then
  set -a; . "$DISCORD_ENV_FILE"; set +a
fi
```
- Missing file/URL → `DISCORD_WEBHOOK_URL` stays unset → the sink **falls back to `macos_notification` + log** (never silently drops). It does NOT error out the caller.
- `set -a`/`set +a` export so child `curl` sees the var. The file is outside `$REPO` so it is never `git add`-ed.

**POST shape:**
- **Text-only path** (no uploadable local files): `curl -sS -f -H "Content-Type: application/json" -d @<(printf '%s' "$json") "$DISCORD_WEBHOOK_URL"` where `$json` = `python3 -c 'import json,sys;print(json.dumps({"content":sys.argv[1]}))' "$content"`.
- **File path**: write the `payload_json` JSON to a temp file (`mktemp`), then `curl -sS -f -F "payload_json=<$tmpjson" -F "files[]=@$path;filename=$(basename "$path")" "$DISCORD_WEBHOOK_URL"`. Reading `payload_json` from a file via `<$tmpjson` avoids shell-quoting the JSON inside `-F`. Multiple `-F "files[]=@…"` parts attach up to 10 files.
- **Size guard:** each candidate file is `stat -f%z`'d; > 25 MiB (26214400) → skipped with a `(attachment skipped, oversize: …)` note appended to `content` (keeps the message under 2000c by not inlining).

**Function scoping:** `_discord_post` is implemented as a **subshell function** (`_discord_post() ( set -euo pipefail; … )`) and invoked inside `if _discord_post …; then` — so a curl failure (`-f` → non-zero) is caught by the caller's `if` without `set -e` aborting the sourcing script, and stderr is appended to `$LOG`.

## 5. Interface — modified `forkable/scripts/report_sink.sh`

Verbatim new/changed bodies (diff against the current 61-line file):

**Header (top of file):** add `set -euo pipefail` + the Discord-env block + a `25 MiB` cap constant. The two `case` branches for `discord_webhook` / `slack_webhook` and `send_report`/`send_error_report` are rewritten; `macos_notification` / `noop` / `*` are unchanged in behavior (factored through a small `_notify_macos` helper).

```bash
#!/bin/bash
# report_sink.sh — delivery abstraction for background-agent reports (v1: Discord comms).
#
# Usage:  send_report <title> <body> [artifact...]
#         send_error_report <title> <body>   # always audible (Sosumi); best-effort Discord
#         (. scripts/report_sink.sh)
#
# REPORT_SINK env:
#   macos_notification (default) — osascript display notification, lists artifacts
#   discord_webhook — POST JSON to Discord (DISCORD_WEBHOOK_URL, see below)
#   slack_webhook — stub (v3 reserved; kept for option value, no behavior yet)
#   noop — testing; logs to $WEEKLY_LOG only
#
# Secret: DISCORD_WEBHOOK_URL is a SECRET (anyone holding it can post to the channel).
# It is sourced from $DISCORD_ENV_FILE (default ~/.config/khelam/discord.env) — a
# machine-local file OUTSIDE all repos, never committed. Format:
#   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/<id>/<token>
# If absent, discord_webhook degrades to macos_notification + log (never drops).
#
# Artifacts: a local file (stat-able) ≤25 MiB is uploaded as a Discord attachment; a
# non-file token (e.g. "weekly/2026-08-07.csv") is rendered as a text list. Discord
# cannot see local files otherwise — repo docs are referenced by PATH, never inlined
# (content caps at 2000 chars). JSON payloads use python3 json.dumps (no hand-rolled
# JSON — quotes/backslashes defeat curl -d silently).

set -euo pipefail

REPORT_SINK="${REPORT_SINK:-macos_notification}"
LOG="${WEEKLY_LOG:-/tmp/weekly-review.log}"

# --- Discord secret load (machine-local, never committed) -------------------------
DISCORD_ENV_FILE="${DISCORD_ENV_FILE:-$HOME/.config/khelam/discord.env}"
if [ -f "$DISCORD_ENV_FILE" ]; then
  set -a; . "$DISCORD_ENV_FILE"; set +a
fi
_DISCORD_FILE_CAP=$((25 * 1024 * 1024))   # 25 MiB free-tier cap

# --- helpers -----------------------------------------------------------------------
_notify_macos() { # _notify_macos <title> <body> [sound]
  local title="$1" body="$2" sound="${3:-}"
  if [ -n "$sound" ]; then
    osascript -e "display notification \"${body}\" with title \"${title}\" sound name \"${sound}\""
  else
    osascript -e "display notification \"${body}\" with title \"${title}\""
  fi
}

# _discord_post <content> [file-or-token...]  — subshell fn, returns 0 on HTTP 2xx.
_discord_post() (
  set -euo pipefail
  local content="$1"; shift
  [ -z "${DISCORD_WEBHOOK_URL:-}" ] && { echo "DISCORD_WEBHOOK_URL unset" >&2; exit 1; }

  local upload_files=() f sz
  for f in "$@"; do
    if [ -f "$f" ]; then
      sz="$(stat -f%z "$f" 2>/dev/null || echo 0)"
      if [ "$sz" -le "$_DISCORD_FILE_CAP" ]; then
        upload_files+=("$f")
      else
        content="${content} (attachment skipped, oversize: ${f})"
      fi
    else
      content="${content} ${f}"          # non-file token → text list
    fi
  done

  local json
  json="$(python3 - "$content" <<'PY'
import json, sys
print(json.dumps({"content": sys.argv[1]}))
PY
)"
  if [ "${#upload_files[@]}" -gt 0 ]; then
    local tmpjson; tmpjson="$(mktemp "${TMPDIR:-/tmp}/discord.XXXXXX.json")"
    printf '%s' "$json" > "$tmpjson"
    local args=(-F "payload_json=<${tmpjson}")
    for f in "${upload_files[@]}"; do
      args+=(-F "files[]=@${f};filename=$(basename "$f")")
    done
    curl -sS -f "${args[@]}" "$DISCORD_WEBHOOK_URL"
    rm -f "$tmpjson"
  else
    curl -sS -f -H "Content-Type: application/json" -d "$json" "$DISCORD_WEBHOOK_URL"
  fi
)

# --- public -----------------------------------------------------------------------
send_report() {
  local title="$1" body="$2"; shift 2
  local artifacts=""
  [ "$#" -gt 0 ] && artifacts=" Artifacts: $*"

  case "$REPORT_SINK" in
    macos_notification)
      _notify_macos "$title" "${body}${artifacts}"
      echo "$(date): [report_sink] macos_notification sent: $title" >> "$LOG"
      ;;
    discord_webhook)
      if _discord_post "${title} — ${body}" "$@" 2>>"$LOG"; then
        echo "$(date): [report_sink] discord_webhook sent ($# artifact(s)): $title" >> "$LOG"
      else
        echo "$(date): [report_sink] discord_webhook FAILED — fallback macos_notification: $title" >> "$LOG"
        _notify_macos "$title" "${body}${artifacts}"
      fi
      ;;
    slack_webhook)
      # v3: curl -H "Content-Type: application/json" -d "{\"text\":\"${body}${artifacts}\"}" "$SLACK_WEBHOOK_URL"
      echo "$(date): [report_sink] slack_webhook stub (v3) — not sent: $title" >> "$LOG"
      ;;
    noop)
      echo "$(date): [report_sink] noop: $title — ${body}${artifacts}" >> "$LOG"
      ;;
    *)
      echo "$(date): [report_sink] unknown REPORT_SINK='$REPORT_SINK' — fallback macos_notification" >> "$LOG"
      _notify_macos "$title" "${body}${artifacts}"
      ;;
  esac
}

send_error_report() {
  # Failure path: ALWAYS audible (Sosumi). Best-effort ALSO posts to Discord; a
  # Discord failure never suppresses the Sosumi.
  local title="$1" body="$2"
  case "$REPORT_SINK" in
    noop)
      echo "$(date): [report_sink] noop ERROR: $title — $body" >> "$LOG"
      ;;
    discord_webhook)
      if [ -n "${DISCORD_WEBHOOK_URL:-}" ] && _discord_post "⚠️ **${title}** — ${body}" 2>>"$LOG"; then
        echo "$(date): [report_sink] discord_webhook error POSTED: $title" >> "$LOG"
      else
        echo "$(date): [report_sink] discord_webhook error FAILED — audible only: $title" >> "$LOG"OG
      fi
      _notify_macos "$title" "$body" "Sosumi"
      ;;
    *)
      _notify_macos "$title" "$body" "Sosumi"
      ;;
  esac
}
```

> Note: the log macro is `$#` (artifact count) — not `${#@}` (which is the last arg's length, a classic shellcheck trap). §11 acceptance requires `shellcheck` clean; a `${#@}` regression fails it.

## 6. Interface — consumers (no edit needed to `weekly_review.sh`; one line in `capture_screens.sh`)

- **`weekly_review.sh`** (forkable-first canonical) is unchanged — it already calls `send_report "$REPO_NAME Weekly Review" "Weekly review ready: docs/reviews/$REVIEW_DATE.md" perf-summary.md update-log.md weekly/$REVIEW_DATE.csv`. Under the new sink the three tokens are non-file references → rendered as a text list; the body is the title.
- **`capture_screens.sh`** (forkable-first canonical):
  - **Success** (L252): pass the PNG as an artifact so it uploads as a Discord attachment:
    ```bash
    send_report "capture_screens.sh done" "captured $SCREEN ($size bytes)" "$OUT_FILE"
    ```
    (Currently the call passes no artifact → Discord would only show a path. This locks the 1-line edit.)
  - **Failure** (L80, in `fail()`): switch `send_report` → `send_error_report` so failures are audible **and** land in Discord:
    ```bash
    send_error_report "$title" "$body"
    ```

Both edits are to the **forkable** canonical `capture_screens.sh`; khelam pulls byte-identical (tripwire stays green).

## 7. Message formats (Discord markdown — no HTML)

### 7.1 Weekly review (`send_report`, text-only)
```
**📋 khelam Weekly Review — 2026-08-07 18:00**

Weekly review ready: `docs/reviews/2026-08-07.md`

Artifacts: performance-summary.md update-log.md weekly/2026-08-07.csv
```
- Under 2000c. The review doc path is a reference, not inlined (§2 #8). `Artifacts:` line lists the three `~/analytics/` tokens.

### 7.2 Screenshot success (`send_report` + PNG attachment)
`content`:
```
**✅ capture_screens.sh — `schedule`** captured (255 KB)
→ `docs/screenshots/booking-calendar/schedule_20260807_182012.png`
```
+ the PNG attached as `files[]`. Discord renders the image inline under the message. (Filename uses the repo-relative `docs/screenshots/...` path the script already writes.)

### 7.3 Session close-out (contract for the v2 wiring — report_sink already supports it)
`content`:
```
**📝 Session close-out — khelam** · 2026-08-07
Objective: <session objective line>
Batches: 1/1 · Trust: L2
Tokens: ~{in}K in / ~{out}K out
Status: `docs/sessions/2026-08-07.md`
Last: {last learnings log one-liner}
```
- Under 2000c. The hook that calls `send_report` at session end is **v2** (no agent-session code exists today to fire it); report_sink renders whatever it's given.

### 7.4 Error report (`send_error_report` — Sosumi + Discord)
`content`:
```
⚠️ **capture_screens.sh failed** — backend unreachable at http://127.0.0.1:8000/health (use --no-backend to skip)
```
- No artifact. Audible (Sosumi) fires regardless of Discord.

## 8. Sync strategy (forkable-first)

| Artifact | Canonical location | Sync mechanics | Why here |
|---|---|---|---|
| `scripts/report_sink.sh` (rewritten) | **forkable `scripts/`**; pulled copy khelam `scripts/` | Manual pull (`cp`); **forkable-sync tripwire** (`forkable_sync_check()` in `weekly_review.sh`) verifies `scripts/` byte-identical and flags child drift. | Shared delivery abstraction → forkable-first (OA#5). |
| `scripts/capture_screens.sh` (1-line: pass PNG + `send_error_report`) | **forkable `scripts/`**; pulled copy khelam `scripts/` | Same tripwire. | Consumer wiring is part of the shared capability. |
| `~/.config/khelam/discord.env` (secret) | **machine-local only** — not in either repo | Created by the user; never `git add`-ed; the scripts `source` it at start. | Secret never in tracked files (sandbox policy §3.3, forkable AGENTS.md Sandbox). |
| `docs/superpowers/specs/2026-08-07-comms-discord-design.md` | khelam `docs/superpowers/specs/` | Stays in khelam (per-repo planning doc; matches the screenshot-verification precedent). | Specs are per-repo, not shared capability scripts. |

Current state: `report_sink.sh` and `capture_screens.sh` are **byte-identical** forkable↔khelam (confirmed via `diff`). The rewrite edits the forkable canonical first; khelam is pulled from it.

## 9. Deviations from existing patterns

- **JSON escaping** (new): the v0 stub hand-rolled `"{\"content\":\"...\"}"`; the rewrite pipes every payload through `python3 json.dumps`. This adds a python3 call per `send_report` (already a dep: `capture_screens.sh` + `ccusage_collect.sh` use it). Justification: the stub's pattern silently 400s on any quote in a body.
- **`capture_screens.sh fail()` → `send_error_report`** (behavior change): failures were audible-via-`send_report`? No — they were **not** audible at all (plain `send_report`). The screenshot-verification spec §5 already promised audibility; this locks it. Not a khelam-first deviation — it's a forkable-first canonical edit.
- **File upload** (new): report_sink now attaches local files. Previously artifacts were text-only. Bounded by the 25 MiB cap + 10-file `files[]` limit.
- **`set -euo pipefail` in report_sink.sh** (new): the v0 file had no `set` line (relied on the caller). The callers (`weekly_review.sh` L10, `capture_screens.sh` L21) already set it, so re-setting is idempotent. Guarded by the subshell-function pattern so the sink never aborts its caller on a curl failure.

## 10. Deliverables (files)

| File | Purpose |
|---|---|
| `docs/superpowers/specs/2026-08-07-comms-discord-design.md` | This design doc |
| `forkable/scripts/report_sink.sh` | Canonical rewrite — Discord sink + fallbacks (new) |
| `khelam/scripts/report_sink.sh` | Pulled byte-identical copy |
| `forkable/scripts/capture_screens.sh` | Canonical: pass `$OUT_FILE` as artifact + `fail()`→`send_error_report` (edit) |
| `khelam/scripts/capture_screens.sh` | Pulled byte-identical copy |

**Implementation is the implementer's downstream task** (gated by this spec's §11 acceptance bar). Per the background-agent execution-model spec (§5 artifact set + §6 deferred), the implementation follows one **L2 batch** with a checkpoint commit.

## 11. Batch breakdown (single implementation batch — matches execution-model §2 #2 / §5 shape)

- **Batch 1 [L2] — Canonical rewrite + forkable-pull + mock test.** Edit `forkable/scripts/report_sink.sh` (§5 bodies) and `forkable/scripts/capture_screens.sh` (§6 edits) forkable-first; pull both byte-identical into khelam; run the mock-server capture test (§14). **Acceptance:** `bash -n report_sink.sh` + `bash -n capture_screens.sh` clean; `shellcheck` clean (no `${#@}` typo); mock server captures (a) one JSON POST with the expected `content`, and (b) one multipart POST with a `files[]` part + `payload_json`; `diff -rq forkable/scripts/{report_sink,capture_screens}.sh khelam/scripts/` = identical (tripwire green); `send_report`/`send_error_report` never abort the caller on a curl failure (verified via `_discord_post` non-zero in an `if`). Checkpoint commit `comms/discord-v1-report-sink`. **Est ~4 k tokens** (bash rewrite is cheap; cost is the mock harness + reasoning).

> Rationale for one batch vs three: this is a ~80-line bash edit with no Dart/Flutter surface, no build, no live backend, and a deterministic in-process mock test. Splitting into three batches would multiply fixed per-batch overhead (status file, commit, re-read) for ~no risk isolation. The screenshot-verification spec used 3 batches only because B2 required a booted iOS simulator — a hardware gate that forces a separate L1 cycle. There is no such gate here.

## 12. Acceptance bar

1. `bash -n forkable/scripts/report_sink.sh` and `…/capture_screens.sh` exit 0.
2. `shellcheck forkable/scripts/report_sink.sh` reports no issues (in particular no `${#@}` macro typo → uses `$#`).
3. Mock webhook (§14 mock test) captures, for a text call: a JSON body `{"content":"<title> — <body>"}` whose `content` equals the expected string; and for a file call: a `multipart/form-data` body containing a `payload_json` part + a `files[]` part whose filename matches the uploaded file's basename.
4. Fallback verified: with `DISCORD_WEBHOOK_URL` **unset** and `REPORT_SINK=discord_webhook`, `send_report "t" "b" /tmp/x.png` emits a `macos_notification` (osascript, no Sosumi) and logs the fallback line — no crash, no drop.
5. Error audibility verified: `REPORT_SINK=discord_webhook` + webhook URL **pointed at a closed port** (curl fails), `send_error_report "t" "b"` → Sosumi fires AND a `discord_webhook error FAILED — audible only` log line is written; the script does not abort.
6. **Tripwire:** `diff -rq ~/projects/forkable/scripts/{report_sink,capture_screens}.sh ~/projects/khel-service/khelam/scripts/` exits 0 (byte-identical).
7. **Real-webhook E2E** (user-only; §14 acceptance): user pastes a real webhook URL in `~/.config/khelam/discord.env`, sets `REPORT_SINK=discord_webhook` on the launchd plist (§15 step 4), runs the weekly review (or `send_report "test" "hello"`) → message appears in the Discord channel with correct `content` (and PNG attachment for the screenshot path).

## 13. Failure / fallback table

| Trigger | `discord_webhook` path | Fallback | Audible? |
|---|---|---|---|
| `DISCORD_WEBHOOK_URL` unset | skip POST | `macos_notification` (osascript, no sound) + log line `… DISCORD_WEBHOOK_URL unset … fallback` | no |
| `curl` HTTP ≥ 400 (`-f`) | POST fails (exit 1) | `macos_notification` + log `… FAILED — fallback` | no |
| `curl` network failure | POST fails | `macos_notification` + log `… FAILED — fallback` | no |
| `DISCORD_ENV_FILE` missing | same as unset | `macos_notification` + log | no |
| File artifact > 25 MiB | skipped with `(attachment skipped, oversize: …)` note in `content`; text-only POST | still posts content; no fallback needed | no |
| `send_error_report` + Discord fails | `send_report`-style fallback inside error branch | log `… audible only`; **Sosumi fires** | **yes (always)** |
| `send_error_report` + `DISCORD_WEBHOOK_URL` unset | skip POST | log `… audible only` | **yes (always)** |
| Unknown `REPORT_SINK` | n/a | `macos_notification` + log | no |
| `noop` | n/a | log to `$WEEKLY_LOG` only | no (by design) |

## 14. Test plan (NO real Discord webhook required)

### 14.1 Mock server (captures POSTs, returns 204)
A 10-line inline python3 HTTP server bound to `127.0.0.1:8099`, writing each POST body to `/tmp/discord-mock-capture.bin`. Returns `204 No Content` (Discord's default success shape). Run in the background:
```bash
python3 - <<'PY' &
import http.server, socketserver
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        l=int(self.headers.get('Content-Length',0)); body=self.rfile.read(l)
        open('/tmp/discord-mock-capture.bin','ab').write(body+b'\n')
        self.send_response(204); self.end_headers()
    def log_message(self,*a): pass
socketserver.TCPServer(('127.0.0.1',8099),H).serve_forever()
PY
MOCK_PID=$!
```

### 14.2 Capture test (text path)
```bash
. forkable/scripts/report_sink.sh
REPORT_SINK=discord_webhook DISCORD_WEBHOOK_URL=http://127.0.0.1:8099/wh REPO_OVERRIDE=… \
  send_report "khelam Weekly Review" "Weekly review ready" "weekly/2026-08-07.csv"
python3 - <<'PY'   # parse the captured POST, assert content
import json
raw=open('/tmp/discord-mock-capture.bin','rb').read().split(b'\n')[-2]  # last body
# text path is JSON
p=json.loads(raw)
assert p['content'].startswith('khelam Weekly Review — '), p['content']
assert 'weekly/2026-08-07.csv' in p['content'], p['content']
print('TEXT POST OK:', p['content'][:80])
PY
```

### 14.3 Capture test (file path — screenshot)
```bash
printf '\x89PNG\r\n\x1a\n' > /tmp/fake.png   # 8-byte fake PNG header
REPORT_SINK=discord_webhook DISCORD_WEBHOOK_URL=http://127.0.0.1:8099/wh \
  send_report "capture_screens.sh done" "captured schedule (8192 bytes)" "/tmp/fake.png"
python3 - <<'PY'   # assert multipart with files[] + payload_json
import re
raw=open('/tmp/discord-mock-capture.bin','rb').read().split(b'\n')[-2]
assert b'name="files[]"' in raw and b'filename="fake.png"' in raw, 'no files[] part'
assert b'"payload_json"' in raw, 'no payload_json part'
print('FILE POST OK: multipart with png attachment')
PY
```

### 14.4 Fallback / audibility tests
```bash
# (a) URL unset → macos_notification, no drop
unset DISCORD_WEBHOOK_URL
REPORT_SINK=discord_webhook send_report "t" "b" "x"   # expect osascript + log line

# (b) error report survives a dead webhook (closed port) → Sosumi still fires
REPORT_SINK=discord_webhook DISCORD_WEBHOOK_URL=http://127.0.0.1:1/no-such \
  send_error_report "boom" "backend unreachable"      # expect Sosumi + log "audible only"
```

### 14.5 Real-webhook E2E acceptance (user-only)
After §15 enablement: user runs the weekly review (or a manual `send_report "test" "hello"`) and **manually confirms** a message appears in the Discord channel. The shell scripts cannot self-verify a real channel post (no read-back API for incoming webhooks) — human eyeball is the gate.

## 15. User enablement path

1. **Create a Discord webhook** in the target channel: *Channel Settings → Integrations → Webhooks → New Webhook → Copy Webhook URL*. You get `https://discord.com/api/webhooks/<id>/<token>`.
2. **Store it locally (machine-only):**
   ```bash
   mkdir -p ~/.config/khelam
   printf 'DISCORD_WEBHOOK_URL=%s\n' "<paste-the-url-here>" > ~/.config/khelam/discord.env
   chmod 600 ~/.config/khelam/discord.env
   ```
   The file is outside every repo → `git status` never sees it; nothing to gitignore. (Same pattern the task-dashboard spec uses for `sb.env`.)
3. **Enable the sink** in your shell / launchd:
   ```bash
   export REPORT_SINK=discord_webhook        # for an interactive test
   send_report "test" "hello from report_sink"
   ```
4. **Automate the weekly review (machine-local launchd):** edit the **installed** plist — `cat ~/Library/LaunchAgents/com.khelam.weekly-review.plist` — and add under `<key>EnvironmentVariables</key>` a new pair:
   ```xml
   <key>REPORT_SINK</key><string>discord_webhook</string>
   ```
   Then `launchctl unload ~/Library/LaunchAgents/com.khelam.weekly-review.plist && launchctl load ~/Library/LaunchAgents/com.khelam.weekly-review.plist`. (The **canonical** forkable `com.khelam.weekly-review.plist` is intentionally NOT edited — `REPORT_SINK` is a machine-local policy, and the file is never the source of the secret, only the toggle.)
5. **Verify** (§14 real-webhook E2E): confirm the weekly-review message lands in-channel after the next run.

## 16. Deferred scope (v2)

- **Session-close-out wiring** (§7.3): no agent-session code currently calls `send_report` at end-of-session. report_sink supports the format; a downstream hook (reads `$SESSION_FILE` + token totals → `send_report`) is v2.
- **Weekly review doc as a Discord attachment**: the ~60-line review markdown could be uploaded via `files[]` if the channel wants the full doc in-message. V1 references it by path (§2 #8) to stay under 2000c; V2 may attach on request.
- **Embeds**: today every message is plain `content` (under 2000c). If a message grows structured, switch to an embed array (≤10, 6000c) — v2.
- **`slack_webhook`**: reserved for v3 (kept stub, §2 #6).
- **Rate-limit coalescing**: only if a future feature fans out >10 msgs/run (>½ the 30/min budget) — not needed now.

## 17. Token-cost note

Implementation batch (§11) est **~4 k tokens** (bash rewrite + mock harness + tripwire) — within the free tier ($0), consistent with `performance-summary.md` Week 1. A cost-note line should be added to the implementer's session file before starting per Cost Discipline rules.

---

## v2 — Multi-Channel Cross-Project Hub (locked 2026-08-07, Grill Gate 12/12)

> Supersedes the v2-deferred list in §16 for **channel routing** and adds a **cross-project daily digest**. v2 is **additive over v1**: every v1 caller (`send_report`, `send_error_report`, the env-file contract) keeps byte-compatible behavior. Canonical edits are forkable-first (§8); the khelam copies are pulled byte-identical (tripwire `forkable_sync_check()` enforces). OA#8 in `khelam/docs/reviews/review-memory.md` (OPEN — next queue).

### V1. Channel topology (per concern, one webhook per channel)

| Channel | Env key | Producers |
|---|---|---|
| `default` | `DISCORD_WEBHOOK_URL` (v1 alias) | v1 callers, unknown/empty channel resolution |
| `daily-overview` | `DAILY_OVERVIEW_WEBHOOK_URL` | `daily_digest.sh` (08:00 Mon–Fri) |
| `weekly-reviews` | `WEEKLY_REVIEWS_WEBHOOK_URL` | `weekly_review.sh` success report |
| `screenshots` | `SCREENSHOTS_WEBHOOK_URL` | `capture_screens.sh` success (PNG attachment) |
| `agent-errors` | `AGENT_ERRORS_WEBHOOK_URL` | `send_error_report` (always) |

Channel names resolve case-insensitively; `-` and `_` are interchangeable. **Resolution rules** (`_discord_url_for <channel>`):
1. `default` → `DISCORD_WEBHOOK_URL` directly.
2. any other name → its own key (`UPPER` + `-`→`_` + `_WEBHOOK_URL`), else the `DISCORD_WEBHOOK_URL` alias, else empty.
3. unknown names resolve to `default`. Empty resolution → `macos_notification` + log (never drops — same failure behavior as v1).

### V2. Env schema (shared, machine-local)

- All webhook keys live in **one** shared file `~/.config/opencode/discord.env` (never in any repo). **`DISCORD_ENV_FILE` default moved from `~/.config/khelam/discord.env` to `~/.config/opencode/discord.env`** (home of the global agent config; the khelam path was a leftover of the pre-global layout). `DISCORD_ENV_FILE` override still honored.
- Schema (one key per line, `KEY=url`):
  ```
  DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/<id>/<token>   # v1 alias
  DAILY_OVERVIEW_WEBHOOK_URL=…
  WEEKLY_REVIEWS_WEBHOOK_URL=…
  SCREENSHOTS_WEBHOOK_URL=…
  AGENT_ERRORS_WEBHOOK_URL=…
  ```
- User creates the file later (webhook URLs unknown at implementation time); tests use URL env vars set inline. A channel with no URL of its own still delivers via the v1 alias — partial setups degrade gracefully.

### V3. API (report_sink.sh v2 — additive)

- `send_report_to <channel> <title> <body> [artifact...]` — routes to the channel's resolved URL (multipart `payload_json`+`files[]` ≤25 MiB cap, python3 json.dumps, `curl -sS -f`, 2xx-only, mktemp cleanup — all unchanged from v1). Unresolved URL → macos fallback + log, exit 0.
- `send_report` — now `send_report_to default ...` (v1 callers unchanged, byte-compatible).
- `send_error_report <title> <body>` — signature unchanged; **always** targets `agent-errors` (Sosumi always + best-effort Discord, v1 semantics). Existing callers (`capture_screens.sh fail()`) need no edit.
- `_discord_post` core unchanged but now takes the **resolved URL** as `$1` (`_discord_post <url> <content> [file-or-token...]`).

### V4. `daily_digest.sh` (NEW, forkable-first canonical)

Reports the **previous calendar day** across khelam/forkable/commons in **one** `send_report_to daily-overview` message (body capped ≤1900 chars for the Discord 2000 cap; truncate with `… [truncated]`).

- **Repo env hooks** (mirror `weekly_review.sh`): `KHELAM_REPO` / `FORKABLE_REPO` / `COMMONS_REPO` (defaults `~/projects/khel-service/khelam`, `~/projects/forkable`, `~/projects/commons`); missing dir → skipped with a note, exit 0. `DB_PATH` overrides `~/.local/share/opencode/opencode.db`.
- **Signal 1 — token deltas**: sqlite3 over the `session` table (`SUM(tokens_input+tokens_output+tokens_cache_read)`, `COUNT(*)`), matched by `directory LIKE '%/<repo_basename>'` and `time_created` in **yesterday local midnight→midnight** (UNIX ms — the same epoch convention `session_boundary_check()` uses; window computed via python3 local `datetime.timestamp()`). Human-readable k/M per repo.
- **Signal 2 — Open Actions**: from each repo's `docs/reviews/review-memory.md`, count `## Open Actions...` section lines that are **not struck through** (`~~`); list up to 3 titles (~60 chars). Heuristic documented in the script header (excludes blockquotes/table chrome/placeholders; numbered khelam rows render as `OA#8: <title>`).
- **Signal 3 — untriaged backlog**: from each repo's `docs/backlog.md`, count top-level `^- ` bullets; list up to 3 titles (~60 chars). Documented heuristic: counts all column-0 bullets incl. watchpoint/DONE-note sections (stricter untriaged-only filter = future work); `- (empty)` placeholders excluded.
- **Session activity count**: number of `docs/sessions/<yesterday>.md` files across the repos (may be 0).
- Format (fixed emoji set): `🔥 Yesterday's agent tokens — … | …` / `📋 Open Actions: …` / `🗂 Backlog: …` / `📄 Sessions yesterday: N`.
- Exit codes: 0 always after assembly (send degrades via report_sink); 1 only if `report_sink.sh` is missing beside it.
- Logging: `$(date): [daily_digest] …` → `$LOG` (default `/tmp/weekly-review.log`).

### V5. Launchd template + instance model

- `com.khelam.daily-digest.plist` (NEW template, forkable/scripts/, mirrors `com.khelam.weekly-review.plist` style): Label `com.khelam.daily-digest`, `/bin/bash <installed path>/daily_digest.sh`, `StartCalendarInterval` **Weekday 1–5 @ Hour 8 Minute 0** — one dict per weekday (launchd fires only on listed weekdays; a single range is not supported), `StandardOutPath`/`StandardErrorPath` → `/tmp/daily-digest.log`, `RunAtLoad false`.
- **Install = user step** (never auto-installed): copy to `~/Library/LaunchAgents/`, fill the path placeholder, `launchctl load`. Same machine-local policy as the weekly plist (env keys stay in `~/.config/opencode/discord.env`, the plist never holds secrets).
- `capture_screens.sh` success call → `send_report_to screenshots …` (one-line change); `weekly_review.sh` success call → `send_report_to weekly-reviews …` (keeps the 3 artifact tokens). `fail()`/`send_error_report` unchanged (→ `agent-errors` automatically).

### V6. §14 test extension (multi-channel)

Beyond the v1 §14.1–14.4 cases (v1 regression: `send_report`/`send_error_report` under only `DISCORD_WEBHOOK_URL` behave exactly as v1 — alias path, ⚠️ error prefix, URL-unset → macos fallback, dead URL → Sosumi + log, exit 0 always):

- Mock server (same shape as §14.1, 127.0.0.1:8099) records bodies **per path**.
- (a) `send_report_to daily-overview` → hits `/daily` only; (b) `weekly-reviews` → `/weekly` only; (c) `screenshots` + fake PNG → `/shots` multipart (`files[]`+`payload_json`); (d) unknown channel `bogus` → falls back to the `DISCORD_WEBHOOK_URL` alias if set, else macos fallback (exit 0); (e) channel key unset but alias set → alias fallback, no macos fallback. Plus: `send_error_report` with `AGENT_ERRORS_WEBHOOK_URL` set → `/errors` with ⚠️ prefix.
- `daily_digest.sh` run against real repo dirs + mock `/daily`: exactly **one** POST, body contains `Daily overview —` + all three repo names + a token number each + `Open Actions`/`Backlog`/`Sessions` lines, ≤1900 chars; with a bogus repo dir → still exit 0, skip noted in body/log.

### V7. Rollout

v2 ships additive over v1 (no consumer of v1 is broken; only the `DISCORD_ENV_FILE` **default** moves — the override var and inline-var behavior are unchanged). Reference checkpoint commit (implemented, NOT to be committed by the implementer): `comms/discord-v2-multi-channel`. Post-review: user creates `~/.config/opencode/discord.env`, sets `REPORT_SINK=discord_webhook`, and installs the daily-digest plist.

---

## Amendment — 2026-08-10 (weekly-review delivery v2: summary + chart)

User sign-off via question tool ("Summary + charts", 2026-08-10). Amends the *implementation* of Decision #8 (its rationale — 2000c cap, doc never inlined — is untouched):

- **Message body**: the review agent now writes a purpose-built Discord summary (`docs/reviews/<date>.discord.txt`, SECTION D in `weekly_review.sh`'s prompt, **≤1600 chars**, plain Discord markdown: bolded headline numbers line + 3-6 shipped bullets + one ⚠ waste/cut line + the full-review pointer). The script clamps it to 1900c as a safety net; falls back to the old pointer text if the file is missing. The review doc itself is still NOT inlined.
- **Real attachments** (previously text-only path tokens per §6 — they resolved against `$REPO` and never uploaded): weekly CSV, `performance-summary.md`, `update-log.md`, and the new chart PNG, all passed as absolute paths → multipart `files[]`.
- **Chart**: new `scripts/review_chart.py` (uv inline-script metadata, matplotlib via uv cache — no system install). Stacked per-day token bars (input/output/cache-read/reasoning) from the weekly CSV + totals annotation. Failure degrades to a no-chart post (WARNING log), never blocks delivery.
- **Bug fix**: the old call referenced `weekly/$REVIEW_DATE.csv` which **never exists** — the collector names week files by `date -v-1d`. `weekly_review.sh` now resolves the real latest week file (`WEEK_CSV_NAME`, computed after the collector) and uses it in the prompt + attachment.
- Consumers unaffected: `daily_digest.sh` (own body), `capture_screens.sh`, `send_error_report`.

### Amendment 2 — 2026-08-10 (delivery fixes after live v2 review)

User feedback on the live v2 post (2026-08-10):
- **Multipart bug fixed in `report_sink.sh` `_discord_post`**: files were posted as unindexed `files[]` with NO `attachments` array in `payload_json` — Discord attached only the FIRST file and silently dropped the rest (v2 post showed the CSV, lost the PNG + .md chips; single-file screenshot posts had masked the bug). Now: `payload_json` carries `attachments: [{id, filename}]` and files are posted as `files[<id>]`. Verified live against the real API (3/3 files attached, PNG content-type + dimensions returned).
- **Summary format tightened (SECTION D v2)**: headline numbers only (sessions · tokens · cost); "Shipped:" ONE comma-separated sentence of short deliverable names (no batch codenames, no clauses); up to 3 numbered lines ≤12 words for waste/cuts; 900c hard cap (was 1600 + bullets).
- **Chart XOR CSV**: when the chart PNG renders, the raw CSV is NOT attached (chart is the data viz); CSV returns as fallback if chart generation fails.

### Amendment 3 — 2026-08-10 (v3: three beautified text messages, no attachments)

User decision (2026-08-10): no .md files on Discord; each section = a separate message; meaningful metrics only; skip update-log; pause chart/PNG (re-plan later); agent + user metrics formatted properly. @architect design approved.

- **Delivery**: 3 sequential messages, ZERO attachments — Summary / Agent Metrics / User Metrics. `weekly_review.sh` SECTION D now writes `docs/reviews/<date>.discord.{summary,agent,user}.txt`; delivery sends each via `send_report_to weekly-reviews "" <body>` (empty title — body leads with emoji headline), clamped to 1900c per message (Discord cap 2000); missing file → pointer fallback; never blocks.
- **Message 1 Summary**: `📊 **Weekly Review <date> — N sessions · XM tokens · $Y cost**` headline; `🚀 **What shipped this week** (<N> groups)` — numbered lines `N. **Group** — one short sentence`, batched by CONCERN (robustness / user-facing feature / comms / tooling / governance), max 5 groups, no batch codenames; `⚠️ **Top waste**` (≤2 lines); `✅ **Resolved this cycle**` (already-fixed items go here, NOT in Focus); `🎯 **Focus next week** (what / why / who)` — ≤3 numbered plain-language items, `_Held to <date>._` when done-but-uncommitted; final `📄 Full review:` pointer.
- **Message 2 Agent metrics**: 🤖 headline; sessions (total + per-repo + top-level/subagent), tokens (input/output/cache + cost), cache efficiency, model mix, 4-week trend, top 3 token hogs, verification runs, codegraph/graphify lookups, waste incidents by category, estimate accuracy.
- **Message 3 User metrics**: 🧑 headline; sessions initiated (opencode.db `parent_id IS NULL`), active days + cadence, longest idle gap + most active day, sidetrack patterns (✅ 0 / 🎯 N — cause), nudges issued, cheaper-phrasing example, data-source caveat. NEW `user_session_stats()` shell helper computes the DB stats into the PROMPT (modeled on `session_boundary_check`).
- **Chart**: PAUSED — `review_chart.py` retained on disk but never called; CSV attachment also dropped (no attachments at all).
- **report_sink.sh fixes surfaced by the first v3 delivery**: (1) bash 3.2 (macOS system bash) `set -u` "unbound variable" on the ZERO-artifact path (`"${upload_files[@]}"` on an empty array) — the v3 flow was the first to post artifact-less; fixed with `${arr[@]+"${arr[@]}"}`. (2) `_notify_macos` AppleScript escaping (backslash + double-quote) — the "never drops" fallback was producing osascript syntax errors (-2740) on emoji/quotes bodies and silently showing NOTHING.

### FINALIZED — 2026-08-10

User ratified the v3 structure ("Finalize this as weekly review structure") — the three-message delivery (📊 Summary / 🤖 Agent metrics / 🧑 User metrics, no attachments, no update-log, chart paused) is the **standing weekly-review structure** from 2026-08-10 onward. The live 10:16 delivery is the canonical example (message bodies archived at `docs/reviews/2026-08-10.discord.{summary,agent,user}.txt`). Any future format change goes through a design round again.
