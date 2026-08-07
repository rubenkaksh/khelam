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
        echo "$(date): [report_sink] discord_webhook error FAILED — audible only: $title" >> "$LOG"
      fi
      _notify_macos "$title" "$body" "Sosumi"
      ;;
    *)
      _notify_macos "$title" "$body" "Sosumi"
      ;;
  esac
}
