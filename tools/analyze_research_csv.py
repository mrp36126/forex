#!/usr/bin/env python3
"""Summarize ForexRiskBot research CSV files.

Usage:
    python tools/analyze_research_csv.py path/to/ForexRiskBot_research_*.csv

The script intentionally uses only the Python standard library so it can run
on a fresh Windows machine without installing dependencies.
"""

from __future__ import annotations

import csv
import glob
import sys
from collections import Counter, defaultdict
from pathlib import Path


def as_float(value: str) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def main(argv: list[str]) -> int:
    patterns = argv[1:] or ["ForexRiskBot_research_*.csv"]
    paths: list[Path] = []
    for pattern in patterns:
        matches = glob.glob(pattern)
        if matches:
            paths.extend(Path(match) for match in matches)
        else:
            p = Path(pattern)
            if p.exists():
                paths.append(p)

    if not paths:
        print("No research CSV files found.")
        return 1

    event_counts: Counter[str] = Counter()
    setup_counts: Counter[str] = Counter()
    action_counts: Counter[str] = Counter()
    hour_counts: Counter[str] = Counter()
    block_reason_counts: Counter[str] = Counter()
    close_profit_by_setup: dict[str, float] = defaultdict(float)
    close_count_by_setup: Counter[str] = Counter()
    close_profit_by_hour: dict[str, float] = defaultdict(float)
    close_count_by_hour: Counter[str] = Counter()

    rows = 0
    for path in paths:
        with path.open(newline="", encoding="mbcs", errors="replace") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows += 1
                event = row.get("event", "")
                setup = row.get("setup", "")
                action = row.get("action", "")
                hour = row.get("hour", "")
                reason = row.get("reason", "")
                event_counts[event] += 1
                setup_counts[setup] += 1
                action_counts[action] += 1
                hour_counts[hour] += 1

                if event == "BLOCKED":
                    first_reason = reason.split(" ", 1)[0]
                    block_reason_counts[first_reason] += 1

                if event == "TRADE_CLOSE":
                    profit = as_float(row.get("profit", "0"))
                    close_profit_by_setup[setup] += profit
                    close_count_by_setup[setup] += 1
                    close_profit_by_hour[hour] += profit
                    close_count_by_hour[hour] += 1

    print(f"Files: {len(paths)}")
    print(f"Rows: {rows}")
    print()

    def print_counter(title: str, counter: Counter[str], limit: int = 12) -> None:
        print(title)
        for key, count in counter.most_common(limit):
            print(f"  {key or '(blank)'}: {count}")
        print()

    print_counter("Events", event_counts)
    print_counter("Setups", setup_counts)
    print_counter("Actions", action_counts)
    print_counter("Rows by hour", hour_counts, 24)
    print_counter("Blocked reason prefixes", block_reason_counts)

    if close_count_by_setup:
        print("Closed-trade P/L by setup")
        for setup, count in close_count_by_setup.most_common():
            profit = close_profit_by_setup[setup]
            avg = profit / count if count else 0.0
            print(f"  {setup or '(blank)'}: trades={count} profit={profit:.2f} avg={avg:.2f}")
        print()

    if close_count_by_hour:
        print("Closed-trade P/L by hour")
        for hour in sorted(close_count_by_hour, key=lambda h: int(h) if h.isdigit() else 99):
            count = close_count_by_hour[hour]
            profit = close_profit_by_hour[hour]
            avg = profit / count if count else 0.0
            print(f"  {hour}: trades={count} profit={profit:.2f} avg={avg:.2f}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
