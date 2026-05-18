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
- a final `[TESTER METRICS]` line.

If the EA trades constantly, that is a warning sign, not a success.

## What to verify manually

1. Every opened trade has both stop loss and take profit.
2. No second position is opened on the same symbol.
3. The EA stops taking new trades after the configured daily limit.
4. Lot sizes remain small and plausible for the account size.
5. Trade entries occur only on new candles.
6. A failed calendar lookup results in `NO TRADE`, not a blind entry.

## First rejection rules

Reject or revise the baseline if:

- it cannot produce clean tester logs;
- it opens trades without stops;
- it bypasses a daily brake;
- it only appears profitable in one narrow period;
- it requires unrealistic spreads or execution assumptions.
