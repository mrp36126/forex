# Signal-engine redesign options

## Why a redesign is needed

The latest robustness batch rejected both:

- the asymmetric short-only revision;
- the prior long-and-short breakout revision.

The safety architecture worked, but the signal model did not survive:

- older EURUSD years;
- other major pairs;
- or comparison against nearby variants.

The next move should therefore be a concept reset, not another narrow filter tweak.

## Core design change

Separate the signal engine into two layers:

1. **Regime classifier**
   - trend;
   - breakout candidate;
   - range;
   - uncertain / no-trade.

2. **Playbook modules**
   - one module per regime;
   - each module has its own entry, invalidation, and metrics;
   - modules can be tested independently before any future combination.

## Candidate A - Conservative trend continuation only

### Idea

Trade only mature, organized trends and only on pullbacks that resume in the trend direction.

### Conceptual rules

- higher timeframe trend required;
- moving averages aligned and sloping;
- pullback into value area;
- confirmation candle in trend direction;
- sufficient room before the next obstacle;
- no breakout chasing;
- range and ambiguous states are `NO TRADE`.

### Strengths

- simplest to explain;
- closest to the books' common ground;
- naturally selective;
- easiest to falsify cleanly.

### Weaknesses

- may trade rarely;
- may miss explosive moves that never pull back;
- existing tests already suggest naive pullback logic alone is not enough, so regime quality must improve.

### Best use

Recommended first baseline because it gives the cleanest answer to:  
**does a disciplined trend-following pullback edge exist here at all?**

## Candidate B - Breakout after compression

### Idea

Ignore general continuation breakouts and trade only a defined volatility-compression-to-expansion pattern.

### Conceptual rules

- prior compression / narrowing range;
- active session required;
- breakout close beyond a buffered level;
- minimum expansion body or ATR-based impulse;
- optional retest confirmation;
- no trade if the move occurs in thin liquidity or directly into a nearby obstacle.

### Strengths

- conceptually distinct from the failed blended breakout logic;
- testable;
- fits known volatility-cycle behavior.

### Weaknesses

- false breakouts can be frequent;
- more sensitive to execution quality;
- may require more careful definition than Candidate A.

### Best use

Good second research line after the cleaner trend baseline is tested.

## Candidate C - Explicit dual-playbook architecture

### Idea

Keep trend continuation and compression breakout as separate modules from the beginning, then allow only the regime classifier to choose between them.

### Strengths

- architecturally closest to a production framework;
- avoids pretending one setup fits all conditions;
- produces rich diagnostics by playbook.

### Weaknesses

- harder to interpret early results;
- more implementation surface;
- temptation to combine two weak strategies into one noisy system.

### Best use

Good eventual architecture, but not the best first research step immediately after a failed robustness batch.

## Recommendation

Start with **Candidate A: Conservative trend continuation only**.

Reason:

- it is the cleanest hypothesis;
- it has the lowest overfitting risk;
- it aligns with the strongest repeated lessons from the books;
- it lets us find out whether the project has a viable technical core before adding a second playbook.

## Acceptance criteria for the next candidate

Before calling the next version "promising," require:

1. positive or near-break-even behavior across several EURUSD years, not just one recent window;
2. no catastrophic collapse on other majors;
3. profit factor preferably above `1.05` across multiple windows before any optimization;
4. drawdown materially lower than the rejected baseline;
5. results that remain directionally similar under nearby coarse parameter values;
6. clear logs showing:
   - regime classification;
   - why trades were allowed;
   - why trades were blocked;
   - performance by playbook.

## Things not to do next

- Do not keep disabling one side of the market because one sample happened to reward it.
- Do not add several named setups at once.
- Do not optimize indicator periods yet.
- Do not count a single profitable year as strategy validation.
