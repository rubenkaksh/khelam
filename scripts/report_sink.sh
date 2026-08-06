#!/bin/bash
# report_sink.sh — delivery abstraction for background-agent reports.
#
# Usage:  send_report <title> <body> [artifact...]
#         (source this file from other scripts:  . scripts/report_sink.sh)
#
# Honors REPORT_SINK env:
#   macos_notification (default) — osascript display notification, lists artifacts
#   discord_webhook / slack_webhook — curl stubs (v2 comms integration, see design)
#   noop — testing; logs to /tmp/weekly-review.log only
#
# Artifacts are listed in the notification body so the user knows what was produced.

REPORT_SINK="${REPORT_SINK:-macos_notification}"
LOG="${WEEKLY_LOG:-/tmp/weekly-review.log}"

send_report() {
  local title="$1"
  local body="$2"
  shift 2
  local artifacts=""
  if [ "$#" -gt 0 ]; then
    artifacts=" Artifacts: $*"
  fi

  case "$REPORT_SINK" in
    macos_notification)
      osascript -e "display notification \"${body}${artifacts}\" with title \"${title}\"" >> "$LOG" 2>&1
      echo "$(date): [report_sink] macos_notification sent: $title" >> "$LOG"
      ;;
    discord_webhook)
      # v2: curl -H "Content-Type: application/json" -d "{\"content\":\"${body}${artifacts}\"}" "$DISCORD_WEBHOOK_URL"
      echo "$(date): [report_sink] discord_webhook stub (v2) — not sent: $title" >> "$LOG"
      ;;
    slack_webhook)
      # v2: curl -H "Content-Type: application/json" -d "{\"text\":\"${body}${artifacts}\"}" "$SLACK_WEBHOOK_URL"
      echo "$(date): [report_sink] slack_webhook stub (v2) — not sent: $title" >> "$LOG"
      ;;
    noop)
      echo "$(date): [report_sink] noop: $title — ${body}${artifacts}" >> "$LOG"
      ;;
    *)
      echo "$(date): [report_sink] unknown REPORT_SINK='$REPORT_SINK' — falling back to macos_notification" >> "$LOG"
      osascript -e "display notification \"${body}${artifacts}\" with title \"${title}\"" >> "$LOG" 2>&1
      ;;
  esac
}

send_error_report() {
  # Failure path: always audible (unique sound) regardless of sink.
  local title="$1"
  local body="$2"
  case "$REPORT_SINK" in
    noop)
      echo "$(date): [report_sink] noop ERROR: $title — $body" >> "$LOG"
      ;;
    *)
      osascript -e "display notification \"${body}\" with title \"${title}\" sound name \"Sosumi\"" >> "$LOG" 2>&1
      ;;
  esac
}
