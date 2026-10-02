# Multi Alpha Research Lab — Builder-Only Architecture Policy v1.00

**Established:** 2026-10-02  
**Status:** PRIMARY ARCHITECTURE DECISION  
**Applies to:** final Multi Alpha EA architecture and all future central development

## 1. Final product concept

The final Multi Alpha EA is a **Builder-only modular trading engine**.

The user creates a strategy by independently building, saving, selecting, and replacing three roles:

```text
ENTRY MODULE
     +
MANAGE MODULE
     +
EXIT MODULE
     =
ONE STRATEGY / ROUTE
```

The three roles are first-class independent modules. A change to ENTRY must not require rewriting MANAGE or EXIT. A MANAGE module must be reusable with different ENTRY and EXIT modules, subject to explicit compatibility validation.

The active runtime shall ultimately execute **Builder definitions only**. It shall not require dedicated O01, A10, A11, A12, A13, A14, or A15 strategy engines.

## 2. O01 / A10-A15 retirement policy

O01 and A10-A15 are now classified as **Legacy Reference / Migration Oracles**.

They remain in GitHub during migration because they provide known behavior for:
- decomposition into generic reusable parts,
- reference-vs-Builder parity,
- regression tests,
- backtest comparison,
- demo/forward comparison.

They are **not** permanent selectable production modules.

Target repository/runtime separation:

```text
ACTIVE BUILDER RUNTIME
  Part Registry
  Builder Definition / Schema
  ENTRY Evaluator
  MANAGE Evaluator
  EXIT Evaluator
  Route Composer
  Validation
  Save / Load
  Backtest / Forward / Execution adapters

LEGACY / REFERENCE TEST ENVIRONMENT
  O01
  A10
  A11
  A12
  A13
  A14
  A15
  frozen parity evidence
```

Do not delete historical source or evidence. Retirement means removal from the **active runtime dependency and normal user selection path**, not destruction of the reference record.

## 3. Builder-only module model

### ENTRY

An ENTRY definition evaluates market/state conditions and emits an intent such as:
- NONE
- BUY
- SELL
- where later required, explicitly typed multi-entry intents.

Example:

```text
RSI(8) < 30
AND
TIME in session
AND
SPREAD <= limit
=> BUY
```

### MANAGE

A MANAGE definition operates only on typed position/cycle state and emits management intent such as:
- NONE
- ADD POSITION
- LOT progression
- grid/averaging action
- recovery action
- stop adding
- management-state transition.

Example:

```text
POSITION_COUNT > 0
AND
DISTANCE_FROM_LAST_ENTRY >= 300 points
=> ADD POSITION
LOT = previous lot * 1.5
```

### EXIT

An EXIT definition evaluates position/cycle/market state and emits exit-management intent such as:
- NONE
- CLOSE
- CLOSE ALL
- fixed TP/SL
- virtual SL
- trailing
- basket trailing
- time/signal exit.

ENTRY, MANAGE, and EXIT must not call broker APIs directly. They produce typed decisions. Execution is a separate adapter.

## 4. Generic Part Registry

All Builder modules are composed from reusable parts.

Required part families:

1. **Indicator**
   - RSI
   - MA
   - ATR
   - Bollinger Bands
   - MACD
   - ADX
   - future indicators through the same interface

2. **Price / Market**
   - current bid/ask/price
   - high/low
   - breakout
   - candle/bar state
   - price distance
   - volatility
   - time/session/day
   - spread
   - news/filter state

3. **Position / Cycle**
   - position count by side
   - average price
   - last-entry price
   - distance from entry/average
   - lot / total lot
   - floating/basket P/L
   - holding time
   - cycle state
   - cooldown
   - trailing state

4. **Logic / Composition**
   - AND
   - OR
   - explicit groups/precedence
   - NOT only when required

5. **Actions**
   - BUY / SELL intent
   - ADD POSITION intent
   - lot calculation/progression
   - TP / SL / virtual SL
   - trailing / basket trailing
   - CLOSE / CLOSE ALL
   - management state transitions

