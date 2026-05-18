# Architecture

## Components

| Component | Responsibility | May place trades? |
| --- | --- | --- |
| MT5 EA | Signals, execution, position sizing, hard risk controls | Yes |
| Sentiment service | Fetch approved news sources and classify market tone | No |
| Supabase | Store settings, logs, sentiment snapshots, risk events, backtests | No |
| Vercel dashboard | Read-only monitoring and reporting | No |

## Data flow

1. The EA evaluates a new candle.
2. It checks session, spread, risk limits, and economic-calendar blackout windows.
3. It evaluates technical signals.
4. If enabled, it queries a separate sentiment layer.
5. It either opens a trade or records `NO TRADE` with the reason.
6. Logs are persisted for review and dashboard display.

## Sentiment service contract

A safe sentiment endpoint should return only filtering metadata, for example:

```json
{
  "symbol": "EURUSD",
  "sentiment": "bullish",
  "confidence": 0.81,
  "high_uncertainty": false,
  "observed_at": "2026-05-18T10:00:00Z"
}
```

Rules:

- stale data => block or abstain;
- low confidence => block;
- conflicting sources => `high_uncertainty`;
- no endpoint response => `NO TRADE`;
- endpoint must never send trade commands.
