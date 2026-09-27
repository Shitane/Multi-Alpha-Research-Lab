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