Do not add strategy-specific parts such as `O01_RSI`, `A10_ENTRY_SPECIAL`, or `A15_EXIT_ONLY` unless a documented review proves that the behavior cannot be expressed generically.

## 5. Definition is the source of truth

The Builder UI is an editor, not the runtime state database.

A module is stored as versioned structured data:

```text
BuilderModuleDefinition
  schema_version
  module_id
  name
  version
  role = ENTRY | MANAGE | EXIT
  groups[]
    operator
    slots[]
      part_id
      part_version
      parameters
      enabled
  output/action
  compatibility requirements
```

A route is also data:

```text
BuilderRouteDefinition
  route_id
  version
  entry_module_id
  manage_module_id
  exit_module_id
  compatibility/schema version
```

The same saved definition must be consumed by parity tests, Strategy Tester, optimization mapping, demo/forward, and later approved execution. No separate reimplementation is allowed for each environment.

## 6. Free interchangeability and compatibility

The normal workflow is:

```text
ENTRY  = choose any valid saved ENTRY module
MANAGE = choose any valid saved MANAGE module
EXIT   = choose any valid saved EXIT module
          |
          v
      VALIDATE
          |
          v
       RUNTIME
```

Interchangeability is free **only after validation**. The validator must fail closed when a selected module requires state/capabilities not provided by the route/runtime.

There is no silent fallback to O01, A10, a default module, or another Builder definition.

## 7. Runtime boundary

Final runtime pipeline:

```text
MT5 MARKET / INDICATOR / POSITION SNAPSHOT
                 |
          CONTEXT PROVIDER
                 |
        +--------+--------+
        |        |        |
      ENTRY    MANAGE    EXIT
      Builder  Builder   Builder
        |        |        |
        +--------+--------+
                 |
          DECISION FRAME
                 |
          SAFETY / RISK GATE
                 |
          EXECUTION ADAPTER
```

Builder evaluators are deterministic decision engines. Broker actions exist only below the safety/execution boundary.

## 8. Development procedure

### Phase B0 — Freeze the architecture decision
- This document is the primary architectural policy.
- Existing Builder work is retained as migration/proof infrastructure.
- Do not extend the old strategy-specific runtime as the final architecture.

**Gate:** policy recorded in GitHub.

### Phase B1 — Builder Core v1
Implement/freeze:
- generic module schema,
- route schema,
- typed roles,
- generic Part Registry,
- parameter representation,
- validation result/reason model,
- serialization identity/version rules.

**Gate:** schema/registry compile tests + invalid-definition fail-closed tests.

### Phase B2 — Three independent Builder evaluators
Create generic:
- ENTRY evaluator,
- MANAGE evaluator,
- EXIT evaluator.

Remove evaluator dependence on O01/A10-specific classes. Existing O01 Builder evaluators may be used to prove semantics during migration but are not the final evaluator API.

**Gate:** independent evaluator unit tests under NO_ORDERS.

### Phase B3 — Route Composer
Implement selection of any saved:
- ENTRY definition,
- MANAGE definition,
- EXIT definition.

Add compatibility validation and explicit reasons for INVALID / NOT REGISTERED.

**Gate:** cross-combination tests, wrong-role tests, missing-part/version tests, no-fallback tests.

### Phase B4 — Context Provider
Create one typed snapshot layer for:
- tick/bid/ask,
- indicator values,
- time/session,
- spread/filter/news state,
- virtual/actual position state,
- cycle/trailing state.

All three Builder evaluators consume this controlled context instead of reading broker/platform state ad hoc.

**Gate:** deterministic snapshot tests + live MT5 read-only input tests.

### Phase B5 — SAVE / LOAD / Library
Implement persistent named ENTRY/MANAGE/EXIT definitions and route definitions.

Required operations:
- NEW
- VALIDATE
- SAVE AS
- LOAD
- CLONE
- VERSION
- DELETE only with explicit confirmation in UI
- route composition from saved modules.

**Gate:** save-load round-trip reproduces byte/semantic-equivalent definitions and decisions.

### Phase B6 — Builder UI
Final user-facing workspaces:

