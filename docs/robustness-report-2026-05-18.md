# Robustness report - 2026-05-18

## Purpose

Test whether the current promising EURUSD result survives:

1. unseen historical windows;
2. other liquid major pairs;
3. comparison against the prior less-specialized revision.

All runs used XM Global MT5, M15, every-tick modeling, USD 1,000 deposit, and unchanged core risk settings. News filtering remained disabled so this batch tested the technical engine itself.

## Configuration under test

### Current asymmetric revision

- long pullbacks disabled;
- long breakouts disabled;
- short pullbacks enabled;
- short breakouts enabled.

### Comparison revision

- long pullbacks disabled;
- long breakouts enabled;
- short pullbacks enabled;
- short breakouts enabled.

## Temporal robustness: EURUSD

| Window | Current profit | Current DD | Current trades | Current PF | Comparison profit | Comparison DD | Comparison trades | Comparison PF |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2022 | -54.66 | 8.73% | 124 | 0.85 | -92.60 | 13.93% | 206 | 0.84 |
| 2023 | -69.53 | 8.50% | 87 | 0.74 | -46.39 | 8.41% | 160 | 0.90 |
| 2024 | -63.07 | 7.54% | 74 | 0.73 | -133.30 | 14.47% | 108 | 0.61 |
| 2025-2026 | 39.53 | 4.86% | 90 | 1.16 | -34.90 | 8.28% | 212 | 0.94 |

## Cross-pair robustness: current asymmetric revision

| Pair | Window | Profit | DD | Trades | PF |
| --- | --- | ---: | ---: | ---: | ---: |
| EURUSD | 2025-2026 | 39.53 | 4.86% | 90 | 1.16 |
| GBPUSD | 2025-2026 | -76.92 | 12.00% | 123 | 0.78 |
| USDJPY | 2025-2026 | -172.47 | 17.95% | 143 | 0.59 |
| AUDUSD | 2025-2026 | -56.45 | 6.89% | 45 | 0.60 |

## Findings

1. The current asymmetric revision fails temporal robustness on EURUSD.
2. The current asymmetric revision fails cross-pair robustness on the other tested majors.
3. The prior less-specialized revision also fails temporal robustness.
4. The positive 2025-2026 EURUSD result is therefore not sufficient evidence of a durable edge.
5. The bot's safety controls behaved correctly during the tests: no uncontrolled trade explosion, explicit no-trade logging, and small risk remained intact.

## Decision

Do **not** promote either tested revision toward demo validation as a strategy candidate.

Keep the project architecture and safety framework, but treat the current signal model as **rejected for robustness** until redesigned and retested.

## Recommended next research direction

Move from incremental filter tuning to a cleaner strategy-research reset:

1. preserve the risk engine, logging, news architecture, and tester harness;
2. separate regime classification from entries more explicitly;
3. research distinct playbooks for:
   - trend continuation;
   - breakout continuation;
   - range conditions as either a no-trade regime or a separately tested strategy;
4. test candidate ideas on multiple years and pairs from the start;
5. only optimize after a concept shows broad evidence with coarse parameters.
