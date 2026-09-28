# A10 FULL / SPLIT NO_ORDERS parity record — 2026-09-28

## Scope
Independent A10 FULL module versus A10 SPLIT (ENTRY + MANAGE + EXIT) on the common regression baseline.

## Baseline
- Symbol: XAUUSD_DUKA
- Timeframe: M15
- Period: 2026-08-16 through 2026-08-29
- Tick model: real ticks
- Initial deposit: JPY 100000
- Leverage: 1:100
- Ticks / bars: 2,571,204 / 920
- Safety: NO_ORDERS=1, VIRTUAL_NOT_FILL=1

## Compile gate
`A10_Full_Module_Parity_NoOrders_v1_00.mq5`
- 0 errors
- 0 warnings
- verified in MetaEditor on 2026-09-28

Required FULL dependencies:
- `A10_Full_Module_v1_00.mqh`
- `A10_Bollinger_Module_v1_00.mqh`

## FULL result
`[A10_FULL100_SUMMARY]`
- ticks=2571204
- entries=6
- exits=4
- open=2
- breakout_entries=4
- breakout_exits=3
- reentry_entries=0
- reentry_exits=0
- midline_entries=1
- midline_exits=1
- squeeze_entries=1
- squeeze_exits=0
- reason=1
- NO_ORDERS=1
- VIRTUAL_NOT_FILL=1

## SPLIT reference
`A10_Split_Manage_Parity_NoOrders_v1_01.mq5` produced the same summary counts on the same baseline:
- entries=6
- exits=4
- open=2
- breakout 4/3
- re-entry 0/0
- midline 1/1
- squeeze 1/0

Observed lifecycle events also matched in timestamp, direction, price, mode, and exit reason, including:
- 2026-08-20 17:56:46 Breakout BUY 4512.44
- 2026-08-21 14:26:46 Breakout TIME exit 4597.18
- 2026-08-24 05:10:49 Breakout BUY 4648.65
- 2026-08-25 01:40:49 Breakout TIME exit 4660.13
- 2026-08-25 22:16:30 Breakout BUY 4665.55
- 2026-08-26 18:02:52 Breakout BB_OPPOSITE exit 4595.06
- 2026-08-26 18:15:43 Midline SELL 4585.67
- 2026-08-28 07:15:44 Midline TIME exit 4580.91
- 2026-08-28 17:02:28 Breakout SELL 4579.24
- 2026-08-28 17:14:49 Squeeze SELL 4543.70

## Gate result
**A10 FULL ↔ SPLIT NO_ORDERS parity: PASS**

This verifies the A10 module decision/lifecycle parity for this documented baseline only. It does not certify broker execution.

## Integration consequence
Parity verification is not the same as runtime registration.

At the time of this record, `MultiAlpha_Module_Registry_v1_61.mqh` still registers A10 ENTRY only because the current Multi Alpha runtime host only connects the A10 Entry dispatcher. A10 FULL / MANAGE / EXIT must remain NOT REGISTERED until their runtime dispatch/ownership contracts are connected and regression-tested. Never change the registry first merely to expose an unconnected capability.

Next integration order:
1. connect A10 FULL runtime dispatch without changing the frozen A10 logic;
2. connect A10 MANAGE and EXIT contracts for SPLIT;
3. update registry only when each capability is actually reachable;
4. run common NO_ORDERS regression;
5. only then create a separate DEMO execution gate.
