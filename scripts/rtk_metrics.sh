#!/usr/bin/env bash
# rtk_metrics.sh — Collect rtk usage metrics for dry-run comparison.
#
# Saves daily rtk gain data to docs/rtk-data/YYYY-MM-DD.json.
# Idempotent: overwrites if run multiple times on the same day.
#
# Usage:
#   bash scripts/rtk_metrics.sh          # collect today's data
#   bash scripts/rtk_metrics.sh 2026-08-13  # collect for specific date
#
# Part of feat/rtk-dry-run (C16) — parallel data collection, does NOT
# replace existing analytics pipeline.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$REPO_ROOT/docs/rtk-data"
TODAY="${1:-$(date +%Y-%m-%d)}"
OUTPUT_FILE="$DATA_DIR/$TODAY.json"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Check rtk is available
if ! command -v rtk &>/dev/null; then
  echo "[rtk_metrics] ERROR: rtk not found in PATH" >&2
  exit 1
fi

# Collect rtk gain metrics (JSON format)
echo "[rtk_metrics] Collecting rtk gain data for $TODAY..."
RTK_DATA=$(rtk gain --all --format json 2>/dev/null || echo '{"error": "rtk gain failed"}')

# Write JSON output (idempotent — overwrites)
echo "$RTK_DATA" | python3 -m json.tool > "$OUTPUT_FILE" 2>/dev/null || echo "$RTK_DATA" > "$OUTPUT_FILE"

echo "[rtk_metrics] Saved to $OUTPUT_FILE"

# Print summary to stdout
COMMANDS=$(echo "$RTK_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('summary',{}).get('total_commands',0))" 2>/dev/null || echo "?")
SAVED=$(echo "$RTK_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('summary',{}).get('total_saved',0))" 2>/dev/null || echo "?")
PCT=$(echo "$RTK_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d.get('summary',{}).get('avg_savings_pct',0):.1f}\")" 2>/dev/null || echo "?")

echo "[rtk_metrics] Summary: $COMMANDS commands, $SAVED tokens saved ($PCT%)"
