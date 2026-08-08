#!/bin/bash
# report_sink.sh — delivery abstraction for background-agent reports (v2: multi-channel Discord).
#
# Usage:  send_report <title> <body> [artifact...]
#         send_report_to <channel> <title> <body> [artifact...]
#         send_error_report <title> <body>   # always audible (Sosumi); best-effort Discord
#         (. scripts/report_sink.sh)
#
# REPORT_SINK env:
#   macos_notification (default) — osascript display notification, lists artifacts
#   discord_webhook — POST JSON to Discord (per-channel webhook URLs, see below)
#   slack_webhook — stub (v3 reserved; kept for option value, no behavior yet)
#   noop — testing; logs to $WEEKLY_LOG only
#
# send_report_to returns 0 when the message reached its sink; in discord_webhook
# mode it returns 1 when the Discord post FAILED (the macos_notification fallback
# still fires first — never drops — but callers that want to retry can see it).
# Callers running under `set -e` must use it in a conditional or guard with
# `|| true`. An EMPTY title posts the body as-is (no " — " prefix) — used by the
# daily digest's per-section messages where only message 1 carries the date
# heading in its title.
#
# Channels (name → env key; all keys live in the shared env file, see Secret):
#   default        → DISCORD_WEBHOOK_URL            (v1 alias, backward-compatible)
#   daily-overview → DAILY_OVERVIEW_WEBHOOK_URL
#   weekly-reviews → WEEKLY_REVIEWS_WEBHOOK_URL
#   screenshots    → SCREENSHOTS_WEBHOOK_URL
#   agent-errors   → AGENT_ERRORS_WEBHOOK_URL
# Channel names resolve case-insensitively; '-' and '_' are interchangeable.
# Resolution: the channel's own key first, then the 'default' alias
# (DISCORD_WEBHOOK_URL) as a fallback — so a channel with no URL of its own
# still delivers via the v1 webhook. Unknown channel names resolve to 'default'.
# An unresolved (empty) URL degrades to macos_notification + log, never drops.
#
# Secret: every webhook URL is a SECRET (anyone holding one can post to the
# channel). They are sourced from $DISCORD_ENV_FILE (default
# ~/.config/opencode/discord.env — v2 moved the default from ~/.config/khelam/) —
# a machine-local file OUTSIDE all repos, never committed. Format:
#   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/<id>/<token>
#   DAILY_OVERVIEW_WEBHOOK_URL=…
#   WEEKLY_REVIEWS_WEBHOOK_URL=…
#   SCREENSHOTS_WEBHOOK_URL=…
#   AGENT_ERRORS_WEBHOOK_URL=…
# If a channel's URL is absent, that channel falls back to the default alias,
# else to macos_notification + log (never drops). send_error_report always
# targets the agent-errors channel.
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
# v2: shared cross-project env file default moved from ~/.config/khelam/ to
# ~/.config/opencode/ (home of the global agent config). Override via
# DISCORD_ENV_FILE. All per-channel webhook keys are loaded from here.
DISCORD_ENV_FILE="${DISCORD_ENV_FILE:-$HOME/.config/opencode/discord.env}"
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

# _discord_url_for <channel> — prints the resolved webhook URL, or empty.
# Eval-free indirection via bash ${!key}. Channel key = UPPER + '-'→'_' +
# '_WEBHOOK_URL'. 'default' (and anything unresolved) → DISCORD_WEBHOOK_URL alias.
_discord_url_for() {
  local channel="$1" key url
  if [ "$channel" = "default" ]; then
    url="${DISCORD_WEBHOOK_URL:-}"
  else
    key="$(printf '%s' "$channel" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_WEBHOOK_URL"
    url="${!key:-}"
  fi
  [ -z "$url" ] && url="${DISCORD_WEBHOOK_URL:-}"
  printf '%s' "$url"
}

# _discord_post <url> <content> [file-or-token...]  — subshell fn, returns 0 on HTTP 2xx.
_discord_post() (
  set -euo pipefail
  local url="$1" content="$2"; shift 2
  [ -z "$url" ] && { echo "discord webhook URL unset (channel resolution empty)" >&2; exit 1; }

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
    curl -sS -f "${args[@]}" "$url"
    rm -f "$tmpjson"
  else
    curl -sS -f -H "Content-Type: application/json" -d "$json" "$url"
  fi
)

# --- public -----------------------------------------------------------------------
send_report_to() { # send_report_to <channel> <title> <body> [artifact...]
  local channel="$1" title="$2" body="$3"; shift 3
  local artifacts="" url
  [ "$#" -gt 0 ] && artifacts=" Artifacts: $*"
  url="$(_discord_url_for "$channel")"

  case "$REPORT_SINK" in
    macos_notification)
      _notify_macos "$title" "${body}${artifacts}"
      echo "$(date): [report_sink] macos_notification sent: $title" >> "$LOG"
      ;;
    discord_webhook)
      local content
      if [ -n "$title" ]; then
        content="${title} — ${body}"
      else
        content="${body}"   # empty title → no " — " prefix (multi-message digests: only msg 1 carries the date heading)
      fi
      if _discord_post "$url" "$content" "$@" 2>>"$LOG"; then
        echo "$(date): [report_sink] discord_webhook sent to '$channel' ($# artifact(s)): $title" >> "$LOG"
      else
        echo "$(date): [report_sink] discord_webhook FAILED — fallback macos_notification: $title" >> "$LOG"
        _notify_macos "$title" "${body}${artifacts}"
        return 1   # Discord failed (fallback already fired) — lets callers retry
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

send_report() { # send_report <title> <body> [artifact...] — v1 alias for the default channel
  send_report_to default "$@"
}

send_error_report() {
  # Failure path: ALWAYS audible (Sosumi). Best-effort ALSO posts to the
  # agent-errors channel (resolved via the shared env); a Discord failure
  # never suppresses the Sosumi.
  local title="$1" body="$2"
  local url
  url="$(_discord_url_for "agent-errors")"
  case "$REPORT_SINK" in
    noop)
      echo "$(date): [report_sink] noop ERROR: $title — $body" >> "$LOG"
      ;;
    discord_webhook)
      if [ -n "$url" ] && _discord_post "$url" "⚠️ **${title}** — ${body}" 2>>"$LOG"; then
        echo "$(date): [report_sink] discord_webhook error POSTED: $title" >> "$LOG"
      else
        echo "$(date): [report_sink] discord_webhook error FAILED — audible only: $title" >> "$LOG"
      fi
      _notify_macos "$title" "$body" "Sosumi"
      ;;
    *)
      _notify_macos "$title" "$body" "Sosumi"
      ;;
  esac
}
