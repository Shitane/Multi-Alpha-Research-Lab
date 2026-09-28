# O01 / Multi Alpha Development Progress — 2026-09-28

## Purpose

This record reconciles the current GitHub implementation with the compile/runtime evidence observed on the development and remote MT5 environments after the v1.50 selector gate.

It does **not** declare live/demo trading parity complete. Market-order lifecycle evidence is still pending because the latest remote validation was performed on Sunday and the O01 session is limited to the configured trading window.

## Architecture direction confirmed

The durable target remains the single-EA architecture in `Docs/MultiAlpha_Single_EA_Target_v1_00.md`:

- one Multi Alpha EA binary,
- `FULL` and `SPLIT` are routes of that same EA,
- each attached instance has its own Instance ID and Magic,
- FULL preserves the independent frozen whole-strategy reference path,
- SPLIT selects Entry / Manage / Exit independently,
- broker execution is owned by a common execution adapter rather than by decision modules,
- unregistered module combinations must fail safely and must never fall back silently to O01.

## Verified development state carried forward

### v1.50 selector gate

The established O01 baseline remains frozen:

- 2,571,204 ticks
- 920 bars
- entries 31
- grids 5
- closes 31
- single trailing 27
- basket trailing 4
- virtual SL 0
- buy open 0
- sell open 0

Both genuine FULL and SPLIT O01/O01/O01 routes matched this aggregate baseline in the documented NoOrders tester work. The unregistered SPLIT Entry=A14 negative test rejected initialization instead of falling back to O01.

### Route-change safety

The runtime route-change safety gate was verified for the required conditions:

- flat + no active cycle + no execution transition: route change accepted,
- managed position open: rejected,
- active cycle: rejected,
- execution transition pending: rejected.

The active route remains unchanged on rejection.

### v1.61 single-EA panel/registry line

The single-EA host contains:

- capability-specific module registry,
- O01 registration for the verified roles,
- A10 as a registered ENTRY capability,
- right-side route/composition selector,
- left-side module settings context,
- explicit Instance ID and Magic inputs.

The development compile evidence for the updated v1.61 host showed 0 errors / 0 warnings.

Remote NoOrders startup evidence was observed for two same-EA instances:

- FULL / O01: Instance 2, Magic 46102031
- SPLIT / O01 + O01 + O01: Instance 3, Magic 46102032

This establishes configuration/identity separation at startup. It does **not** by itself prove broker-position isolation under real demo fills.

## v1.62-v1.63 DEMO execution boundary

GitHub current files:

- `Modules/Common/MultiAlpha_Demo_Execution_Adapter_v1_62.mqh`
- `Modules/Common/MultiAlpha_Demo_Execution_Adapter_v1_63.mqh`
- `Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_DemoGate_v1_63.mq5`

Relevant commits:

- `b8dbbb0696a701273aa723dfa998b7bb0977ac9d` — Add v1.62 demo execution safety boundary
- `cb78516f03c597cc275d6be9dda446f252ff3229` — Integrate v1.62 demo execution safety gate into Multi Alpha host
- `81a5e21c27bc99ea3c196585ed86d0464c9a4ee9` — Add checked DEMO broker operations for v1.63 execution adapter
- `30fafd8427bc23c57471342d75fef64466e2629f` — Connect v1.63 Multi Alpha host to checked DEMO execution adapter

The v1.63 execution adapter implements:

- DEMO-account requirement,
- HEDGING-account requirement,
- positive Instance ID / Magic validation,
- Symbol + Magic ownership filtering,
- synchronous CTrade execution,
- checked trade retcodes,
- explicit transition-pending state around broker calls,
- owned-position count/lot/weighted-average/newest-position queries,
- owned-side close and owned-all close helpers.

The v1.63 host compile shown in MetaEditor on 2026-09-28 was **0 errors / 0 warnings**.

Remote MT5 startup evidence on 2026-09-28 showed the DEMO/HEDGING gate accepting Instance 2 / Magic 46102031 and logging `BROKER_ACTIONS_ARMED=1`.

## Important limitation of the 2026-09-28 remote run

2026-09-28 is Sunday in the user's local environment and the O01 logic does not permit new-cycle trading on weekends. In addition, the configured O01 session is restricted to its trading window (the current AUTO_GMT inputs correspond to the intended server-time session).

Therefore no broker entry/grid/exit event from this run is counted as demo execution parity evidence.

The following are still **pending** and must not be marked PASS yet:

1. actual DEMO initial entry with correct Instance/Symbol/Magic ownership,
2. simultaneous FULL and SPLIT same-symbol/different-Magic non-interference under broker positions,
3. grid-add ownership and lot progression,
4. single-position trailing close,
5. basket trailing close,
6. virtual-SL/emergency behavior where applicable,
7. route-change rejection while a real owned position/cycle exists,
8. restart/state behavior with owned broker positions,
9. event-level comparison against the Original O01 reference during an open market/session.

