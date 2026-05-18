# Trend-pullback candidate report - 2026-05-18

## Candidate

Conservative trend-continuation-only redesign:

- higher-timeframe organized trend required;
- minimum EMA separation required;
- pullback must be visible on the prior candle;
- current closed candle must confirm resumption;
- breakout entries disabled;
- both long and short pullbacks allowed symmetrically.

## What improved

- Trade frequency dropped sharply.
- Drawdown dropped materially versus the rejected blended model.
- The playbook became simpler and easier to explain.
- Logs now identify the active setup as `trend_pullback`.

## One-year EURUSD and recent cross-pair results

| Test | Profit | DD | Trades | PF |
| --- | ---: | ---: | ---: | ---: |
| EURUSD 2022 | -20.93 | 2.68% | 13 | 0.52 |
| EURUSD 2023 | -35.59 | 4.57% | 15 | 0.32 |
| EURUSD 2024 | 2.85 | 1.73% | 12 | 1.08 |
| EURUSD 2025-2026 | 11.89 | 2.83% | 21 | 1.21 |
| GBPUSD 2025-2026 | 10.74 | 1.74% | 13 | 1.29 |
| USDJPY 2025-2026 | 3.86 | 4.41% | 20 | 1.07 |
| AUDUSD 2025-2026 | -29.06 | 5.48% | 14 | 0.48 |

## Continuous 2022-2026 results

| Pair | Profit | DD | Trades | PF |
| --- | ---: | ---: | ---: | ---: |
| EURUSD | -44.63 | 6.21% | 61 | 0.76 |
| GBPUSD | -11.03 | 5.20% | 43 | 0.92 |
| USDJPY | -24.71 | 8.17% | 62 | 0.87 |
| AUDUSD | -58.17 | 7.49% | 51 | 0.66 |

## Decision

Reject this candidate as a profitable strategy hypothesis.

It is safer and cleaner than the rejected blended model, but it still does not show a durable edge across the full multi-year sample.

## Interpretation

The redesign improved **discipline**, not **expectancy**.

That is still useful:

- the architecture is moving in the right direction;
- the next candidate can reuse the cleaner regime/playbook separation;
- the evidence argues against spending more time tuning trend-pullback thresholds in isolation.

## Recommended next step

Move to the next distinct hypothesis:

**Compression breakout after contraction**, tested as its own standalone playbook rather than mixed back into the rejected model.
