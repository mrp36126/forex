# Applied review: Day Trading and Swing Trading the Currency Market

Source: *Day Trading and Swing Trading the Currency Market, 2nd Edition* by Kathy Lien.

## Lessons adopted

### Profile the market before selecting a strategy

The book repeatedly distinguishes between range, trend, and breakout conditions. That reinforces a core architectural rule for ForexRiskBot:

- do not apply one entry template to every market state;
- classify the regime first;
- only then allow the strategy family that belongs to that regime.

### Use multiple time frames

The book emphasizes trading with the bigger picture rather than reacting only to the entry chart. ForexRiskBot already uses a higher-timeframe trend filter, and this review strengthens that principle:

- higher timeframe defines direction and context;
- lower timeframe defines execution;
- contradictory lower-timeframe noise should not overrule the broader regime.

### Timing matters by pair

The book highlights that each pair has active and inactive periods. For the project, that means:

- the trading window should eventually be symbol-specific, not one global hour range forever;
- backtests must report performance by hour;
- weak hours should be treated as hypotheses to validate, not automatically traded.

### Correlations are portfolio risk

The book's correlation discussion is directly relevant to multi-pair automation:

- EURUSD, GBPUSD, AUDUSD, and USDCHF exposures may not be independent;
- several trades can become one hidden USD bet;
- portfolio risk controls should consider correlation, not just per-symbol stops.

### Keep a currency-pair checklist

The book's checklist idea maps neatly onto a systematic workflow:

- approved pair;
- regime;
- higher-timeframe trend;
- support / resistance context;
- volatility;
- active session;
- macro / event risk;
- blocked-trade reason.

The EA should log this mechanically; the dashboard should eventually display it.

### Pair profiles matter

Each pair has different drivers, liquidity, and timing. A single configuration should not be assumed portable across all symbols without testing.

## Lessons not copied directly

The book includes named discretionary tactics such as:

- fading double zeros;
- waiting for the "real deal" around session opens;
- news-trading playbooks;
- several specialized short-term setups.

Those are useful research ideas, but they are not imported directly into the production EA because:

- many are discretionary;
- several depend on microstructure or event interpretation that is hard to automate safely;
- blindly adding them would raise overfitting risk.

They belong in the research backlog, not the live baseline.

## Concrete project consequences

- retain regime-first signal design;
- add symbol-specific session support;
- add future correlation-aware portfolio risk checks;
- expand logging toward a pair-checklist model;
- validate strategies by symbol, hour, and regime before broad deployment.
