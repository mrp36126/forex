
# Strategy definition

## Objective

Build a rules-based forex strategy that trades rarely, with layered confirmation and explicit reasons for both entries and blocked trades.

## Default strategy: higher-timeframe trend + lower-timeframe pullback

### Instruments

- Liquid major forex pairs only during initial validation, such as EURUSD, GBPUSD, USDJPY, AUDUSD.
- Avoid exotic pairs until symbol-specific spread, slippage, and session behavior have been measured.

### Timeframes

- Higher-timeframe trend filter: `H1` by default.
- Entry timeframe: `M15` by default.
- Countertrend trading is disabled by default.

### Trend direction

Bullish regime:

- H1 EMA 50 is above H1 EMA 200.
- Price is above EMA 200.
- Recent structure shows higher highs and higher lows.

Bearish regime:

- H1 EMA 50 is below H1 EMA 200.
- Price is below EMA 200.
- Recent structure shows lower highs and lower lows.

If those conditions conflict, the market regime is `neutral` and the EA should return `NO TRADE`.

### Support, resistance, and structure

The first implementation uses recent swing highs/lows over a configurable lookback as practical structure proxies:

- Resistance = highest recent high.
- Support = lowest recent low.
- A pullback is preferred over chasing an extended breakout candle.

This is deliberately simple and testable. More advanced swing logic can be added later only if it improves out-of-sample robustness.

### Long entry logic

All required:

1. Higher timeframe trend is bullish.
2. Entry timeframe price is above EMA 200.
3. EMA 50 is above EMA 200 on the entry timeframe.
4. A recent pullback has occurred toward EMA 50 or a recent support area.
5. RSI is above the oversold threshold but below overbought territory.
6. Spread, session, risk, news, and sentiment filters all approve.

Optional confirmations:

- MACD histogram above zero.
- Tick volume not materially below recent average.

### Short entry logic

Mirror image of the long setup:

1. Higher timeframe trend is bearish.
2. Entry timeframe price is below EMA 200.
3. EMA 50 is below EMA 200.
4. A recent pullback has occurred toward EMA 50 or resistance.
5. RSI is below the overbought threshold but above oversold territory.
6. All operational filters approve.

### News filter

- Block new entries before and after high-impact events involving either currency in the pair.
- Default blackout window: 45 minutes before and 45 minutes after.
- The EA should use MT5 Economic Calendar data where available.
- All calendar times must be interpreted in broker trade-server time.

### Sentiment filter

- External sentiment is optional and subordinate to price-based logic.
- Allowed states: `bullish`, `bearish`, `neutral`, `high_uncertainty`.
- If confidence is below threshold, stale, conflicting, or high uncertainty, block the trade.
- Sentiment may veto a trade; it may not create one by itself.

### Exit logic

- Stop loss: ATR-based.
- Take profit: minimum reward:risk target of `1.5R`, default `2R`.
- Optional break-even after `1R`.
- Optional trailing stop after trade proves itself.
- Opposite signals should normally block new entries, not trigger emotional exits.

## Why this baseline

This strategy is intentionally unglamorous:

- It avoids predictive complexity before there is evidence.
- It is easy to test honestly.
- It creates traceable reasons for every decision.
- It is naturally selective, which is appropriate for small capital and strict risk control.
