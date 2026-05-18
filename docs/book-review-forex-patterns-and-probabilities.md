# Applied review: Forex Patterns and Probabilities

Source: *Forex Patterns and Probabilities: Trading Strategies for Trending and Range-Bound Markets* by Ed Ponsi.

## Lessons adopted

### A regime determines the playbook

The book draws a sharp line between trending and non-trending conditions. For ForexRiskBot:

- classify the environment first;
- permit only the setup family suited to that environment;
- do not apply trend-continuation entries inside range conditions merely because one candle looks attractive.

### Moving-average organization helps describe trend quality

The book uses "proper order" of moving averages to distinguish organized trends from tangled, range-like conditions. ForexRiskBot already uses EMA alignment and slope; the practical lesson is:

- moving averages should confirm direction and organization, not act as a magic signal by themselves;
- flat or entangled averages are evidence against a clean trend regime;
- trend quality matters more than one crossover event.

### Support and resistance are zones

The book repeatedly frames support and resistance as areas rather than exact prices. Applied here:

- obstacle filters should not assume surgical precision;
- entry logic should allow for buffers;
- stops should not be placed with false exactness on obvious levels.

### Breakouts need filters

The intraday breakout sections emphasize trend filters and time-of-day filters. For the project:

- breakout logic should remain stricter than simple level penetration;
- session context matters;
- a breakout during poor liquidity deserves more skepticism than the same pattern during active hours.

### Volatility is part of the setup

The book uses ATR and volatility concepts in both trend and breakout contexts. That supports the current EA design:

- ATR belongs in stop sizing;
- very low-volatility conditions can invalidate trend-continuation expectations;
- volatility should be measured and logged, not guessed.

### Trading costs punish tiny targets

The book's "playing field" discussion makes a useful point: the spread has a larger proportional effect on small profit targets. For ForexRiskBot:

- avoid scalping-style targets that leave no room after costs;
- preserve minimum reward:risk standards;
- evaluate results net of spread, commission, slippage, and swap.

### A good trade is not the same as a winning trade

This is one of the most important lessons for a production system:

- evaluate trades by rule adherence, not only by outcome;
- losing trades can be valid;
- winning trades taken outside the rules are still defects.

### Beware impressive backtests

The book explicitly warns against overoptimized hypothetical results. That reinforces our validation stance:

- backtests are research evidence, not proof;
- nearby parameters, out-of-sample periods, and forward demo results matter;
- a smooth historical curve is suspicious if the economic logic is weak.

## Lessons deliberately not adopted

The book contains several named discretionary strategies, including:

- Fibonacci-based entry variations;
- round-number plays;
- squeeze plays;
- false-breakout fades;
- carry / interest-rate ideas;
- partial-exit and reload tactics.

These are useful research candidates, but they are not imported into the baseline EA yet because:

- mixing many playbooks would blur attribution;
- several require their own distinct validation;
- adding them before robustness testing would increase overfitting risk.

## Concrete project consequences

- preserve the trend-versus-range split as a first-class design rule;
- consider moving-average organization as a future measurable trend-quality feature;
- keep breakout logic filtered by regime and session;
- treat support/resistance as buffered zones;
- continue using ATR as a volatility-aware risk input;
- judge the bot by process quality as well as P/L;
- keep resisting attractive but overfit backtest stories.
