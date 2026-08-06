#!/usr/bin/env python3
"""analytics_charts.py — generate charts from ~/analytics data (v1).

Usage:
    python3 scripts/analytics_charts.py [--chart N] [--week YYYY-MM-DD] [--month YYYY-MM]

Charts (per design spec §3):
    1. cost trend line            (weekly CSVs: total_tokens / cost per week)
    2. waste-category pareto      (monthly CSV: waste_incidents categories)
    3. estimate calibration       (monthly CSV: estimated vs actual tokens, y=x line)
    4. model usage stacked bar    (weekly CSV: input/output tokens per model)
    5. cache-efficiency ratio     (weekly CSV: cache_read / total per session)
    6. drift per pattern bar      (monthly CSV: drift_nudges)
    7. verification waste dual    (monthly CSV: full_test_runs + flutter_analyze_runs)
    8. tooling efficiency line    (monthly CSV: codegraph_lookups per week)

Graceful degradation: if matplotlib is missing, print a hint and exit 1.
All output PNGs go to ~/analytics/charts/.
"""

import argparse
import csv
import glob
import os
import sys

ANALYTICS_DIR = os.environ.get("ANALYTICS_DIR", os.path.expanduser("~/analytics"))
CHARTS_DIR = os.path.join(ANALYTICS_DIR, "charts")
WEEKLY_GLOB = os.path.join(ANALYTICS_DIR, "weekly", "*.csv")
MONTHLY_GLOB = os.path.join(ANALYTICS_DIR, "monthly", "*.csv")


def load_weekly() -> list[dict]:
    rows = []
    for path in sorted(glob.glob(WEEKLY_GLOB)):
        with open(path, newline="") as f:
            for r in csv.DictReader(f):
                rows.append(r)
    return rows


def load_monthly() -> list[dict]:
    rows = []
    for path in sorted(glob.glob(MONTHLY_GLOB)):
        with open(path, newline="") as f:
            for r in csv.DictReader(f):
                rows.append(r)
    return rows


