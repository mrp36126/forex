
# Risk rules

## Core principle

The first job of the robot is survival. A small account cannot absorb reckless sizing, frequent losses, or wide transaction costs.

## Capital and return expectations

Trying to generate about `R100/day` from `R1000` means targeting roughly `10%` per day before costs. That is a high-risk expectation and must never drive position sizing or trade frequency.

## Per-trade controls

- Default risk per trade: `0.50%` of account balance.
- Allowed operating range: `0.25%` to `1.00%`.
- No trade may be opened without a hard stop loss.
- Lot size must be calculated from:
  - account balance,
  - configured risk percentage,
  - stop-loss distance,
  - tick size,
  - tick value,
  - broker volume step/min/max.
- If a valid lot size cannot be calculated safely, return `NO TRADE`.

## Daily controls

- Maximum daily loss: default `2.0%`.
- Maximum trades per day: default `3`.
- Stop after `2` consecutive losses by default.
- Stop after reaching the daily profit target if configured.
- Never increase risk to recover losses.

## Portfolio and execution controls

- One open position per symbol.
- Maximum total open risk across all positions.
- Block trades when:
  - spread exceeds threshold,
  - slippage is unacceptable,
  - outside configured trading hours,
  - near illiquid session boundaries,
  - daily brakes are active,
  - risk budget is exhausted.

## Exit controls

- Initial stop: ATR multiple.
- Minimum reward:risk ratio: `1.5`.
- Default reward:risk ratio: `2.0`.
- Break-even is optional after `1R`.
- Trailing is optional and should not be enabled until it has been tested across regimes.

## Forbidden behaviors

- Martingale.
- Grid recovery.
- Revenge trading.
- Oversized lots.
- Uncontrolled averaging down.
- Removing stops to avoid realizing losses.

## Safe default behavior

When data is missing, sentiment is unclear, news timing is uncertain, or execution costs are elevated, the correct action is:

> `NO TRADE`
