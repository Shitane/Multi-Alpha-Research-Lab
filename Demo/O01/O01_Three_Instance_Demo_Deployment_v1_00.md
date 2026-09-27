# O01 Three-Instance Demo Deployment v1.01

## Goal

Run a three-chart comparison on ONE MT5 DEMO HEDGING account without creating separate FULL and SPLIT EA products.

| Chart | Codebase | Route | Planned Magic |
|---|---|---|---:|
| 1 | Original O01 benchmark | Original O01 | 46102030 |
| 2 | SAME Multi Alpha EA binary | FULL / O01 | 46102031 |
| 3 | SAME Multi Alpha EA binary | SPLIT / O01 + O01 + O01 | 46102032 |

FULL and SPLIT are selectable routes inside one Multi Alpha EA. A FULL-only host may remain as a diagnostic scaffold, but it is not the target architecture.

## Verified v1.64 regression checkpoint — 2026-09-28

The current execution-gate development host `MultiAlpha_Runtime_Panel_DemoGate_v1_64.mq5` has completed the frozen O01 NO_ORDERS regression checkpoint.

Verified common-baseline result:

- 2,571,204 ticks / 920 bars
- entries=31 / grids=5 / closes=31
- single_trail=27 / basket_trail=4 / virtual_sl=0
- buy_open=0 / sell_open=0
- `EXECUTION=NO_ORDERS`
- `BROKER_ACTIONS_ARMED=0`
- `VIRTUAL_NOT_FILL=1`
- MetaEditor compile: 0 errors / 0 warnings

This checkpoint proves regression preservation of the O01 virtual/no-order path. It does not prove broker-fill parity. The next validation remains the DEMO execution gate with identity/ownership/result logging and the route-safety rules below.

## Current safety boundary

The frozen parity/research path remains NO_ORDERS / VIRTUAL_NOT_FILL. The v1.64 execution-gate development host also retains that regression path, and its 2026-09-28 regression run confirmed `BROKER_ACTIONS_ARMED=0`.

Broker DEMO execution is a separate validation mode. Do not treat a successful NO_ORDERS regression as proof of broker execution parity, and do not add broker order functions to the frozen parity/research modules.

## Instance identity

The Multi Alpha host exposes:

- InpInstanceId
- InpMagic

These values identify each attached instance in logs and prepare the single-EA execution boundary. They do not enable broker orders.

Suggested research instances:

- Chart 2: InpInstanceId=2, InpMagic=46102031, Structure=FULL, Full=O01
- Chart 3: InpInstanceId=3, InpMagic=46102032, Structure=SPLIT, Entry=O01, Manage=O01, Exit=O01

Unsupported routes must reject. There is no O01 fallback for an unregistered capability.

## O01 ownership audit

The frozen Original O01 source filters managed open positions by both:

- POSITION_SYMBOL == _Symbol
- POSITION_MAGIC == InpMagic

Closed-profit history also filters DEAL_SYMBOL and DEAL_MAGIC.

Persistent terminal Global Variables use a base key containing:

- account login
- InpMagic
- symbol

This means position/history/persistent-state ownership is separated by Magic in the inspected Original O01 implementation.

## Important DD coupling

Magic separation does NOT make drawdown independent.

The Original O01 drawdown calculation uses account Balance/Equity (and, in PEAK_EQUITY mode, an account-equity peak). Therefore profit/loss from another EA instance on the same demo account can affect an O01 instance's:

- Warning DD threshold
- Grid Pause threshold
- Emergency Close threshold

The 8% / 12% / 15% safety behavior must not be treated as per-instance parity when several trading instances share one account.

For forward comparison, distinguish:

1. decision/route parity — Entry, Manage, Exit decisions
2. broker execution parity — request/fill/result behavior
3. account-level safety behavior — DD thresholds affected by total account equity

Do not rewrite the frozen O01 DD formula merely to make the comparison convenient. If isolated DD parity is required, use separate demo accounts or add a separately specified future per-instance risk contract after the frozen baseline is preserved.

## Next execution gate

Before the SAME Multi Alpha EA binary may place demo orders, add one broker execution adapter owned by the host. Decision modules remain order-free.

The adapter gate must include:

- hard DEMO-account lock
- hard HEDGING-account lock
- positive InstanceId and Magic
- Symbol + Magic filtering for every position read/modify/close
- checked and logged broker result codes
- explicit execution_transition_pending state
- route changes rejected while managed positions are open, a cycle is active, or execution transition is pending
- no order functions inside FULL/SPLIT decision modules unless the FULL adapter is explicitly treated as a separately frozen whole-path compatibility boundary
- NO_ORDERS regression path retained

## Remote deployment sequence

Compile and verify the current host first. The v1.64 NO_ORDERS baseline has passed. Then attach the same compiled Multi Alpha EA to two charts with different InstanceId/Magic and FULL/SPLIT routes and confirm independent identity and the expected active route.

For broker-DEMO validation, keep the planned identities:
- FULL / O01: InstanceId=2, Magic=46102031
- SPLIT / O01+O01+O01: InstanceId=3, Magic=46102032

Validate broker actions separately from the NO_ORDERS regression, and preserve the frozen NO_ORDERS path for every later execution-adapter change.

Only after compile, no-order regression, route-safety regression, and Magic-isolation checks pass should DEMO broker execution be armed.

## Forward comparison fields

Record independently for Original / Multi Alpha FULL / Multi Alpha SPLIT:

- instance id
- Magic
- active route
- signal timestamp
- BUY/SELL
- requested lot
- initial/grid
- grid number
- close timestamp
- close reason
- trailing state
- managed position count
- broker request/result code when execution is later enabled

Actual broker fill prices can differ because requests are sequential. Decision parity and fill parity are separate measurements.