def fnum(v, default=0.0):
    try:
        return float(v)
    except (TypeError, ValueError):
        return default


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--chart", type=int, default=0, help="0 = all charts, else 1-8")
    args = ap.parse_args()

    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print(
            "matplotlib not installed. Install it with: pip3 install matplotlib",
            file=sys.stderr,
        )
        return 1

    os.makedirs(CHARTS_DIR, exist_ok=True)
    weekly = load_weekly()
    monthly = load_monthly()

    def save(fig, name):
        path = os.path.join(CHARTS_DIR, name)
        fig.savefig(path, dpi=110, bbox_inches="tight")
        plt.close(fig)
        print(f"wrote {path}")

    chart = args.chart
    if chart in (0, 1):
        fig, ax = plt.subplots(figsize=(8, 4))
        weeks = sorted({r["date"][:10] for r in weekly})
        tokens = [sum(fnum(r["total_tokens"]) for r in weekly if r["date"][:10] == w) for w in weeks]
        ax.plot(weeks, tokens, marker="o")
        ax.set_title("Total tokens per day (weekly CSV)")
        ax.set_ylabel("tokens")
        ax.tick_params(axis="x", rotation=45)
        save(fig, "1-cost-trend.png")

    if chart in (0, 2):
        fig, ax = plt.subplots(figsize=(8, 4))
        # waste categories come from the review doc; monthly CSV carries the count only.
        labels = ["scope back-and-forth", "redundant verification", "tooling churn",
                  "diagnosis waste", "output waste", "process gaps"]
        counts = [fnum(r["waste_incidents"]) for r in monthly]
        if counts:
            ax.bar(labels[: len(counts)], counts)
        else:
            ax.text(0.5, 0.5, "no waste data yet", ha="center", va="center")
        ax.set_title("Waste categories (from weekly reviews)")
        ax.tick_params(axis="x", rotation=30)
        save(fig, "2-waste-pareto.png")

    if chart in (0, 3):
        fig, ax = plt.subplots(figsize=(6, 6))
        est = [fnum(r["estimated_tokens"]) for r in monthly if r.get("estimated_tokens")]
        act = [fnum(r["actual_tokens"]) for r in monthly if r.get("actual_tokens")]
        if est and act:
            ax.scatter(est, act, s=60)
            m = max(max(est), max(act), 1)
            ax.plot([0, m], [0, m], "r--", label="y=x (perfect)")
            ax.set_xlabel("estimated tokens")
            ax.set_ylabel("actual tokens")
            ax.legend()
        else:
            ax.text(0.5, 0.5, "no calibration data yet", ha="center", va="center")
        ax.set_title("Estimate calibration")
        save(fig, "3-estimate-calibration.png")

    if chart in (0, 4):
        fig, ax = plt.subplots(figsize=(8, 4))
        models = {}
        for r in weekly:
            m = r["model_name"] or "unknown"
            models.setdefault(m, {"in": 0, "out": 0})
            models[m]["in"] += fnum(r["input_tokens"])
            models[m]["out"] += fnum(r["output_tokens"])
        if models:
            names = sorted(models)
            ins = [models[m]["in"] for m in names]
            outs = [models[m]["out"] for m in names]
            ax.bar(names, ins, label="input")
            ax.bar(names, outs, bottom=ins, label="output")
            ax.set_yscale("log")
            ax.legend()
            ax.tick_params(axis="x", rotation=30)
        else:
            ax.text(0.5, 0.5, "no model data yet", ha="center", va="center")
        ax.set_title("Model usage (input/output tokens)")
        save(fig, "4-model-usage.png")

    if chart in (0, 5):
        fig, ax = plt.subplots(figsize=(8, 4))
        ratios = [fnum(r["cache_read_tokens"]) / max(fnum(r["total_tokens"]), 1)
                  for r in weekly]
        days = [r["date"][:10] for r in weekly]
        if ratios:
            ax.bar(range(len(ratios)), ratios)
            ax.set_xticks(range(len(days)))
            ax.set_xticklabels(days, rotation=45, ha="right")
            ax.set_ylabel("cache_read / total")
        else:
            ax.text(0.5, 0.5, "no cache data yet", ha="center", va="center")
        ax.set_title("Cache efficiency per session")
        save(fig, "5-cache-efficiency.png")

    if chart in (0, 6):
        fig, ax = plt.subplots(figsize=(8, 4))
        counts = [fnum(r["drift_nudges"]) for r in monthly]
        weeks = [r["week_ending"] for r in monthly]
        if counts:
            ax.bar(weeks, counts)
            ax.tick_params(axis="x", rotation=45)
        else:
            ax.text(0.5, 0.5, "no drift data yet", ha="center", va="center")
        ax.set_title("Sidetrack drift nudges per week")
        save(fig, "6-drift-patterns.png")

    if chart in (0, 7):
        fig, ax = plt.subplots(figsize=(8, 4))
        tests = [fnum(r["full_test_runs"]) for r in monthly]
        analyzes = [fnum(r["flutter_analyze_runs"]) for r in monthly]
        weeks = [r["week_ending"] for r in monthly]
        if weeks:
            ax.plot(weeks, tests, marker="o", label="full test runs")
            ax.plot(weeks, analyzes, marker="s", label="flutter analyze runs")
            ax.legend()
            ax.tick_params(axis="x", rotation=45)
        else:
            ax.text(0.5, 0.5, "no verification data yet", ha="center", va="center")
        ax.set_title("Verification activity per week")
        save(fig, "7-verification-waste.png")

    if chart in (0, 8):
        fig, ax = plt.subplots(figsize=(8, 4))
        lookups = [fnum(r["codegraph_lookups"]) for r in monthly]
        weeks = [r["week_ending"] for r in monthly]
        if weeks:
            ax.plot(weeks, lookups, marker="o")
            ax.tick_params(axis="x", rotation=45)
            ax.set_ylabel("codegraph/graphify lookups")
        else:
            ax.text(0.5, 0.5, "no tooling data yet", ha="center", va="center")
        ax.set_title("Tooling efficiency (lookups per week)")
        save(fig, "8-tooling-efficiency.png")

    return 0


if __name__ == "__main__":
    sys.exit(main())
