# O01 Three-Instance Demo Deployment v1.00

## Goal

Run three independent O01 comparison instances on ONE MT5 demo hedging account:

| Chart | Role | Structure | Required Magic |
|---|---|---|---:|
| 1 | Original O01 benchmark | Original | 46102030 |
| 2 | Frozen whole-path reproduction | FULL | 46102031 |
| 3 | Modular composition | SPLIT (Entry/Manage/Exit) | 46102032 |

All three must use the same symbol/timeframe and equivalent strategy settings for parity comparison.

## Safety boundary

- Original O01 and FULL may submit broker orders only on a DEMO account.
- SPLIT broker execution is NOT enabled yet. Existing SPLIT/parity files remain NO_ORDERS / VIRTUAL_NOT_FILL.
- Do not convert any Parity_Tests host into a trading EA.
- No unsupported module may silently fall back to O01.
- Each trading instance manages positions by Symbol + its own Magic.
- Use a HEDGING demo account. The frozen O01 module rejects non-hedging accounts.

## Stage A — copy to Remote Desktop now

On the development PC, keep GitHub as the source of truth. On the remote MT5, copy the following source files into the corresponding MQL5 locations.

### Original benchmark

Copy the frozen original O01 source/module used by the current benchmark. Keep:
- Magic = 46102030

### FULL demo host

EA:
- Demo/O01/O01_GSG_RSI30_Full_Runtime_Demo_v1_01.mq5

Required include:
- O01_GSG_RSI30_Monolithic_Module_v1_00.mqh

The repository module is the frozen whole-path source. On the remote terminal, place it at:
- MQL5/Include/Original_Logic/O01_GSG_RSI30_Monolithic_Module_v1_00.mqh

Place the host at:
- MQL5/Experts/MultiAlpha_Demo/O01_GSG_RSI30_Full_Runtime_Demo_v1_01.mq5

Compile on the REMOTE MetaEditor. Do not copy an old EX5 over a newer source and assume it is current.

FULL host v1.01 intentionally refuses initialization unless:
- InpMagic = 46102031

### SPLIT research host — observation only for now

Keep the current verified selector/runtime research EA available for visual/decision observation, but it remains:
- NO_ORDERS=1
- VIRTUAL_NOT_FILL=1

Do NOT count it as broker-execution parity yet.

## Stage B — first remote validation

Before AutoTrading is enabled:

1. Open three XAUUSD charts with the same timeframe.
2. Attach Original to Chart 1.
3. Attach FULL v1.01 to Chart 2 and set InpMagic=46102031.
4. Attach current SPLIT research host to Chart 3.
5. Confirm Expert log identifies each role correctly.
6. Confirm Original Magic=46102030 and FULL Magic=46102031.
7. Confirm SPLIT still reports NO_ORDERS / VIRTUAL_NOT_FILL.
8. Confirm the account is DEMO and HEDGING.

Only after these checks should Original/FULL AutoTrading be enabled.

## Stage C — SPLIT real-demo development

Next code gate will add a SEPARATE demo execution layer for SPLIT. Required properties:

- hard DEMO-account lock
- hard HEDGING-account lock
- required Magic = 46102032
- Symbol + Magic filtering for every position read/modify/close
- synchronous execution result checking and logging
- explicit pending-execution-transition state
- no order function inside Entry/Manage/Exit decision modules
- route change rejected while positions are open, cycle is active, or execution transition is pending
- Entry/Manage/Exit module decisions remain independently testable under NO_ORDERS

SPLIT real-demo execution is not PASS until compile, no-order regression, isolation test, and user-observed demo behavior are all confirmed.

## Forward comparison fields

Record independently for Original / FULL / SPLIT:
- signal timestamp
- BUY/SELL
- requested lot
- initial/grid
- grid number
- close timestamp
- close reason
- trailing state
- managed position count
- broker fill/result code

Actual fill prices can differ slightly because three requests are sequential. Decision parity and fill parity are separate measurements.

## Important DD note

The O01 safety logic can depend on account Balance/Equity. Running three trading instances on one account can therefore couple DD measurements. Normal entry/manage/exit parity should be checked first. Warning 8%, Grid Pause 12%, Emergency Close 15% behavior must be evaluated separately with this account-level coupling documented.
