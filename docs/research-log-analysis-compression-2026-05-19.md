# Research-log analysis: compression breakout - 2026-05-19

## Context

After adding structured CSV research logging, the compression-breakout candidate was rerun with the verified compiled `.ex5`.

This corrected an earlier stale-compile issue. The refreshed candidate was less bad than the earlier rejection, but it still failed robustness across years and pairs.

## Corrected robustness results

| Test | Profit | DD | Trades | PF |
| --- | ---: | ---: | ---: | ---: |
| EURUSD 2022 | -38.59 | 6.82% | 46 | 0.72 |
| EURUSD 2023 | -40.06 | 7.01% | 24 | 0.51 |
| EURUSD 2024 | 3.19 | 3.74% | 23 | 1.05 |
| EURUSD 2025-2026 | 34.26 | 2.75% | 41 | 1.30 |
| GBPUSD 2025-2026 | -40.27 | 5.22% | 42 | 0.69 |
| USDJPY 2025-2026 | -81.70 | 12.97% | 64 | 0.62 |
| AUDUSD 2025-2026 | -125.25 | 14.49% | 50 | 0.33 |

## Combined CSV findings

Across the seven corrected runs:

- closed trades: `290`;
- total closed-trade P/L: `-288.42`;
- BUY trades: `157`, P/L `-241.09`;
- SELL trades: `133`, P/L `-47.33`.

The largest visible weakness is on the buy side.

## Failure concentrations

### Direction

| Direction | Trades | Profit | Avg / trade |
| --- | ---: | ---: | ---: |
| BUY | 157 | -241.09 | -1.54 |
| SELL | 133 | -47.33 | -0.36 |

BUY breakouts are the dominant source of loss.

### Hour

Worst combined hours:

| Hour | Trades | Profit | Avg / trade |
| --- | ---: | ---: | ---: |
| 16 | 32 | -86.13 | -2.69 |
| 10 | 40 | -80.59 | -2.01 |
| 20 | 10 | -33.66 | -3.37 |
| 14 | 12 | -26.05 | -2.17 |

Better combined hours:

| Hour | Trades | Profit | Avg / trade |
| --- | ---: | ---: | ---: |
| 18 | 21 | 23.19 | 1.10 |
| 15 | 19 | 14.83 | 0.78 |
| 12 | 15 | 1.88 | 0.13 |

The signal is not session-neutral. Some hours appear structurally hostile.

### ATR bucket

| ATR bucket | Trades | Profit | Avg / trade |
| --- | ---: | ---: | ---: |
| <60 | 81 | -111.42 | -1.38 |
| 60-89 | 82 | -100.27 | -1.22 |
| 90-119 | 62 | -20.57 | -0.33 |
| 120-179 | 56 | -49.84 | -0.89 |
| 180+ | 9 | -6.32 | -0.70 |

Low-volatility breakouts are especially weak.

### Spread bucket

| Spread bucket | Trades | Profit | Avg / trade |
| --- | ---: | ---: | ---: |
| 10-19 | 143 | -41.99 | -0.29 |
| 20-29 | 146 | -238.21 | -1.63 |
| 50+ | 1 | -8.22 | -8.22 |

The candidate is highly sensitive to transaction cost. Wider-spread trades are a major loss source.

## Per-symbol notes

### EURUSD

- total: `-41.20` over `134` trades;
- BUY: `-74.10`;
- SELL: `+32.90`;
- worst hours: `10`, `16`, `11`;
- better hours: `9`, `15`, `12`;
- ATR `90+` was materially better than ATR below `90`.

EURUSD has the most salvageable profile, but only after excluding large chunks of behavior.

### GBPUSD

- total: `-40.27` over `42` trades;
- both BUY and SELL lost;
- spread `20-29` carried nearly all the loss.

GBPUSD does not currently justify inclusion.

### USDJPY

- total: `-81.70` over `64` trades;
- BUY lost more than SELL;
- spread bucket `20-29` was heavily negative.

USDJPY does not currently justify inclusion.

### AUDUSD

- total: `-125.25` over `50` trades;
- both BUY and SELL lost badly;
- all trades occurred in the `20-29` spread bucket.

AUDUSD should be excluded from this candidate.

## Interpretation

The compression-breakout candidate is not universally broken, but it is too broad.

Its weaknesses are clear:

1. BUY breakouts are materially worse than SELL breakouts.
2. Low-ATR breakouts are poor.
3. Wider-spread conditions destroy expectancy.
4. Certain hours are repeatedly hostile.
5. The candidate is not portable across tested majors.

## Recommendation

Do not promote this candidate.

If researched further, it should be narrowed into an **EURUSD-only experimental profile** with:

- SELL-only mode;
- `MinATRPoints` raised to at least `90`;
- `MaxSpreadPoints` tightened below `20`;
- known hostile hours excluded, especially `10`, `16`, and `20`;
- no claim of generality across pairs.

This would be a research experiment, not a production strategy.

The safer architectural next step is to add configuration support for explicit allowed/excluded trade hours before running that narrowed experiment.
