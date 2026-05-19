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


def bucket(value: float, cuts: list[float], labels: list[str]) -> str:
    for cut, label in zip(cuts, labels):
        if value < cut:
            return label
    return labels[-1]


def atr_bucket(value: float) -> str:
    return bucket(value, [60, 90, 120, 180], ["<60", "60-89", "90-119", "120-179", "180+"])


def spread_bucket(value: float) -> str:
    return bucket(value, [10, 20, 30, 50], ["<10", "10-19", "20-29", "30-49", "50+"])


def add_profit(group_profit: dict[str, float], group_count: Counter[str], key: str, profit: float) -> None:
    group_profit[key] += profit
    group_count[key] += 1


def print_profit_table(title: str, group_profit: dict[str, float], group_count: Counter[str], sort_numeric: bool = False) -> None:
    if not group_count:
        return
    print(title)
    keys = list(group_count)
    if sort_numeric:
        keys.sort(key=lambda k: int(k) if str(k).isdigit() else 999)
    else:
        keys.sort(key=lambda k: group_profit[k])
    for key in keys:
        count = group_count[key]
        profit = group_profit[key]
        avg = profit / count if count else 0.0
        print(f"  {key or '(blank)'}: trades={count} profit={profit:.2f} avg={avg:.2f}")
    print()


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
    close_profit_by_direction: dict[str, float] = defaultdict(float)
    close_count_by_direction: Counter[str] = Counter()
    close_profit_by_atr_bucket: dict[str, float] = defaultdict(float)
    close_count_by_atr_bucket: Counter[str] = Counter()
    close_profit_by_spread_bucket: dict[str, float] = defaultdict(float)
    close_count_by_spread_bucket: Counter[str] = Counter()
    blocker_tag_counts: Counter[str] = Counter()

    rows = 0
    for path in paths:
        with path.open(newline="", encoding="mbcs", errors="replace") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows += 1
                event = row.get("event", "")
                setup = row.get("setup", "")
                action = row.get("action", "")
                direction = row.get("direction", "")
                hour = row.get("hour", "")
                reason = row.get("reason", "")
                event_counts[event] += 1
                setup_counts[setup] += 1
                action_counts[action] += 1
                hour_counts[hour] += 1

                if event == "BLOCKED":
                    first_reason = reason.split(" ", 1)[0]
                    block_reason_counts[first_reason] += 1
                    if "buy=[" in reason or "sell=[" in reason:
                        for part in reason.replace("[", ",").replace("]", ",").split(","):
                            tag = part.strip()
                            if tag and "=" not in tag and " " not in tag:
                                blocker_tag_counts[tag] += 1

                if event == "TRADE_CLOSE":
                    profit = as_float(row.get("profit", "0"))
                    add_profit(close_profit_by_setup, close_count_by_setup, setup, profit)
                    add_profit(close_profit_by_hour, close_count_by_hour, hour, profit)
                    add_profit(close_profit_by_direction, close_count_by_direction, direction, profit)
                    add_profit(close_profit_by_atr_bucket, close_count_by_atr_bucket, atr_bucket(as_float(row.get("atr_points", "0"))), profit)
                    add_profit(close_profit_by_spread_bucket, close_count_by_spread_bucket, spread_bucket(as_float(row.get("spread_points", "0"))), profit)

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
    print_counter("Blocked condition tags", blocker_tag_counts)

    print_profit_table("Closed-trade P/L by setup", close_profit_by_setup, close_count_by_setup)
    print_profit_table("Closed-trade P/L by direction", close_profit_by_direction, close_count_by_direction)
    print_profit_table("Closed-trade P/L by hour", close_profit_by_hour, close_count_by_hour, sort_numeric=True)
    print_profit_table("Closed-trade P/L by ATR bucket", close_profit_by_atr_bucket, close_count_by_atr_bucket)
    print_profit_table("Closed-trade P/L by spread bucket", close_profit_by_spread_bucket, close_count_by_spread_bucket)

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
