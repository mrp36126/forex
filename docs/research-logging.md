# Research CSV logging

ForexRiskBot now has a structured research logger for Strategy Tester analysis.

## Purpose

The normal MT5 journal is useful for debugging, but it is awkward for statistical review. The research CSV logger creates machine-readable rows for:

- blocked decisions;
- accepted trade plans;
- closed trades.

This lets us analyze future candidates by:

- setup / playbook;
- direction;
- hour;
- ATR points;
- spread;
- profit;
- block reason.

## Inputs

```text
EnableResearchCsvLog = true
LogBlockedSignalsToCsv = true
```

For long multi-year tests, `LogBlockedSignalsToCsv=true` can create large files. If only trade-level analysis is needed, set it to `false` and keep `TRADE_PLAN` / `TRADE_CLOSE` rows.

## Output location

The EA writes files to the MetaTrader common files directory:

```text
%APPDATA%\MetaQuotes\Terminal\Common\Files
```

Files are named like:

```text
ForexRiskBot_research_EURUSD_YYYYMMDD_HHMMSS_TICKCOUNT_MAGIC.csv
```

## Columns

```text
timestamp,symbol,event,action,setup,direction,hour,atr_points,spread_points,lots,entry,sl,tp,rr,profit,deal,reason
```

Important event types:

- `BLOCKED` - no trade was opened;
- `TRADE_PLAN` - an order was accepted and submitted;
- `TRADE_CLOSE` - a position closed and realized P/L was logged.

## Analyzer script

Use the lightweight Python helper:

```powershell
python tools\analyze_research_csv.py "$env:APPDATA\MetaQuotes\Terminal\Common\Files\ForexRiskBot_research_*.csv"
```

The script summarizes:

- event counts;
- setup counts;
- action counts;
- rows by hour;
- blocked reason prefixes;
- blocker condition tags;
- closed-trade P/L by setup;
- closed-trade P/L by direction;
- closed-trade P/L by hour;
- closed-trade P/L by ATR bucket;
- closed-trade P/L by spread bucket.

## Safety note

The research logger does not place trades and does not change risk logic. It only records decisions already made by the EA.
