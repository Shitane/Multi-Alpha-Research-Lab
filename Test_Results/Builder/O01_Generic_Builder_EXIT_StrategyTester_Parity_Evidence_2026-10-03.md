# O01 Generic Builder EXIT — Strategy Tester Parity Evidence — 2026-10-03

## Gate
`MA_Builder_O01_Exit_Parity_Tester_v1_00.ex5`

## Observed environment
- Symbol: `XAUUSD_DUKA`
- Timeframe: `M15`
- Broker/test environment: `TitanFX-MT5-Demo`
- Model: generating based on real ticks
- Test range: 2026-08-16 00:00 through 2026-08-29 00:00

## Observed result
At 2026-08-17 01:00:03 tester time:
- `TOTAL EXIT PARITY 140/140`
- `VSL=20`
- `TP=20`
- `SINGLE=20`
- `BASKET=20`
- `RESULT: PASS - O01 reference EXIT == generic Builder-part EXIT with all exit families observed`
- Scope: deterministic virtual position/trailing state + active Strategy Tester market ticks
- `NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0`

## Conclusion
Under the tested deterministic virtual position/trailing contexts and active Strategy Tester market ticks, the O01 reference EXIT decision and generic Builder-part EXIT decision matched on all 140 comparisons. Virtual SL, Fixed TP, Single Trailing, and Basket Trailing were each observed 20 times.

This establishes the EXIT role parity for this gate only. It does not yet establish an integrated saved ENTRY+MANAGE+EXIT Builder Route, stateful virtual-cycle parity across historical ticks, or broker execution.
