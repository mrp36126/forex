# Setup guide

## 1. MetaTrader 5

1. In MT5, open `File -> Open Data Folder`.
2. Copy `mt5-ea/Experts/ForexRiskBot` into `MQL5/Experts`.
3. Copy `mt5-ea/Include/ForexRiskBot` into `MQL5/Include`.
4. Open `ForexRiskBot.mq5` in MetaEditor.
5. Compile the EA.
6. In MT5, enable algorithmic trading only on a **demo account** first.
7. Attach the EA to one chart per symbol you intend to test.
8. Start with conservative defaults:
   - `RiskPercent = 0.50`
   - `MaxDailyLossPercent = 2.00`
   - `MaxTradesPerDay = 3`
   - `UseNewsFilter = true`
   - `UseSentimentFilter = false` until an external sentiment bridge is validated

## 2. Backtesting in MT5

1. Open Strategy Tester.
2. Select `ForexRiskBot`.
3. Use a liquid forex pair and `M15` modelled with realistic costs.
4. Test at least `2–3 years`.
5. Review the metrics in `backtesting-checklist.md`.
6. Repeat on several pairs and regimes.
7. Do not optimize until the unoptimized baseline is understood.

## 3. Supabase

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the SQL editor.
3. Create row-level-security policies before exposing data outside a trusted environment.
4. Keep broker credentials and MT5 credentials out of Supabase.

## 4. Dashboard environment variables

Create `web-dashboard/.env.local` from `.env.example`:

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

Important:

- `SUPABASE_SERVICE_ROLE_KEY` must stay server-side only.
- Never expose broker credentials, MT5 login details, or private API keys in frontend code.

## 5. Vercel

1. Import the `web-dashboard` project into Vercel.
2. Add the same environment variables in Vercel project settings.
3. Deploy the dashboard.
4. Treat it as monitoring only; it must not place trades.

## 6. Demo-first rollout

1. Demo test for `4–8 weeks`.
2. Confirm stops, blackout windows, lot sizing, spread filters, and lockouts.
3. Compare demo behavior to backtest expectations.
4. Only then consider very small live deployment.