## Known DD interpretation constraint

O01's frozen DD behavior includes account-level Balance/Equity measurements. Two strategies on the same demo account can therefore influence account-level DD observations even when their positions are separated correctly by Symbol + Magic.

Do not rewrite the frozen O01 DD logic merely to simplify the comparison. Record DD parity separately and use a separately specified risk-scope contract if per-strategy DD is introduced later.

## Next implementation / validation gate

Before calling simultaneous DEMO operation ready:

1. preserve the frozen O01 decision path,
2. keep the NoOrders regression host intact,
3. strengthen execution diagnostics so every broker open/close can be tied to Instance ID, Symbol, Magic, side, ticket/order/deal and result,
4. run the two same-EA instances during an open market and valid O01 session,
5. verify that each instance sees/manages only its own Symbol + Magic positions,
6. verify grid and exit lifecycle behavior,
7. compare FULL and SPLIT event timing and results with the Original O01 reference,
8. document discrepancies before any optimization.

No optimization of O01 is authorized by this record.


## v1.68 NO_ORDERS regression checkpoint — VERIFIED

The v1.68 execution-gate host was tester-verified after the execution-adapter changes:

- host: `Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_DemoGate_v1_68.mq5`
- symbol/timeframe: XAUUSD_DUKA / M15
- period: 2026-08-16 through 2026-08-29
- model: real ticks
- initial deposit: 100,000
- leverage: 1:100
- execution: `NO_ORDERS`
- `BROKER_ACTIONS_ARMED=0`
- `VIRTUAL_NOT_FILL=1`

Verified final result:

- ticks 2,571,204
- bars 920
- entries 31
- grids 5
- closes 31
- single trailing 27
- basket trailing 4
- virtual SL 0
- buy open 0
- sell open 0

The tester reported `Test passed`. These values exactly match the frozen O01 aggregate NoOrders baseline.

Interpretation: the v1.68 execution-gate development changes preserved the frozen virtual/no-order O01 behavior on the common baseline. This does **not** establish DEMO broker-fill parity. Actual DEMO entry/grid/exit ownership and FULL-vs-SPLIT lifecycle evidence remain pending for an open market and valid O01 session.

### Next gate after v1.68

Continue with the pre-DEMO safety/diagnostic gate without changing the frozen O01 decision logic:

1. preserve `NO_ORDERS` as the regression path,
2. retain DEMO/HEDGING/positive InstanceId+Magic locks,
3. make broker lifecycle evidence attributable to InstanceId + Symbol + Magic + side + order/deal/position ticket + retcode,
4. verify route changes remain rejected while real owned positions/cycle/transition exist,
5. only then collect open-market/session DEMO evidence for Original O01 vs same-EA FULL/O01 vs same-EA SPLIT/O01+O01+O01.

No O01 optimization is authorized at this checkpoint.


## v1.69 NO_ORDERS regression checkpoint — VERIFIED

The v1.69 host was rerun on the frozen common O01 baseline after adding the v1.69 broker-state audit and lifecycle diagnostics.

Test conditions:

- host: `Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_DemoGate_v1_69.mq5`
- symbol/timeframe: XAUUSD_DUKA / M15
- period: 2026-08-16 through 2026-08-29
- model: real ticks
- initial deposit: JPY 100000
- leverage: 1:100
- Instance ID: 1
- Magic: 46102031
- execution: `NO_ORDERS`

Verified startup safety state:

- `EXEC_ADAPTER=1.69`
- `EXECUTION=NO_ORDERS`
- `BROKER_ACTIONS_ARMED=0`
- `VIRTUAL_NOT_FILL=1`

Verified final result:

- ticks 2,571,204
- bars 920
- entries 31
- grids 5
- closes 31
- single trailing 27
- basket trailing 4
- virtual SL 0
- buy open 0
- sell open 0
- tester: `Test passed`

These values exactly match the frozen O01 aggregate NoOrders baseline.

### Interpretation

v1.69 preserves the frozen O01 virtual/no-order decision path while adding execution-boundary diagnostics. This closes the v1.69 **NoOrders regression gate only**.

It does not close the DEMO broker-fill parity gate. DEMO evidence is still required during an open market and valid O01 session for:

1. Original O01 vs same-EA FULL/O01 vs same-EA SPLIT/O01+O01+O01 event timing,
2. initial broker entry ownership,
3. same-symbol/different-Magic isolation,
4. grid additions and lot progression,
5. single/basket trailing exits,
6. route-change rejection while real owned positions/cycles/transitions exist,
7. restart/state behavior with owned broker positions,
8. relevant safety/emergency behavior.

No O01 optimization is authorized by this checkpoint.


## DEMO evidence protocol prepared

The open-market validation procedure is now fixed in:

- `Test_Results/O01/O01_v1_69_DEMO_Validation_Protocol.md`

