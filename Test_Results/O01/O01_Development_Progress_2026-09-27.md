# O01 Development Progress — 2026-09-27

## Objective

O01 reproduces the logic of `Gold_Session_Guard_v4_Experimental_03_RSI30` while building the architecture needed for Multi Alpha Research Lab.

The target comparison is three simultaneous paths:

1. Original EA
2. FULL — frozen whole-strategy path
3. SPLIT — independently callable Entry / Manage / Exit path

FULL must never be silently substituted by the SPLIT implementation. The two routes are intentionally independent so that later three-chart demo parity has meaning.

## Verified milestones

### Original / O01 demo observation

Original EA and O01 have already shown matching demo behavior on observed cycles with separate Magic numbers. Same-account DD behavior remains a known special case because Balance/Equity is account-wide.

### SPLIT105 parity

The split O01 path reached the established baseline:

- ticks: 2,571,204
- entries: 31
- grids: 5
- closes: 31
- single trailing exits: 27
- basket trailing exits: 4
- virtual SL exits: 0
- final buy open: 0
- final sell open: 0

Earlier event-level comparison recorded 67/67 matching events between the split lifecycle and the runtime-panel baseline.

### Unified selector v1.42

`Parity_Tests/O01/O01_GSG_RSI30_Unified_Selector_NoOrders_v1_42.mq5` now contains two genuine NoOrders routes:

- `O01_STRUCTURE_FULL` -> frozen REF105-derived whole-path adapter
- `O01_STRUCTURE_SPLIT` -> O01 Entry / Manage / Exit modules through the router

The FULL route does not call the split Entry/Manage/Exit decision functions.

The user compiled v1.42 with 0 errors / 0 warnings.

### FULL / SPLIT common-baseline result

On XAUUSD_DUKA M15, 2026-08-16 through 2026-08-29, real ticks, both routes reached the same aggregate baseline:

```
ticks=2571204
entries=31
grids=5
closes=31
single_trail=27
basket_trail=4
virtual_sl=0
buy_open=0
sell_open=0
time_blocks=516374
news_blocks=0
spread_blocks=0
filter_blocks=0
```

The SPLIT run also reported 2,571,204 ticks / 920 bars / Test passed.

Representative SPLIT basket sequence:

```
2026.08.27 12:36:47 BUY INITIAL 0.01
2026.08.27 12:45:00 BUY GRID #2 0.02
2026.08.27 13:00:21 BUY GRID #3 0.03
2026.08.27 13:42:43 BASKET_TRAILING
```

## Freeze / safety decision

The v1.42 FULL and SPLIT trading-decision paths are now the O01 NoOrders architecture baseline.

Do not change their trading logic merely to add UI, routing, execution, or future module selection.

`NO_ORDERS=1` and `VIRTUAL_NOT_FILL=1` remain mandatory in this research/parity host.

Actual demo execution must be implemented through a separate execution layer after the common interface and safety gates are verified. It must not replace or mutate the NoOrders baseline.

## Next architecture step

Build a common module-selection interface around the verified paths so the future target EA can select logic without duplicating trading logic.

Required direction:

- FULL remains an independent whole-strategy route.
- SPLIT exposes Entry / Manage / Exit independently.
- Logic IDs are stable and explicit.
- Invalid or unsupported combinations fail safely; no silent fallback.
- Route changes are allowed only when the strategy is flat / cycle is inactive.
- The selector must later be controllable from both Expert Properties and the runtime panel.
- Backtest, demo and future live execution must call the same verified modules.

The next code phase is interface/router scaffolding only. It must not introduce broker orders.


## Common selector interface v1.50 — implementation started

The first common-selection layer has now been added without changing the verified v1.42 decision logic.

New files:

- `Modules/Common/MultiAlpha_Module_Contract_v1_50.mqh`
- `Modules/O01/O01_GSG_RSI30_Logic_Router_v1_50.mqh`
- `Parity_Tests/O01/O01_GSG_RSI30_Unified_Selector_NoOrders_v1_50.mq5`

v1.50 exposes explicit Expert Inputs for:

- Structure: FULL / SPLIT
- Full module
- Entry module
- Manage module
- Exit module

At the current gate only O01 is registered. Selecting an unsupported A10-A15 combination is expected to fail initialization with an explicit reason; it must not silently substitute O01.

