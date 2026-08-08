#!/bin/bash
# codegraph_refresh.sh — per-repo CodeGraph incremental refresh (hook-driven).
#
# Forkable-first canonical copy: forkable/scripts/codegraph_refresh.sh
# Children pull an identical copy; the forkable-sync tripwire diffs scripts/.
#
# Called DETACHED by the post-commit hook (see git-hooks/post-commit.codegraph)
# in every repo that has a .codegraph/ index. Refreshes the local index for
# changes since the last index. Never blocks the commit — the hook backgrounds
# this script; any failure is logged + notified via report_sink (rate-limited).
#
# DESIGN (user-locked, 2026-08-08): hook-only refresh. There is no launchd
# timer and no master-loop. A weekly freshness_check() in weekly_review.sh
# catches a broken hook (stale index past FRESHNESS_DAYS).
#
# Usage:  codegraph_refresh.sh <repo-path>
# Env:    FORKABLE_REPO (fallback script path for repos with no scripts/, e.g. commons)
#         REPORT_SINK   (forwarded to report_sink.sh)
set -uo pipefail

repo="${1:-}"
if [ -z "$repo" ]; then
    echo "[codegraph] usage: codegraph_refresh.sh <repo-path>" >&2
    exit 2
fi
# Resolve to an absolute path (the hook passes a toplevel already, but be safe).
repo="$(cd "$repo" 2>/dev/null && pwd)" || { echo "[codegraph] repo path not found: $repo" >&2; exit 2; }
reponame="$(basename "$repo")"

LOG_DIR="${HOME}/.cache"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/codegraph-refresh-${reponame}.log"

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] [codegraph-refresh:${reponame}] $*" >> "$LOG_FILE"; }

# Resolve report_sink.sh for failure notification (forkable-first canonical).
sink=""
for _s in "$repo/scripts/report_sink.sh" \
          "${FORKABLE_REPO:-$HOME/projects/forkable}/scripts/report_sink.sh"; do
    [ -f "$_s" ] && sink="$_s" && break
done

# notify_error: best-effort delivery to #agent-errors (+ macos fallback).
# Rate-limited to one notification per hour per repo to avoid spamming on
# repeated failed commits. NEVER masks the sync exit code.
notify_error() {
    local title="$1" body="$2"
    log "NOTIFY: $title — $body"
    [ -n "$sink" ] || { log "no report_sink.sh found — skipping notification"; return 0; }
    local rate_marker="$LOG_DIR/codegraph-refresh-${reponame}.last_notify"
    local now_epoch; now_epoch="$(date +%s)"
    if [ -f "$rate_marker" ]; then
        local last_epoch; last_epoch="$(cat "$rate_marker" 2>/dev/null || echo 0)"
        if [ $(( now_epoch - last_epoch )) -lt 3600 ]; then
            log "notify suppressed by rate-limit ($(( now_epoch - last_epoch ))s since last)"
            return 0
        fi
    fi
    echo "$now_epoch" > "$rate_marker"
    ( . "$sink" && send_error_report "$title" "$body" ) >> "$LOG_FILE" 2>&1 \
        || log "report_sink failed to deliver (best-effort; sync failure still reported)"
}

# --- status short-circuit -------------------------------------------------
# Cheap guard: if codegraph reports zero pending changes, skip the sync. This
# avoids a no-op rebuild when commits cluster (back-to-back commits). Falls back
# to "always sync" if codegraph or python3 are unavailable — safe default.
PENDING=1
if command -v codegraph >/dev/null 2>&1 && [ -d "$repo/.codegraph" ]; then
    if status_json="$(codegraph status --json "$repo" 2>/dev/null)" && \
       command -v python3 >/dev/null 2>&1; then
        PENDING="$(printf '%s' "$status_json" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    pc = d.get("pendingChanges", {})
    print(int(pc.get("added", 0)) + int(pc.get("modified", 0)) + int(pc.get("removed", 0)))
except Exception:
    print(1)  # on any parse error, default to "sync" (safe)
' 2>/dev/null || echo 1)"
    fi
fi
if [ "${PENDING:-1}" = "0" ]; then
    log "skipped (pendingChanges=0)"
    exit 0
fi

# --- sync -----------------------------------------------------------------
log "sync start (pendingChanges=${PENDING:-unknown})"
if command -v codegraph >/dev/null 2>&1; then
    if codegraph sync --quiet "$repo" >> "$LOG_FILE" 2>&1; then
        log "sync OK"
        exit 0
    fi
    rc=$?
    log "sync FAILED (rc=$rc)"
    # Stale lock? codegraph owns its lock; try the one documented escape hatch.
    if codegraph unlock "$repo" >> "$LOG_FILE" 2>&1; then
        log "unlocked stale lock; retrying"
        if codegraph sync --quiet "$repo" >> "$LOG_FILE" 2>&1; then
            log "sync OK on retry"
            exit 0
        fi
        rc=$?
        log "sync FAILED on retry (rc=$rc)"
    fi
    notify_error "CodeGraph sync failed: ${reponame}" \
        "codegraph sync exited $rc in $repo. Log: tail -20 $LOG_FILE"
    exit "$rc"
fi

# No codegraph binary (shouldn't happen in an indexed repo) — log + skip.
log "codegraph binary not found; nothing to sync"
exit 0
