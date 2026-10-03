# O01 Saved Builder Route — Strategy Tester Evidence — 2026-10-03

## Result
PASS for the saved-definition execution path in Strategy Tester.

Observed user run:
- EA: `MA_Builder_O01_Tester_Gate_v1_00.ex5`
- Symbol: `XAUUSD_DUKA`
- Timeframe: `M15`
- Model: real ticks
- Test range: 2026-08-16 through 2026-08-29
- Saved route: `BUILDER_E01 + BUILDER_M01 + BUILDER_X01`
- RSI period: 8
- Target samples: 20
- Final: `TOTAL EVALUATED 20/20 ticks_received=20 rsi_wait=0`
- Final result: `PASS - exact saved ENTRY/MANAGE/EXIT Builder route evaluated on Strategy Tester ticks`
- Safety: `NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0`

## What this proves
The saved Builder route can load all three role definitions and pass Strategy Tester historical tick + RSI context through the generic saved-definition evaluator without evaluator errors.

## What this does NOT prove
This is not yet O01 behavioral parity on historical ticks. In the observed 20 samples, ENTRY/MANAGE/EXIT decisions were all false. The current saved ENTRY expression also contains a duplicated lower-threshold operand and therefore does not yet encode the verified two-direction O01 ENTRY semantics.

The verified O01 ENTRY reference semantics remain:
- BUY when common gates pass, BUY is enabled, BUY side is empty, and RSI < lower threshold.
- SELL when common gates pass, SELL is enabled, SELL side is empty, and RSI > upper threshold.
- Default thresholds in the verified parity harness: lower 30, upper 70.

Next gate: represent those verified semantics with generic Builder parts and compare Reference O01 vs saved Builder decisions on the same Strategy Tester market context.