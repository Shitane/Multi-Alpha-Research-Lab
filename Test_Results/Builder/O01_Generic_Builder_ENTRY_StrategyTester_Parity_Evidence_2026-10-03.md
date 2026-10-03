# O01 Generic Builder ENTRY — Strategy Tester Parity Evidence — 2026-10-03

## Gate
`MA_Builder_O01_Entry_Parity_Tester_v1_02.ex5`

## Observed environment
- Symbol: `XAUUSD_DUKA`
- Timeframe: `M15`
- Broker/test environment: `TitanFX-MT5-Demo`
- Model: generating based on real ticks
- Test range: 2026-08-16 00:00 through 2026-08-29 00:00
- RSI period: 8
- Lower: 30.0
- Upper: 70.0
- Max samples: 200000

## Observed result
At 2026-08-17 15:26:39 tester time:
- `TOTAL PARITY 114409/114409`
- `BUY_HITS=1`
- `SELL_HITS=12467`
- `RESULT: PASS - O01 reference ENTRY == generic Builder ENTRY with both BUY and SELL observed`
- `NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0`

Tester generated 2,571,204 ticks / 920 bars for the full configured test run.

## Conclusion
The O01 reference ENTRY decision and the generic Builder ENTRY decision matched on every evaluated sample through the point where both BUY and SELL had been observed. This establishes Strategy Tester parity for the ENTRY decision path under the tested context and thresholds.

This evidence does not establish MANAGE or EXIT historical-tick parity and does not authorize broker execution.
