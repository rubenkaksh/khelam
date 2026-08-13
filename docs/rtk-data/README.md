# RTK Data Collection (Dry-Run)

This directory collects rtk usage metrics for comparison with the existing analytics pipeline.

## What is rtk?

[rtk](https://github.com/rtk-ai/rtk) is a CLI proxy that compresses shell command output for AI agents. It wraps commands like `flutter test`, `git status`, etc., and reduces output by 60-90%.

## Setup

rtk is installed globally via Homebrew (`rtk-ai/tap/rtk`). The OpenCode plugin at `~/.config/opencode/plugins/rtk.ts` transparently rewrites bash commands to use rtk equivalents.

**This is a dry-run**: rtk runs alongside existing tooling (scripts/, agent-tools, pre-commit gate). It does NOT replace anything. The underlying tools still execute — rtk only filters their output.

## Data Collection

Daily metrics are collected by `scripts/rtk_metrics.sh`:

```bash
# Collect today's data
bash scripts/rtk_metrics.sh

# Collect for a specific date
bash scripts/rtk_metrics.sh 2026-08-13
```

Output: `YYYY-MM-DD.json` in this directory. Idempotent (overwrites on same-day re-run).

## JSON Format

```json
{
  "summary": {
    "total_commands": 42,
    "total_input": 12345,
    "total_output": 5678,
    "total_saved": 6667,
    "avg_savings_pct": 54.0,
    "total_time_ms": 123456,
    "avg_time_ms": 2939
  },
  "daily": [...],
  "weekly": [...],
  "monthly": [...]
}
```

## Analysis (C17)

C17 will analyze the collected data to compare:
- Token usage with rtk vs. baseline (without rtk)
- Savings percentage across different command types
- Whether rtk's compression justifies the overhead

## Commands Tracked

rtk tracks all commands that pass through its proxy layer:
- `rtk git ...` — git operations
- `rtk proxy flutter ...` — Flutter commands (analyze, test, build)
- `rtk proxy <any>` — any command tracked via `rtk proxy`
- OpenCode plugin rewrites — transparent via `rtk rewrite`

## Files

- `YYYY-MM-DD.json` — daily metrics (one per day)
- `baseline-comparison.md` — initial with/without comparison
- `README.md` — this file