The v1.50 O01 router is an adapter over the already verified v1.40 O01 router. SPLIT decisions therefore continue to pass through the frozen Entry / Manage / Exit implementation rather than a new reimplementation. FULL continues to dispatch to `O01_GSG_RSI30_Full_NoOrders_Adapter_v1_00.mqh`.

Safety remains:

```
NO_ORDERS=1
VIRTUAL_NOT_FILL=1
```

### Required verification before the next architecture gate

Compile `O01_GSG_RSI30_Unified_Selector_NoOrders_v1_50.mq5` first.

Then run the common baseline twice:

1. Structure = SPLIT; Entry/Manage/Exit = O01.
2. Structure = FULL; Full = O01.

Expected aggregate baseline for both valid O01 routes remains:

```
ticks=2571204
entries=31
grids=5
closes=31
single_trail=27
basket_trail=4
virtual_sl=0
buy_open=0
sell_open=0
```

Also perform one fail-safe check by selecting an unsupported module ID such as A14 in one SPLIT slot. Initialization should stop with an `[O01_ROUTER150_START] invalid route reason=...` message. This negative test verifies that the common selector does not silently fall back to O01.

Do not mark v1.50 parity PASS until compile and tester evidence are supplied.


## v1.50 FULL route verification — 2026-09-27

User tester evidence has now verified the genuine FULL route of `O01_GSG_RSI30_Unified_Selector_NoOrders_v1_50.mq5` on the common baseline:

- Symbol / timeframe: XAUUSD_DUKA M15
- Period: 2026-08-16 through 2026-08-29
- Model: real ticks
- Initial deposit: JPY 100,000
- Leverage: 1:100
- `InpStructureMode=FULL`
- `InpFullModule=O01`

The startup log explicitly reported:

```
[O01_SELECTOR150_ROUTE] structure=FULL full=O01 entry=O01 manage=O01 exit=O01 NO_ORDERS=1 VIRTUAL_NOT_FILL=1
[O01_FULL100_START] SOURCE=REF105_FROZEN_WHOLE_PATH ... NO_ORDERS=1 VIRTUAL_NOT_FILL=1
[O01_SELECTOR150_START] STRUCTURE=FULL SOURCE=REF105_FROZEN_WHOLE_PATH NO_ORDERS=1 VIRTUAL_NOT_FILL=1
```

Final FULL summary:

```
ticks=2571204
entries=31
grids=5
closes=31
single_trail=27
basket_trail=4
virtual_sl=0
buy_open=0
sell_open=0
time_blocks=516374
news_blocks=0
spread_blocks=0
filter_blocks=0
STRUCTURE=FULL
NO_ORDERS=1
VIRTUAL_NOT_FILL=1
```

Tester completed with 2,571,204 ticks / 920 bars / Test passed.

Representative FULL lifecycle evidence also preserved the expected grid/basket sequences, including the 2026-08-27 three-position BUY cycle ending in BASKET_TRAILING.

### Gate interpretation

This confirms that v1.50 FULL is not a disguised SPLIT route: it starts from the frozen REF105 whole-path source and reaches the established O01 aggregate baseline while preserving NoOrders safety.

The next required verification remains the negative fail-safe selector test. Select an unsupported module ID (for example A14) in one SPLIT slot and confirm that initialization stops with an explicit invalid-route reason and does not silently fall back to O01. Only after this safety test is confirmed should the selector advance to the next architecture gate (runtime-panel module selection / route-change safety).


## v1.50 negative fail-safe selector test — PASS

The planned unsupported-combination test has now passed.

Test selection:

```
Structure = SPLIT
Full     = O01
Entry    = A14   // intentionally unsupported at this gate
Manage   = O01
Exit     = O01
```

Observed startup result:

```
[O01_ROUTER150_START] invalid route reason=SPLIT entry module is not registered for this gate
[O01_SELECTOR150_SUMMARY] ticks=0 entries=0 grids=0 closes=0 ... STRUCTURE=SPLIT NO_ORDERS=1 VIRTUAL_NOT_FILL=1
tester stopped because OnInit reports incorrect input parameters
```

This proves the common selector does not silently substitute O01 when an unsupported module is selected. No ticks were processed and no virtual lifecycle was started.

### Gate status

O01 v1.50 common selector Gate is PASS for:

- valid SPLIT O01/O01/O01 baseline
- valid genuine FULL O01 baseline
- invalid SPLIT module fail-safe rejection
- NoOrders / Virtual-not-fill safety preservation

