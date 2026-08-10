#!/usr/bin/env python3
# /// script
# dependencies = ["matplotlib"]
# ///
"""Weekly review token-trend chart.

Usage: uv run --script review_chart.py <weekly.csv> <out.png>

Reads the ccusage weekly CSV (15 cols; row[0]=date, row[4]=input,
row[5]=output, row[6]=cache_read, row[7]=cache_write, row[8]=reasoning)
and renders a stacked per-day token bar chart (M tokens).

Exit 0 on success; 1 on unusable input — the caller degrades to a
no-chart post with a WARNING log line (never blocks the Discord send).
Runs via uv's inline-script metadata so matplotlib lives in uv's cache,
not the system Python.
"""
import csv
import sys

import matplotlib

matplotlib.use("Agg")  # headless — no display needed under launchd
import matplotlib.pyplot as plt


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: review_chart.py <weekly.csv> <out.png>", file=sys.stderr)
        return 1
    csv_path, out_path = sys.argv[1], sys.argv[2]

    days: dict[str, list[float]] = {}
    total = 0.0
    try:
        with open(csv_path, newline="") as fh:
            for row in csv.reader(fh):
                if not row or row[0].startswith("date"):
                    continue
                if len(row) < 9 or not row[0]:
                    continue
                try:
                    comps = [
                        float(row[4] or 0), float(row[5] or 0),
                        float(row[6] or 0), float(row[7] or 0), float(row[8] or 0),
                    ]
                except ValueError:
                    continue
                days.setdefault(row[0], [0.0] * 5)
                for i in range(5):
                    days[row[0]][i] += comps[i]
                total += sum(comps)
    except OSError as exc:
        print(f"review_chart: cannot read {csv_path}: {exc}", file=sys.stderr)
        return 1

    if not days:
        print(f"review_chart: no data rows in {csv_path}", file=sys.stderr)
        return 1

    labels = sorted(days)
    comps = [days[d] for d in labels]
    stacked = [sum(c) for c in comps]
    # series[idx][d] = component idx's value on day d (component-major).
    series = list(zip(*comps))

    fig, ax = plt.subplots(figsize=(11, 4.2), dpi=150)
    bottom = [0.0] * len(labels)
    for idx, (label, color) in enumerate((
        ("input", "#4c8bf5"),
        ("output", "#f5a04c"),
        ("cache read", "#8e8e93"),
        ("reasoning", "#b45cf5"),
    )):
        data = [series[idx][d] / 1e6 for d in range(len(labels))]
        if any(data):
            ax.bar(labels, data, bottom=bottom, label=label, color=color, width=0.62)
            bottom = [b + v for b, v in zip(bottom, data)]

    peak = max(bottom) if bottom else 1.0
    for i, lbl in enumerate(labels):
        day_total = stacked[i] / 1e6
        ax.text(i, bottom[i] + peak * 0.02, f"{day_total:.1f}M",
                ha="center", va="bottom", fontsize=9)

    week_label = csv_path.rsplit("/", 1)[-1].replace(".csv", "")
    ax.set_title(f"Weekly token trend — {week_label}", fontsize=12, loc="left")
    ax.set_ylabel("tokens (M)")
    ax.set_ylim(0, peak * 1.16 if peak > 0 else 1)
    ax.spines[["top", "right"]].set_visible(False)
    ax.grid(axis="y", alpha=0.3)
    ax.tick_params(axis="x", rotation=30)
    ax.legend(ncol=4, frameon=False, loc="upper left")
    ax.annotate(f"Total {total / 1e6:.1f}M tokens", (0, 0), (0, -38),
                xycoords="axes fraction", textcoords="offset points", fontsize=10)
    fig.tight_layout()
    fig.savefig(out_path)
    plt.close(fig)
    return 0


if __name__ == "__main__":
    sys.exit(main())
