# Live-trading readiness checklist

Do not enable live trading until all boxes below are true.

## Strategy and code

- [ ] EA compiles without warnings that affect behavior.
- [ ] Every trade and blocked trade is logged with a clear reason.
- [ ] All live inputs match the tested configuration.
- [ ] No martingale, grid, or averaging-down logic exists.
- [ ] Approved trading pairs are intentionally limited and documented.

## Risk controls

- [ ] Lot sizing has been manually cross-checked.
- [ ] Daily loss limit stops new entries.
- [ ] Consecutive-loss lockout works.
- [ ] Every position opens with a stop loss.
- [ ] Spread filter works.
- [ ] One-position-per-symbol rule works.

## News and session controls

- [ ] High-impact calendar events block entries during blackout windows.
- [ ] Calendar timezone handling has been validated against broker server time.
- [ ] Restricted hours behave as expected.

## Backtest and demo evidence

- [ ] At least `2-3 years` of realistic backtests completed.
- [ ] Out-of-sample test passed.
- [ ] Demo forward test completed for `4-8 weeks`.
- [ ] Demo results are reasonably consistent with backtest expectations.
- [ ] Execution quality is acceptable.
- [ ] Losses have been reviewed by category, not only by P/L.

## Operational readiness

- [ ] Broker login and API keys are not stored in frontend code.
- [ ] Dashboard is monitoring-only.
- [ ] You can explain when the system should refuse to trade.
- [ ] You are prepared to stop the system if behavior deviates from design.