The protocol defines the three-chart identity map, startup prerequisites, required v1.69 log markers, and explicit PASS criteria for initial entry ownership, same-symbol/different-Magic isolation, grid lifecycle, exit lifecycle, route-change protection with real positions, restart/state observation, and Original-vs-FULL-vs-SPLIT event comparison.

This preparation does not change the v1.69 trading implementation and does not change the current DEMO gate status: **PENDING until actual open-market/session broker evidence is collected**.


## v1.70-v1.73 open-market DEMO validation update — VERIFIED 2026-09-28

Development continued through the quiet-diagnostic and broker-refresh-race fixes while preserving the frozen O01 decision path.

### v1.70-v1.71 diagnostics

- v1.70 reduced successful state-audit logging while retaining immediate failure/lifecycle diagnostics.
- v1.71 suppressed unconditional background chart-event noise and moved successful periodic audit display to approximately five-minute intervals.
- v1.71 compiled with 0 errors / 0 warnings and exactly preserved the frozen NO_ORDERS baseline.

### v1.72 FULL dispatch and close-confirmation fixes

v1.71 open-market evidence exposed two implementation defects outside the frozen O01 decision logic:

1. O01 Entry Dispatcher accepted O01 only when Structure=SPLIT, so FULL/O01 could not produce broker entries.
2. a successful synchronous broker close could be reported as REJECTED when the terminal position list had not refreshed immediately after TRADE_RETCODE_DONE.

v1.72 corrected the FULL/O01 dispatcher path without fallback and added a bounded terminal-refresh confirmation wait for closes.

Verified v1.72 checkpoints:

- compile: 0 errors / 0 warnings,
- NO_ORDERS regression: exact frozen baseline,
- FULL Instance 2 / Magic 46102031 produced real DEMO entries,
- SPLIT Instance 3 / Magic 46102032 produced real DEMO entries,
- same-symbol Magic ownership remained isolated,
- initial entry, grid addition and trailing/basket exits were observed.

### v1.73 broker OPEN refresh-race fix

v1.72 broker evidence then exposed an OPEN-side terminal-refresh race. A broker request could return TRADE_RETCODE_DONE while the local position list still temporarily showed before_count == after_count. The adapter therefore classified a real fill as REJECTED; because the host did not record the successful INITIAL bar, the same M1 bar could later permit an unintended GRID addition.

v1.73 changes only the common DEMO execution adapter confirmation boundary:

- after accepted broker OPEN retcode, confirm the owned Symbol + Magic + side position/lots transition,
- poll for at most about 500 ms (20 x 25 ms) before classifying the OPEN as failed,
- preserve ticket ownership checks,
- preserve DEMO/HEDGING/positive identity gates,
- do not change O01 Entry / Manage / Exit decisions.

Current files:

- Modules/Common/MultiAlpha_Demo_Execution_Adapter_v1_73.mqh
- Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_DemoGate_v1_73.mq5
- Entry Dispatcher remains MultiAlpha_Entry_Dispatcher_v1_72.mqh.

Verified v1.73 checkpoints:

- compile: **0 errors / 0 warnings**,
- NO_ORDERS regression: **exact frozen baseline PASS**,
- remote FULL: Instance 2 / Magic 46102031 / DEMO + HEDGING / broker actions armed,
- remote SPLIT: Instance 3 / Magic 46102032 / DEMO + HEDGING / broker actions armed,
- FULL and SPLIT OPEN lifecycle: CONFIRMED with correct Symbol + Magic ownership,
- GRID #2 and GRID #3: both routes followed the expected lot progression and retained isolated ownership,
- both routes reached three SELL positions / 0.06 total lots in the observed basket cycle,
- basket-trailing decision matched between FULL and SPLIT in the observed cycle,
- all owned positions closed with accepted broker retcodes and CONFIRMED lifecycle,
- post-cycle state audit returned owned=0 and transition_pending=0 for both instances,
- the v1.72 false OPEN-REJECT race was not reproduced in the observed v1.73 cycle.

### DEMO gate status after v1.73

Verified broker evidence now covers:

- Gate A — startup / identity: **PASS**
- Gate B — initial entry ownership: **PASS**
- Gate C — same-symbol / different-Magic isolation: **PASS**
- Gate D — grid lifecycle: **PASS**
- Gate E — observed trailing/basket exit lifecycle: **PASS**

Still pending and not to be inferred from the above:

- Gate F — controlled route-change rejection while a real owned DEMO position/cycle exists,
- Gate G — controlled restart/state observation while a real owned DEMO position exists,
- virtual-SL/emergency behavior when naturally reached,
- broader event-level Original-vs-FULL-vs-SPLIT observation across additional cycles.

The next controlled validation is Gate F. Do not alter the frozen O01 logic for this test. During one naturally occurring owned DEMO cycle, attempt one route APPLY on only one Multi Alpha instance. PASS requires rejection, unchanged active route, and no modification/closure of the owned broker position. After that position closes naturally, proceed separately to Gate G restart/state observation.
