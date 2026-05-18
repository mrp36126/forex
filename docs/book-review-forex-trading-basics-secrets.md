# Applied review: Forex Trading Basics & Secrets Volume 3.0

Source: *Forex Trading Basics & Secrets, Volume 3.0* by Forex Hero.

## Lessons adopted

### Low leverage is a safety feature

The book repeatedly warns that leverage magnifies losses as quickly as gains and recommends conservative effective leverage. For ForexRiskBot:

- lot sizing remains risk-based rather than margin-based;
- small accounts must not be encouraged into larger positions just because a broker permits them;
- low effective leverage is treated as a sign of discipline, not missed opportunity.

### Begin with liquid major pairs

The book recommends that beginners focus on the major pairs before expanding. That supports the current project rule:

- validate on a small universe of liquid majors first;
- avoid exotics until spread, liquidity, swap, and execution behavior are measured;
- add symbols only after they survive their own validation.

### Timing and liquidity matter

The book emphasizes that the forex market is open continuously but not equally tradable at all hours. Applied to the project:

- session filters remain mandatory;
- spread widening during thin hours and around major announcements must be measured;
- backtests should report performance by hour and session, not only in aggregate.

### News changes execution conditions

The book gives practical attention to economic calendars, expectations versus actual releases, and pre-news spread widening. For the EA:

- high-impact event blackouts remain a core safety control;
- news is not only a directional issue, but also an execution-risk issue;
- the robot should avoid pretending that a technical setup is unchanged when spreads and volatility are abnormal.

### Use both technical and fundamental awareness

The book argues that technical patterns can fail around major events and that fundamentals alone are also insufficient. That reinforces our design:

- technical rules create the setup;
- news and sentiment layers may veto it;
- no external macro service may directly place trades.

### Keep multiple timeframes

The book recommends using higher timeframes for trend context and lower timeframes for entries. That supports the existing H1/M15 architecture and the rule that the entry chart must not overrule the broader regime.

### Protect expectancy, not ego

The risk-management section stresses stop losses, reward:risk planning, and not allowing one large loss to erase many small gains. For this project:

- every trade requires a stop loss;
- default reward:risk remains `2R`;
- the robot must prefer a valid loss over an invalid rescue attempt.

## Lessons deliberately not adopted

Some material is either promotional, unsuitable for automation, or inconsistent with our safety goals:

- copy-trading suggestions;
- the claim that a trader should risk anything close to `1/6` of free capital;
- widening stops around news as a routine tactic;
- optimistic examples that focus on leverage-enabled upside more than survival;
- any implication that forex is a quick path to large profits.

For ForexRiskBot, those are explicitly rejected.

## Concrete project consequences

- preserve conservative lot sizing and low effective leverage;
- keep the initial symbol universe restricted to liquid majors;
- strengthen validation by session and spread regime;
- treat event windows as both signal risk and execution risk;
- continue combining technical entries with non-execution macro veto layers;
- keep the system selective enough that `NO TRADE` remains a healthy outcome.