```text
EA LOGIC
  ENTRY Builder
  MANAGE Builder
  EXIT Builder

EA PARTS
  Part selection + parameters

ROUTE
  ENTRY  [saved module]
  MANAGE [saved module]
  EXIT   [saved module]
  [VALIDATE] [SAVE ROUTE] [LOAD ROUTE]
```

The UI must support empty ordered slots, AND/OR groups, parameter editing, validation status, and clear module identity/version.

**Gate:** UI changes definition data correctly and do not alter runtime decisions independently.

### Phase B7 — Reference migration: O01 then A10-A15
Use the legacy references only as migration oracles, in this order:

```text
O01 -> A10 -> A11 -> A12 -> A13 -> A14 -> A15
```

For each reference:
1. decompose ENTRY/MANAGE/EXIT,
2. identify missing generic parts,
3. add generic parts only,
4. reconstruct three Builder definitions,
5. compose a Builder route,
6. run event-level reference parity,
7. run backtest/regression as required,
8. run demo/forward evidence as required,
9. freeze/version the Builder definitions,
10. mark the strategy-specific runtime path eligible for retirement.

**Gate per reference:** evidence-backed Builder equivalence; never profit-only similarity.

### Phase B8 — Active-runtime retirement
After required references have migrated:
- remove O01/A10-A15 from normal active runtime selection,
- remove active runtime compile dependencies on their strategy engines,
- keep frozen source/evidence in Legacy/Reference/Test locations,
- make Builder Route the sole normal strategy path.

**Gate:** clean dependency audit + Builder-only regression/backtest/demo test.

### Phase B9 — Builder-only execution host
Only after Builder-only NO_ORDERS/runtime validation is complete:
- create a separately approved execution host,
- keep decision engine and execution adapter separated,
- add risk/safety gates,
- validate on demo before any real-account consideration.

No broker execution is introduced into parity/research hosts.

### Phase B10 — New Alpha research
Create new strategies exclusively by:
- new generic reusable parts where necessary,
- new ENTRY/MANAGE/EXIT Builder definitions,
- new route combinations.

Do not create new A16/A17-style hard-coded strategy engines as the normal development path.

## 9. Migration rule for current O01 Builder work

The already verified O01 Builder gates remain valuable:
- ENTRY parity,
- MANAGE parity,
- EXIT parity,
- FULL controlled integration,
- Module Registry,
- Runtime Route recognition,
- Runtime Tick Adapter.

They prove semantics and integration concepts, but `BUILDER_E01/M01/X01` are treated as **migration definitions**, not the permanent architecture.

Before extending O01 live-market integration further, prioritize B1-B4 so the next market/runtime work targets the generic Builder-only core rather than deepening an O01-specific runtime dependency.

## 10. Non-negotiable rules

1. Final active runtime is Builder-only.
2. ENTRY / MANAGE / EXIT are independently buildable, saveable, selectable, and replaceable.
3. O01/A10-A15 are migration references, not permanent active engines.
4. Historical reference source/evidence is preserved.
5. Parts are generic and parameterized.
6. Definitions, not UI objects, are the source of truth.
7. Invalid/incompatible routes fail closed with a reason.
8. No silent fallback.
9. Same definition/runtime path for test/backtest/forward/execution.
10. Builder evaluators never send broker orders directly.
11. Research/parity remains NO_ORDERS / VIRTUAL_NOT_FILL.
12. PASS requires actual compile/runtime/parity evidence.
13. GitHub is the durable source of truth.
14. New strategy research should normally be data/definitions, not new hard-coded strategy engines.

## 11. Definition of project completion

The architecture objective is reached when a user can:

1. open the Builder,
2. construct or load an ENTRY module,
3. construct or load a MANAGE module,
4. construct or load an EXIT module,
5. combine any compatible three modules,
6. validate the route,
7. save/version it,
8. run the exact same definitions in Strategy Tester and demo/forward,
9. change only one role without rewriting the other two,
10. create a strategy that has no O01/A10-A15 hard-coded implementation behind it.

That is the target Multi Alpha EA.


---

## 12. Governing extension — Multi-Instance / Broker / Risk Architecture (2026-10-02)

The Builder-only final architecture is extended by:

`Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`

This extension fixes the following requirements:

