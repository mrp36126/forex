# Compression-breakout candidate report - 2026-05-19

## Candidate

Standalone compression-breakout playbook:

- pullback entries disabled;
- breakout entries enabled in the test profiles;
- prior compression required;
- current candle must break beyond the compression range by a buffer;
- breakout candle body must exceed a minimum size;
- higher-timeframe trend filter enabled;
- ordinary risk, spread, session, daily-loss, and one-position controls remained active.

## Robustness results

| Test | Profit | DD | Trades | PF |
| --- | ---: | ---: | ---: | ---: |
| EURUSD 2022 | -117.99 | 15.43% | 202 | 0.79 |
| EURUSD 2023 | -48.42 | 9.21% | 157 | 0.89 |
| EURUSD 2024 | -117.06 | 13.35% | 104 | 0.64 |
| EURUSD 2025-2026 | -85.45 | 11.90% | 203 | 0.85 |
| GBPUSD 2025-2026 | -176.46 | 20.35% | 252 | 0.74 |
| USDJPY 2025-2026 | -283.29 | 29.59% | 287 | 0.64 |
| AUDUSD 2025-2026 | -125.20 | 12.96% | 109 | 0.62 |

## Decision

Reject this candidate.

The concept traded far more often than the trend-pullback candidate and produced materially worse drawdowns. It failed every tested EURUSD yearly window and every recent cross-pair check.

## Interpretation

The implemented compression definition is not selective enough. It appears to behave too much like generic breakout chasing, which is exactly what the redesign was supposed to avoid.

This does **not** prove that every compression-breakout idea is invalid, but it does reject this implementation as a candidate.

## Safety note

Because both researched strategy candidates have failed robustness, the EA defaults should remain fail-closed for live use. Research `.ini` profiles may enable specific playbooks for testing, but the default EA should not accidentally trade when attached manually.

## Recommended next step

Pause strategy additions and improve the research harness before testing another idea:

1. add explicit per-playbook tester summaries;
2. export trade-level CSV or structured logs;
3. analyze losers by hour, ATR bucket, direction, and setup state;
4. only then decide whether to refine compression or research a different signal family.
