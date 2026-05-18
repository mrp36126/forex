# Book-informed design notes

Source: *Currency Trading For Dummies, 4th Edition* by Paul Mladjenovic, Kathleen Brooks, and Brian Dolan.

## How this book changes the project

The book reinforces that a forex system should not be built as "indicator enters, indicator exits." It should be built as a trading process:

1. know what moves currencies;
2. trade from a written plan;
3. focus on a manageable set of pairs;
4. understand execution details such as rollover and order handling;
5. practice before risking real capital;
6. keep leverage low and risk rules explicit;
7. review losing trades instead of rationalizing them.

## Principles adopted into ForexRiskBot

### 1. Currency pairs are not interchangeable

The system should begin with a small, deliberate universe of liquid majors rather than treating every forex pair as equal. Pair selection must consider:

- spread and liquidity;
- session behavior;
- sensitivity to scheduled data;
- correlation with other open exposures;
- whether the trader can explain the economic story behind the pair.

### 2. Technical analysis is necessary but incomplete

Technical signals remain useful, but they should be evaluated inside a wider context:

- interest-rate expectations;
- central-bank policy bias;
- inflation and employment releases;
- geopolitical risk;
- cross-market confirmation where relevant.

This does not mean the EA should predict macroeconomics. It means the system should know when uncertainty is elevated and when a technically attractive signal is not enough.

### 3. A trade plan exists before a trade

Every trade should have, before entry:

- direction;
- reason for entry;
- stop loss;
- take-profit logic;
- invalidation condition;
- maximum risk;
- event-risk status.

If any of those are missing, the correct output is `NO TRADE`.

### 4. Practice first, specialize early

The project should favor:

- demo trading before live trading;
- a narrow initial symbol list;
- repeated review of the same instruments;
- learning the personality of a few pairs instead of chasing everything.

### 5. Low leverage is a feature, not a limitation

The bot should be intentionally unimpressed by large notional exposure. Small capital plus high leverage is a fragility amplifier, not an edge.

### 6. Other markets matter

The dashboard and research process should eventually track relevant context such as:

- broad USD strength;
- yields / rate expectations;
- commodities for commodity-linked currencies;
- equity-risk tone during risk-on / risk-off regimes.

These are context inputs, not autonomous trade signals.

### 7. Losses must produce learning

Every bad trade should be classifiable:

- valid setup, normal loss;
- execution problem;
- violated rule;
- poor market regime;
- news or macro conflict;
- overfit signal.

The system should support post-trade review, not just P/L reporting.

## Concrete project consequences

The book pushes ForexRiskBot toward:

- fewer supported pairs at launch;
- stronger pre-trade checklist logic;
- explicit macro/event uncertainty filters;
- swap / rollover awareness;
- richer post-trade classification;
- less parameter chasing and more process validation.
