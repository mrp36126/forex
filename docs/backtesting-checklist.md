# Backtesting and validation checklist

## Dataset

- Use at least `2-3 years` of history.
- Include multiple symbols and multiple market regimes.
- Use realistic spread, commission, swap, and slippage assumptions.
- Keep an out-of-sample segment that is not touched during tuning.

## Regimes to test

- Trending periods.
- Ranging periods.
- High-volatility news periods.
- Low-liquidity periods.
- Different sessions and seasonal conditions.

## Required metrics

- Total return.
- Maximum drawdown.
- Profit factor.
- Win rate.
- Average win.
- Average loss.
- Expectancy.
- Consecutive losses.
- Monthly performance.
- Sharpe-like risk metric if the sample supports it.

## Required comparisons

- In-sample vs out-of-sample.
- Backtest vs forward demo.
- Gross vs after-cost performance.
- Default parameters vs nearby parameter values.
- Per-pair performance, rather than only pooled portfolio results.
- Performance by macro regime and major event windows.

## Reject the strategy if

- Drawdown is too high for the account size.
- Most profit comes from one lucky month or one unusual regime.
- Out-of-sample results collapse.
- The backtest depends on unrealistic spreads or zero slippage.
- Tiny parameter changes destroy the result.
- Optimization creates a "perfect" curve that cannot be explained economically.
- Results only work on one pair while the stated rationale claims a broader edge.
- Profit comes from quietly accumulating correlated exposure rather than distinct opportunities.

## Validation sequence

1. Single-symbol sanity test.
2. Multi-symbol test.
3. Walk-forward or rolling out-of-sample test.
4. Demo forward test for `4-8 weeks`.
5. Compare expected vs realized slippage, spread, fills, and blocked trades.

## Book-informed review questions

- Did the trade align with the pair's dominant driver at the time?
- Did performance depend on a period of unusually favorable macro conditions?
- Were rollover, spreads, and event risk realistically represented?
- Did the strategy stay specialized and understandable, or become a parameter maze?