The verified decision paths remain frozen. The next architecture phase is runtime-panel selection for Structure / Full / Entry / Manage / Exit plus safe route-change rules. Route changes must be rejected while a managed cycle/position is active; no broker execution is introduced in this phase.


## Gate-3A started — runtime route-change safety v1.51

Before adding route selectors to the runtime panel, a reusable route-change controller has been added:

- `Modules/Common/MultiAlpha_Route_Controller_v1_51.mqh`
- `Parity_Tests/O01/O01_Route_Change_Safety_NoOrders_v1_51.mq5`

Policy:

- unsupported requested routes are rejected;
- route changes are rejected while managed positions are open;
- route changes are rejected while a cycle is active;
- route changes are rejected while an execution transition is pending;
- accepted changes update the active route only when the state is safe;
- rejection preserves the previous active route;
- no silent fallback;
- NO ORDERS.

The dedicated Gate-3A host intentionally contains no trading logic and no `OnTick` decisions. It exists only to verify the route-change policy before that policy is connected to the runtime panel.

Required first compile/test sequence:

1. Compile `O01_Route_Change_Safety_NoOrders_v1_51.mq5`.
2. Safe-flat test: positions=0, cycle_none=true, transition_pending=false, request SPLIT -> FULL O01. Expected: ACCEPT / route changed.
3. Open-position test: positions=1 with the same request. Expected: REJECT / managed positions are open; active route remains SPLIT.
4. Active-cycle test: positions=0, cycle_none=false. Expected: REJECT / cycle is active.
5. Pending-transition test: positions=0, cycle_none=true, transition_pending=true. Expected: REJECT / execution transition is pending.

Do not connect panel route controls until this gate is verified by tester evidence.


## Gate-3A COMPLETE — runtime route-change safety v1.51

Gate-3A is now formally PASS based on user-supplied MetaTrader 5 compile/tester evidence.

Compile status previously verified:

```
0 errors
0 warnings
```

The four required route-change conditions were verified:

| Test | State | Expected / observed |
|---|---|---|
| 1. Flat | positions=0, cycle_none=true, transition_pending=false | ACCEPT / route changed |
| 2. Position Open | positions=1, cycle_none=true, transition_pending=false | REJECT / managed positions are open |
| 3. Cycle Active | positions=0, cycle_none=false, transition_pending=false | REJECT / cycle is active |
| 4. Transition Pending | positions=0, cycle_none=true, transition_pending=true | REJECT / execution transition is pending |

For all rejection tests, the active route remained the original SPLIT O01 route. No automatic fallback occurred.

Final Gate-3A test 4 was run on the common baseline:

- XAUUSD_DUKA M15
- 2026-08-16 through 2026-08-29
- real ticks
- initial deposit 100,000
- leverage 1:100
- 2,571,204 ticks / 920 bars
- Tester: Test passed

Observed transition-pending evidence:

```
[MA_ROUTE151_REQUEST] requested={structure=FULL full=O01 entry=O01 manage=O01 exit=O01} state_positions=0 cycle_none=1 transition_pending=1 result=REJECT reason=execution transition is pending active={structure=SPLIT full=O01 entry=O01 manage=O01 exit=O01} NO_ORDERS=1
```

### Gate-3A status

**PASS / COMPLETE**

The verified policy is now:

1. Route change is accepted only when managed positions = 0, Cycle = NONE, and execution transition pending = false.
2. Any unsafe lifecycle state rejects the requested route and preserves the active route.
3. Unsupported modules reject explicitly; there is no silent fallback to O01.
4. This gate remains architecture-only / NoOrders. It does not add broker execution.
5. Existing parity-passed O01 FULL and SPLIT trading-decision logic remains frozen and unchanged.

### Next gate — Gate-3B

Connect Structure / Full / Entry / Manage / Exit selection to the existing O01 runtime panel and Expert Properties through Runtime Settings.

Gate-3B must preserve:

- Expert Properties -> OnInit -> Runtime Settings -> Panel
- APPLY: Panel -> validated Runtime route
- SAVE / LOAD / RESET behavior
- route changes only under the Gate-3A safe-state policy
- rejection preserves the current active route
- unsupported modules reject; never fall back to O01
- existing parity-passed FULL/SPLIT trading logic unchanged
- NO_ORDERS=1 / VIRTUAL_NOT_FILL=1 in the research/parity host
