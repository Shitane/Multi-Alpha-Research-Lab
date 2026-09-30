# COMMON FILTER all-OFF regression gate — v2.01

## Purpose
Verify that introducing the slot-local COMMON FILTER configuration/UI does not alter the verified A10 baseline while every filter part is OFF.

## Required baseline
- Symbol: XAUUSD_DUKA
- Timeframe: M15
- Period: 2026-08-16 through 2026-08-29
- Tick model: real ticks
- Initial deposit: JPY 100000
- Leverage: 1:100
- Ticks / bars: 2,571,204 / 920
- NO_ORDERS=1
- VIRTUAL_NOT_FILL=1

## Required configuration
Run `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_01.mq5` with FULL=A10 and leave every COMMON FILTER part OFF.

Startup must contain:
`[MA_FILTER201_OFF_GATE] slot=1 all_off=1 runtime_connected=0 expected_behavior=IDENTICAL_TO_PRE_FILTER_BASELINE NO_ORDERS=1 VIRTUAL_NOT_FILL=1`

## Expected A10 FULL summary
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

## Pass rule
PASS only when the tester summary matches every expected value above. Compile success alone is not a regression PASS.

## Safety boundary
v2.01 still does not connect COMMON FILTER permission to runtime entry execution. This is intentional. Runtime wiring is permitted only after this all-OFF regression gate is evidenced as PASS. EXIT and SAFETY remain outside filter blocking.
