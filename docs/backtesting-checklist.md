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
- Performance by trading hour and by market regime.
- Correlated exposure impact when multiple pairs are tested together.
- Normal-spread periods vs widened-spread periods around opens, closes, and major events.
- Rule-adherent losing trades vs rule-breaking winning trades.

## Reject the strategy if

- Drawdown is too high for the account size.
- Most profit comes from one lucky month or one unusual regime.
- Out-of-sample results collapse.
- The backtest depends on unrealistic spreads or zero slippage.
- Tiny parameter changes destroy the result.
- Optimization creates a "perfect" curve that cannot be explained economically.
- Results only work on one pair while the stated rationale claims a broader edge.
- Profit comes from quietly accumulating correlated exposure rather than distinct opportunities.
- Performance depends on unrealistic assumption that spreads remain stable during illiquid or news-heavy windows.
- A beautiful backtest cannot be explained by a simple, durable market tendency.

## Validation sequence

1. Single-symbol sanity test.
2. Multi-symbol test.
3. Walk-forward or rolling out-of-sample test.
4. Demo forward test for `4-8 weeks`.
5. Compare expected vs realized slippage, spread, fills, and blocked trades.

## Process quality checks

- A losing trade is acceptable if it followed the rules.
- A winning trade is a defect if it violated the rules.
- Review blocked trades as seriously as executed trades; a selective system proves itself partly through what it refuses.
- If a result only exists after repeated parameter hunting, treat it as suspect until proven otherwise.

## Book-informed review questions

- Did the trade align with the pair's dominant driver at the time?
- Did performance depend on a period of unusually favorable macro conditions?
- Were rollover, spreads, and event risk realistically represented?
- Did the strategy stay specialized and understandable, or become a parameter maze?
- Did the apparent edge survive after excluding thin-liquidity and abnormal-spread conditions?

