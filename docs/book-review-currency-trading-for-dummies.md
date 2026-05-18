# Applied review: Currency Trading For Dummies, 4th Edition

This review is based on the full PDF supplied for the project.

## Lessons adopted

### Trade from a complete plan

The book repeatedly treats entry as only the beginning of the job. A real plan includes entry, stop, target, monitoring, and review. In the project, that means:

- every accepted trade must log the planned direction, entry, stop, target, and reward:risk ratio;
- every rejected trade must state why it was rejected;
- post-trade review remains part of the workflow, not an optional afterthought.

### Wait for confirmation

The technical-analysis chapter distinguishes between merely looking for confirmation and waiting for the market to prove the idea. In the EA, that means a pullback alone is not enough; the default signal now requires a confirmation candle after the pullback.

### Support and resistance matter because of behavior after the level

The book emphasizes follow-through after breaks of support or resistance. That pushes the project away from naive "touch = trade" logic and toward:

- structure-aware entries;
- confirmation after interaction with a level;
- future breakout tests that require evidence of continuation rather than only level penetration.

### Pair specialization beats scattered attention

The book strongly favors focusing on a few pairs. The project therefore keeps the launch universe deliberately small and treats pair behavior as something to learn, test, and document rather than assuming one ruleset behaves identically everywhere.

### Fundamentals and other markets provide context

Currencies are driven by more than indicators. The design now preserves a distinct macro-context layer for:

- central-bank policy;
- rate expectations;
- inflation and labor data;
- geopolitical risk;
- related-market confirmation.

That context may block or qualify a trade; it does not become a direct trade generator.

### Risk management is more than the stop itself

The book is explicit about low leverage, stop-loss discipline, avoiding event exposure, and taking profits seriously. Those ideas reinforce:

- low default risk per trade;
- explicit daily brakes;
- event blackouts;
- later evaluation of break-even and profit-protection rules only after testing.

### Simulate first and start small

The book's beginner guidance supports the project's existing demo-first philosophy:

- backtest first;
- demo trade next;
- then, if evidence supports it, test very small live size.

### Analyze losing trades

The system should distinguish:

- valid loss;
- bad regime;
- news conflict;
- execution issue;
- rule violation;
- strategy defect.

This is essential for improving the robot without blindly curve-fitting.

## Lessons deliberately not adopted

### Averaging into positions

The book discusses averaging into a position in a discretionary context. ForexRiskBot does **not** adopt that behavior because:

- the project explicitly forbids uncontrolled averaging down;
- it can turn a mistaken thesis into larger exposure;
- it is too easy to automate unsafely for a small account.

If scaling is ever studied later, it must be:

- preplanned before the first entry;
- capped by total open risk;
- additive only into profitable trades or strictly bounded thesis zones;
- validated out of sample.

For the current robot, the rule remains:

> one controlled entry, one defined stop, no rescue behavior.

## Changes made because of the book

- added explicit trade-plan logging in the EA;
- added `RequireConfirmationCandle` to default signal logic;
- added `MinATRPoints` to avoid trading dead conditions;
- strengthened the written strategy around macro context and pair specialization;
- added this review so future changes can be traced back to principles instead of random tweaks.
