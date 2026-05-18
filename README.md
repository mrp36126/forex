# ForexRiskBot

ForexRiskBot is a conservative MetaTrader 5 forex trading-system baseline. It is designed to protect capital first, explain every decision, and support demo-first validation before any live deployment.

## Safety position

- This project does **not** promise profits.
- Trying to make roughly `R100/day` from `R1000` implies a very aggressive daily return target and should be treated as high risk, not as a design requirement.
- The robot intentionally prefers **NO TRADE** over weak trades.
- Martingale, grid recovery, revenge trading, uncontrolled averaging down, and oversized lots are excluded by design.

## Repository layout

```text
docs/
  strategy.md
  risk-rules.md
  backtesting-checklist.md
  live-trading-checklist.md
mt5-ea/
  Experts/ForexRiskBot/ForexRiskBot.mq5
  Include/ForexRiskBot/
    Config.mqh
    Logger.mqh
    NewsFilter.mqh
    RiskManager.mqh
    SignalEngine.mqh
    TradeManager.mqh
supabase/
  schema.sql
web-dashboard/
  app/
  components/
  lib/
```

## System boundaries

- **MT5 EA**: the only component allowed to place or modify trades.
- **Supabase**: stores settings, logs, sentiment snapshots, risk events, and backtest results.
- **Vercel dashboard**: read-only monitoring surface for status, P/L, drawdown, open risk, trade history, and blocked-trade reasons.
- **Sentiment service**: optional external filter only. It may approve, block, or abstain; it must never create trades directly.

## Recommended rollout

1. Read the strategy and risk docs.
2. Compile the EA in MetaEditor.
3. Backtest on 2â€“3 years of realistic data with spread/slippage assumptions.
4. Reject fragile results rather than optimizing until they look pretty.
5. Demo trade for 4â€“8 weeks.
6. Only after validation, consider very small live sizing.

## Installation summary

1. Copy `mt5-ea/Experts/ForexRiskBot` into your MT5 `MQL5/Experts` directory.
2. Copy `mt5-ea/Include/ForexRiskBot` into your MT5 `MQL5/Include` directory.
3. Open `ForexRiskBot.mq5` in MetaEditor and compile.
4. Configure inputs conservatively on a demo account.
5. Apply the Supabase schema if you want external logging/dashboard support.

More detailed instructions are included in the docs files.

## Documentation map

- `docs/strategy.md` â€” exact trading logic and filters
- `docs/risk-rules.md` â€” capital-protection rules
- `docs/backtesting-checklist.md` â€” validation process
- `docs/live-trading-checklist.md` â€” go-live gate
- `docs/setup.md` â€” installation, MT5, Supabase, and Vercel setup
- `docs/architecture.md` â€” component boundaries and sentiment-service design
- `docs/strategy-tester.md` â€” first Strategy Tester run and what to inspect
- docs/book-notes-currency-trading-for-dummies.md - book-informed project principles
- docs/book-review-currency-trading-for-dummies.md - applied lessons from the full supplied book
- docs/book-review-day-trading-and-swing-trading.md - applied lessons from Kathy Lien's currency-market framework
- docs/book-review-forex-trading-basics-secrets.md - selective lessons adopted from the beginner-focused forex handbook
