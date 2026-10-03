# O01 Generic Builder Integrated Route — Strategy Tester Parity Evidence — 2026-10-03

## Gate
`MA_Builder_O01_Route_Parity_Tester_v1_00.ex5`

## Observed environment
- Symbol: `XAUUSD_DUKA`
- Timeframe: `M15`
- Broker/test environment: `TitanFX-MT5-Demo`
- Model: generating based on real ticks
- Test range: 2026-08-16 00:00 through 2026-08-29 00:00
- RSI period: 8
- Max samples: 200000

## Observed result
At 2026-08-17 15:26:39 tester time:
- `TOTAL ROUTE SAMPLES 114409`
- `ENTRY PARITY 114409/114409 BUY=1 SELL=12467`
- `MANAGE PARITY 114409/114409 ADD_BUY=50973 ADD_SELL=63436`
- `EXIT PARITY 114409/114409 EXITS=114409`
- `RESULT: PASS - O01 reference route == Builder route across ENTRY->MANAGE->EXIT`
- Scope: real tester RSI/ticks + deterministic virtual routed position/trailing state
- `NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0`

## Conclusion
The integrated tester gate passed all 114,409 comparisons for each role across the routed ENTRY -> MANAGE -> EXIT sequence. Both ENTRY directions and both MANAGE grid-add directions were observed.

This evidence proves the integrated parity gate only within its stated scope. The routed position/trailing state is deterministic and virtual. It does not yet prove that persisted SAVE24 definitions alone can reconstruct and execute the same complete O01 semantics, nor does it prove broker execution or a live demo trading cycle.
