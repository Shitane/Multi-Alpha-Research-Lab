# Multi Alpha Research Lab — Multi-Instance / Broker / Risk Architecture v1.00

**Established:** 2026-10-02  
**Status:** Governing extension to Builder-Only Architecture  
**UI baseline:** `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_45`  
**Target generation:** Builder-only v3.x

## 1. Architectural decision

The final Multi Alpha EA shall combine the Builder-only logic architecture with a multi-instance portfolio runtime.

One EA host manages up to **50 independent Strategy Instances (#01-#50)**. Each enabled instance can independently select:

- logical symbol,
- saved ENTRY Builder module,
- saved MANAGE Builder module,
- saved EXIT Builder module,
- Risk Profile / instance risk settings,
- unique runtime identity and Magic Number.

Conceptually:

```text
Expert Properties
  Environment / broker / portfolio safety only
                |
        Broker + Symbol Layer
                |
          Instance Manager
     #01 #02 #03 ... #50
                |
      +---------+---------+
      |         |         |
    ENTRY     MANAGE     EXIT
    Builder   Builder    Builder
      +---------+---------+
                |
           Risk Engine
                |
         Portfolio Guard
                |
           Safety Gate
                |
        Execution Adapter
```

Logic parameters such as RSI levels, MA periods, grid distance, TP/SL and trailing settings belong to Builder definitions/panel settings, not ordinary Expert Properties.

## 2. Expert Properties responsibility

Expert Properties shall remain intentionally small. They configure the environment and global safety boundary, not strategy logic.

Target categories:

### Execution / environment
- Execution Mode: NO_ORDERS / DEMO / separately approved LIVE
- Broker Profile: AUTO / known profile / CUSTOM
- Symbol Mapping Mode: AUTO / CUSTOM
- Magic Base
- maximum enabled instance count (hard ceiling 50)

### Portfolio safety
- Master Risk Mode
- Master/Portfolio Risk Budget
- Max Total DD
- Max Daily Loss
- Max Total Exposure or equivalent portfolio cap
- optional maximum simultaneously active instances

Exact risk semantics/units must be defined and validated before execution use. Defaults must fail safely.

Do not duplicate Builder logic parameters in Expert Properties.

## 3. Broker and symbol abstraction

Builder definitions must use a **Logical Symbol** and must not hard-code broker-specific names such as `XAUUSD-m`.

Example:

```text
Logical Symbol: XAUUSD
        |
   Symbol Resolver
        |
Titan FX Micro -> XAUUSD-m
Other broker   -> broker-specific mapped symbol
```

The Broker/Symbol layer must expose normalized symbol metadata to runtime, including where available:

- `SYMBOL_POINT`
- `SYMBOL_DIGITS`
- `SYMBOL_TRADE_TICK_SIZE`
- `SYMBOL_TRADE_TICK_VALUE` and relevant profit/loss variants
- `SYMBOL_VOLUME_MIN`
- `SYMBOL_VOLUME_MAX`
- `SYMBOL_VOLUME_STEP`
- `SYMBOL_TRADE_CONTRACT_SIZE`
- trading/session availability needed by validation.

Do not assume that two symbols named similarly have identical point value, contract size, tick value, volume rules, or trading characteristics.

AUTO mapping must be validated. Ambiguous/unavailable mappings fail closed and display a reason. CUSTOM mapping allows the user to explicitly map a logical symbol to the broker symbol.

## 4. Strategy Instance model (#01-#50)

A Strategy Instance is the isolation boundary for one independently configured route.

Conceptual data:

```text
StrategyInstance
  instance_id          #01 ... #50
  enabled
  logical_symbol
  resolved_broker_symbol
  entry_module_id
  manage_module_id
  exit_module_id
  risk_profile_id
  magic_number
  route_version
  runtime_state
  position/cycle state
  validation status/reason
```

Rules:

1. Maximum 50 configured instances.
2. Each instance may choose its own symbol.
3. Multiple instances may use the same symbol.
4. Multiple instances may use the same Builder module.
5. Each instance has isolated state and identity.
6. Position ownership must be determined by explicit identity (including Magic/instance/symbol as required), never by symbol alone.
7. One instance must not consume or modify another instance's cycle/trailing/cooldown state.
8. Disabling or changing a route while positions/cycles are active requires an explicit safe transition policy.
9. Invalid instances do not trade and do not silently fall back.

## 5. Instance Manager UI

Use v2.45 as the UI/reference baseline. Preserve its proven panel layout, tabs, Free Slot Builder, Parts Picker, Interpreter/Readout, filters/presets and stable Canvas lifecycle where compatible.

Evolve the SLOT workspace into the Instance Manager:

```text
MULTI ALPHA / INSTANCES

#01  ON   XAUUSD   ENTRY-01   MANAGE-03   EXIT-02   RISK-NORMAL
#02  ON   GBPUSD   ENTRY-04   MANAGE-01   EXIT-01   RISK-LOW
#03  OFF  USDJPY   ENTRY-02   MANAGE-01   EXIT-05   RISK-NORMAL
...
#50
```

Selecting an instance opens its details:

```text
INSTANCE #01
Logical Symbol : XAUUSD
Broker Symbol  : XAUUSD-m
ENTRY          : ENTRY-01
MANAGE         : MANAGE-03
EXIT           : EXIT-02
Risk Profile   : RISK-NORMAL
Magic          : derived/validated identity
Status         : VALID / INVALID reason
```

EA LOGIC edits Builder module definitions. EA PARTS edits the selected Builder part. INSTANCE/SLOT selects which saved modules and symbol are composed into a running strategy.

## 6. Risk architecture — two layers

Risk management shall have at least two independent layers.

### Layer A — Instance Risk

Controls risk attributable to one Strategy Instance/cycle.

Potential modes include:
- fixed lot (research/compatibility),
- equity/balance percentage,
- maximum cycle-risk budget,
- strategy-specific risk request interpreted by the common Risk Engine.

For grid/averaging/recovery strategies, initial-order risk alone is not sufficient. Where a bounded worst-case can be defined, the Risk Engine should consider the configured position progression, maximum positions/lots, distance model and stop/exit boundary to estimate or bound **whole-cycle risk**.

If a strategy has no bounded loss under its configuration, the system must not label its risk as a guaranteed fixed percentage. It must expose the limitation and use explicit caps/guards.

### Layer B — Portfolio Risk

Before accepting a new risk-increasing action, Portfolio Guard evaluates account-wide Multi Alpha exposure.

Target controls:
- total risk budget,
- total DD emergency boundary,
- daily loss boundary,
- maximum aggregate exposure,
- maximum active instances,
- per-symbol exposure cap,
- later, currency/correlation/concentration controls where useful.

A locally valid ENTRY or ADD POSITION may therefore be blocked by Portfolio Guard.

## 7. Risk sizing

Risk Engine must use broker-resolved symbol specifications rather than assuming a universal lot value.

Conceptually:

```text
Account equity/balance
      + risk budget
      + loss/stop model
      + symbol tick/contract/volume specification
      + current portfolio exposure
                |
            Risk Engine
                |
        normalized allowed lot
```

Lot output must respect broker min/max/step and be validated after normalization.

Risk calculations require dedicated numerical tests across symbols/broker profiles before they are trusted for execution.

## 8. Runtime scheduling for 50 instances

Do not require 50 separate chart-attached EAs.

The target is one host managing up to 50 Strategy Instances. Runtime must therefore not depend only on the chart symbol's `OnTick()`.

The multi-symbol runtime requires a scheduler/context update mechanism capable of reading each enabled resolved symbol. Candidate implementation is timer-driven polling plus symbol-specific tick/time change detection, with performance measurement before finalizing cadence.

Requirements:
- enable/select required symbols,
- maintain per-symbol market snapshots,
- evaluate only valid/enabled instances,
- isolate per-instance state,
- avoid duplicate evaluation of the same market event where strategy semantics require once-per-tick/bar behavior,
- record latency/throughput diagnostics,
- fail safely if symbol data is stale/unavailable.

The exact scheduler design is an implementation decision to be proven by tests; it must not be assumed from the single-chart v2.45 loop.

## 9. Development procedure

### M0 — Freeze v2.45 UI baseline
- Preserve `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_45` unchanged.
- Record it as the UI/parts baseline for v3 reconstruction.
- New Builder-only work goes into new versioned files.

**Gate:** baseline file/commit identified; no regression edits to v2.45.

### M1 — Environment Configuration schema
Create data structures for:
- execution mode,
- broker profile,
- symbol mapping mode,
- Magic Base,
- portfolio safety settings.

Keep Expert Properties mapped only to this environment layer.

**Gate:** defaults + validation + invalid-setting fail-closed tests.

### M2 — Symbol Specification + Resolver
Implement:
- LogicalSymbol,
- BrokerSymbol,
- SymbolSpec snapshot,
- AUTO resolver,
- CUSTOM mapping,
- validation/reason codes.

First verification cases must include broker suffix/prefix handling such as logical `XAUUSD` -> broker `XAUUSD-m`, without hard-coding that mapping into Builder logic.

**Gate:** resolver unit tests + actual MT5 symbol-spec read-only gate.

### M3 — Strategy Instance schema
Implement `StrategyInstance[50]` with:
- ID,
- enabled state,
- logical/resolved symbol,
- ENTRY/MANAGE/EXIT IDs,
- Risk Profile,
- Magic,
- isolated runtime state.

**Gate:** 50-instance construction/validation test; duplicate symbol allowed; duplicate identity rejected.

### M4 — Generic Builder Core
Implement/freeze Builder-only:
- module definition/schema,
- Part Registry,
- ENTRY evaluator,
- MANAGE evaluator,
- EXIT evaluator,
- validation,
- no O01/A10 runtime dependency.

**Gate:** generic evaluator tests under NO_ORDERS.

### M5 — Route Composer per Instance
Each instance independently selects saved ENTRY/MANAGE/EXIT definitions.

**Gate:** cross-combination, wrong-role, missing-part/version, incompatible-state and no-fallback tests.

### M6 — Multi-Symbol Context Provider
Create symbol and instance snapshots independent of chart symbol.

Include:
- tick/time,
- indicator data,
- spread/session,
- position/cycle state,
- freshness status.

**Gate:** read-only multi-symbol test with several simultaneous symbols; stale/unavailable data rejection.

### M7 — Multi-Instance Scheduler
Implement and measure the mechanism that evaluates enabled instances.

Start NO_ORDERS.

**Gate:** #01-#50 simulation/stress test; state isolation; no duplicate event processing; performance diagnostics.

### M8 — Risk Engine v1
Implement:
- broker-aware lot normalization,
- fixed-lot compatibility,
- percentage risk mode for bounded-loss cases,
- cycle-risk budget interface,
- explicit unbounded-risk status.

**Gate:** numerical test vectors for multiple symbol specifications and volume steps.

### M9 — Portfolio Guard v1
Implement:
- portfolio risk budget,
- DD boundary,
- daily-loss boundary,
- aggregate/per-symbol caps,
- maximum active instances.

**Gate:** deterministic allow/block scenarios including simultaneous risk requests.

### M10 — v2.45 -> v3 UI reconstruction
Create a new Builder-only v3 host using v2.45 as visual/interaction baseline.

- preserve left LOGIC/FILTER/PRESET where applicable,
- preserve right EA LOGIC / EA PARTS,
- replace old SLOT/ROUTE strategy-specific selection with Instance Manager,
- show #01-#50,
- show logical + resolved broker symbol,
- select saved ENTRY/MANAGE/EXIT,
- select Risk Profile,
- show VALID/INVALID reason.

**Gate:** UI-only state tests; no trading-decision side effects.

### M11 — SAVE/LOAD libraries
Persist/version:
- Builder modules,
- routes,
- Risk Profiles,
- Instance configurations,
- symbol mappings where appropriate.

**Gate:** save/load round-trip and version compatibility tests.

### M12 — Legacy migration/parity
Migrate references in order:

```text
O01 -> A10 -> A11 -> A12 -> A13 -> A14 -> A15
```

For each, reconstruct Builder modules using generic parts, run parity/regression/forward evidence, then mark dedicated runtime path eligible for retirement.

**Gate:** evidence-backed equivalence, not profit similarity.

### M13 — Builder-only Strategy Tester / demo
Run exact saved definitions and instance configurations through common runtime.

**Gate:** backtest + demo/forward evidence, multi-instance state isolation, symbol-resolution evidence, Risk/Portfolio Guard evidence.

### M14 — Retire strategy-specific active runtime
Remove O01/A10-A15 from normal runtime dependency/selection while preserving Legacy Reference source/evidence.

**Gate:** dependency audit + Builder-only regression.

### M15 — Execution host
Only after NO_ORDERS architecture is verified, create a separately approved execution adapter/host.

**Gate:** demo execution first; risk and ownership audits mandatory.

## 10. Development priority from this decision

Do not continue deepening the O01-specific Live Market Gate as the central path.

Immediate order is:

```text
M0 v2.45 freeze
 -> M1 Environment
 -> M2 Symbol Resolver
 -> M3 Instance[50]
 -> M4 Generic Builder Core
 -> M5 Route Composer
 -> M6 Multi-Symbol Context
 -> M7 Scheduler
 -> M8 Risk Engine
 -> M9 Portfolio Guard
 -> M10 v3 Panel reconstruction
 -> ...
```

UI prototypes may be developed in parallel, but runtime dependencies must follow these boundaries.

## 11. Non-negotiable rules

1. v2.45 is preserved as the UI/parts reconstruction baseline.
2. Final active runtime is Builder-only.
3. Logic values live in Builder/panel definitions; Expert Properties focus on environment/global safety.
4. Maximum configured Strategy Instances is 50.
5. Every instance can independently choose a symbol and ENTRY/MANAGE/EXIT modules.
6. Broker-specific symbol names never become hard-coded Builder logic.
7. Position/state ownership is instance-isolated.
8. Risk is checked at both Instance and Portfolio layers.
9. Risk percentages are not claimed as fixed/guaranteed where loss is unbounded.
10. Multi-symbol scheduling must be tested rather than assumed from chart `OnTick`.
11. Invalid/stale/unmapped/incompatible configurations fail closed.
12. No silent fallback.
13. Builder evaluators do not send orders.
14. Research/parity remains NO_ORDERS / VIRTUAL_NOT_FILL.
15. Execution is a separate, later-approved boundary.
16. PASS requires actual evidence.
17. GitHub remains the durable source of truth.
