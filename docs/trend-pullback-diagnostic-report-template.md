# Trend-pullback diagnostic report template

## Run identity

| Field | Value |
| --- | --- |
| Date run |  |
| Broker / server |  |
| Symbol |  |
| Period | M15 |
| Model | Every tick based on real ticks |
| Date range |  |
| Deposit | 1000 USD |
| News filter | Disabled for technical-engine research unless stated otherwise |
| EA revision / commit |  |

## Inputs changed from baseline

List only intentional differences from the checked-in `.ini` file.

| Input | Baseline | Test value | Reason |
| --- | ---: | ---: | --- |
|  |  |  |  |

## Tester metrics

Copy from `[TESTER METRICS]` and the Strategy Tester report.

| Metric | Value |
| --- | ---: |
| Net profit |  |
| Max equity drawdown % |  |
| Trades |  |
| Profit factor |  |
| Win rate |  |
| Average win |  |
| Average loss |  |
| Expected payoff |  |
| Max consecutive losses |  |

## Tester summary

Copy the final summary lines.

```text
[TESTER SUMMARY]
[TESTER BLOCKS]
```

## Block distribution notes

| Category | Count | Interpretation |
| --- | ---: | --- |
| outside_hours |  |  |
| spread |  |  |
| existing_position |  |  |
| risk |  |  |
| news |  |  |
| signal_range |  |  |
| signal_setup |  |  |
| sentiment |  |  |
| volatility |  |  |
| stops |  |  |
| lot_size |  |  |

## Signal-quality review

Sample at least 20 blocked `playbook=trend_pullback` journal rows across different months.

| Question | Notes |
| --- | --- |
| Are most blocks caused by sensible no-trade conditions? |  |
| Are valid-looking trends being blocked mostly by one rule? |  |
| Are trades firing into nearby obstacles? |  |
| Are entries clustered in one month/session? |  |
| Do losing trades still follow the stated rules? |  |

## Decision

Choose one:

- **Reject**: results fail robustness, diagnostics show poor setup quality, or losses depend on an obvious rule defect.
- **Revise carefully**: the concept is plausible, but one diagnostic category points to a specific rule needing a small change.
- **Retest unchanged**: logs are clean and this run should be repeated on another symbol/window before changing anything.

Decision:

Reason:

Next run:
