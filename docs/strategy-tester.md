# Strategy Tester workflow

## First safety run

Use this before any optimization:

| Setting | Value |
| --- | --- |
| Symbol | EURUSD |
| Period | M15 |
| Model | Every tick based on real ticks if available |
| Date range | At least 2 years |
| Deposit | Match your intended account size where possible |
| Leverage | Match your broker account |
| Optimization | Disabled |
| Visual mode | Optional for first debugging pass |

## What to inspect in the Journal

You should see:

- initialization messages;
- many `NO TRADE` decisions;
- explicit block reasons such as:
  - outside trading hours,
  - spread too high,
  - high-impact news blackout,
  - confirmation missing,
  - lot size below broker minimum;
- a final `[TESTER SUMMARY]` line;
- a final `[TESTER BLOCKS]` line with block counts by category;
- a final `[TESTER METRICS]` line.

If the EA trades constantly, that is a warning sign, not a success.

## What to inspect in signal diagnostics

The signal engine now writes structured playbook reasons. For blocked trend-pullback signals, look for entries like:

```text
playbook=trend_pullback blocked buy=[regime, pullback, structure] sell=[confirmation, obstacle_room]
```

Use these diagnostics to understand *why* the strategy is selective:

- `regime=range` means the structure range was too compressed for trend continuation.
- `regime` inside a buy/sell blocker means the higher-timeframe trend was not organized enough.
- `entry_ema_alignment` means the entry timeframe EMAs did not agree with that side.
- `pullback` means price did not return to the configured value area.
- `rsi`, `macd`, and `confirmation` identify missing momentum/confirmation filters.
- `structure` means recent highs/lows did not support continuation.
- `obstacle_room` means price was too close to nearby support/resistance.

The `[TESTER BLOCKS]` line gives the high-level distribution:

```text
[TESTER BLOCKS] outside_hours=... spread=... existing_position=... risk=... news=... signal_range=... signal_setup=... sentiment=... volatility=... stops=... lot_size=...
```

A useful next research run should have understandable rejection pressure. For example, many `signal_setup` blocks can be healthy for a selective trend strategy, while many `spread`, `stops`, or `lot_size` blocks point to broker/execution or account-sizing constraints rather than signal quality.

## What to verify manually

1. Every opened trade has both stop loss and take profit.
2. No second position is opened on the same symbol.
3. The EA stops taking new trades after the configured daily limit.
4. Lot sizes remain small and plausible for the account size.
5. Trade entries occur only on new candles.
6. A failed calendar lookup results in `NO TRADE`, not a blind entry.
7. The `[TESTER BLOCKS]` counts roughly reconcile with the Journal reasons.

## First rejection rules

Reject or revise the baseline if:

- it cannot produce clean tester logs;
- it opens trades without stops;
- it bypasses a daily brake;
- it only appears profitable in one narrow period;
- it requires unrealistic spreads or execution assumptions.