- `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_45` is frozen as the UI/parts reconstruction baseline for the v3 Builder-only generation.
- One host shall support up to **50 independent Strategy Instances (#01-#50)**.
- Every instance may independently choose a logical symbol plus saved ENTRY / MANAGE / EXIT Builder modules.
- Builder logic uses logical symbols; a Broker/Symbol Resolver maps them to actual broker symbols such as `XAUUSD-m`.
- Expert Properties are kept primarily for environment/broker/global portfolio-safety configuration; strategy logic values belong to Builder/panel definitions.
- Risk management is split into **Instance Risk** and **Portfolio Risk / Portfolio Guard**.
- Broker-aware lot/risk calculations use actual symbol specifications and volume rules.
- Multi-symbol operation must use a tested scheduler/context architecture rather than assuming the chart symbol's `OnTick()` can drive all instances.
- O01/A10-A15 remain Legacy Reference/Migration Oracles and are not permanent active runtime engines.

The implementation sequence M0-M15 in the extension document is the governing development order for this architecture. Where earlier immediate-work wording conflicts with that sequence, the M0-M15 sequence governs.


---

## 13. Current execution priority — O01 Builder end-to-end demo (2026-10-02)

The M0-M15 sequence referenced by the Multi-Instance / Broker / Risk extension is an architectural guide and gate map, **not a mandatory waterfall schedule**.

The current highest-priority implementation objective is to complete the general-purpose LOGIC BUILDER for O01 end-to-end:

```text
ENTRY BUILDER -> saved O01 ENTRY definition
MANAGE BUILDER -> saved O01 MANAGE definition
EXIT BUILDER  -> saved O01 EXIT definition
                    |
                    v
             O01 Builder Route
                    |
             NO_ORDERS validation
                    |
        Strategy Tester / market context
                    |
             single-instance DEMO
                    |
       Reference vs Builder forward evidence
```

Implement only the portions of Broker/Symbol, Context, Risk, Instance or other infrastructure needed to safely reach this milestone; broader #01-#50 and portfolio completion may follow. All such work must remain compatible with the final Builder-only multi-instance architecture.

Detailed current-milestone steps and completion criteria are recorded in `Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`, section 12.


## 14. Fixed Builder UI interaction rule (2026-10-02)

The Builder UI shall use a single simple role-scoped workflow based on the v2.45 Free-Slot Builder:

- ENTRY BUILDER selected -> EA PARTS shows/configures ENTRY parts.
- MANAGE BUILDER selected -> EA PARTS shows/configures MANAGE parts.
- EXIT BUILDER selected -> EA PARTS shows/configures EXIT parts.

ENTRY/MANAGE/EXIT definitions retain independent state while sharing the generic Free-Slot Builder/Parts Picker implementation. The v2.45 `+`/`-` variable-slot mechanism and `UP`/`DOWN` slot scrolling are retained. EA PARTS must not require a second normal role selector or present an unnecessarily mixed all-role catalog.

Detailed behavior is fixed in `Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`, section 13.


### 14.1 Fixed slot paging

For the current Builder generation, each of ENTRY / MANAGE / EXIT has a standard capacity of **24 logical slots**, displayed as **8 slots x 3 pages**: 01-08, 09-16, 17-24. `UP` / `DOWN` switch pages. The new Builder generation does not use the v2.45 `+` / `-` one-slot capacity adjustment as its normal workflow; unused slots are EMPTY.

24 is the standard/default UI capacity, not a permanent architectural ceiling. Internal definitions/evaluators must remain extensible to additional 8-slot pages if real evidence later requires them. Detailed rules are in `Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`, sections 13.7-13.8.


### 14.2 SAVE scopes: 24-role and 72-complete

Persistence must support both independent role-module saves and complete strategy saves:

- SAVE/LOAD current role = 24 slots (ENTRY or MANAGE or EXIT).
- SAVE/LOAD ALL = ENTRY 24 + MANAGE 24 + EXIT 24 = 72 slots as one composed strategy package.

The 72-slot package preserves all three role boundaries and does not replace the ability to save/load and swap each 24-slot role independently. Detailed rules are in `Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`, section 13.9.
