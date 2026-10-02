# Multi Alpha Research Lab — Development Policy v1.00

## 1. Foundation completion standard for A10-A15

A10, A11, A12, A13, A14, and A15 are the foundation/reference set.

Each Alpha is considered foundation-complete only after this sequence is completed and verified:

1. Original EA preservation and source-faithful NoOrders reproduction
2. Combined Entry+Exit module extraction
3. Combined-module parity PASS
4. Entry Module / Exit Module separation
5. Recombined Entry+Exit parity PASS against the verified combined module/original baseline
6. MultiAlpha Core integration
7. Core regression PASS

Existing verified files are frozen references. Do not rewrite a verified combined module merely to create the separated form; add new versioned Entry/Exit modules and parity tests.

Parity must preserve strategy decisions and lifecycle behavior, including signal direction, timing, executable bid/ask where applicable, entry/exit price, exit reason, state transitions, cooldown/hold behavior, and relevant counters.

## 2. Safety

Research, Core, reproduction, and parity code remains NoOrders.

Do not add OrderSend, OrderCheck, CTrade execution, or real broker orders to NoOrders code unless a separate execution version is explicitly approved.

## 3. Two parallel development tracks after/during foundation work

### Track A — Public EA intake

Continue searching for useful public EAs without imposing a fixed count limit.

Candidates are not restricted to XAUUSD. Other FX pairs and instruments may be evaluated, with suitable historical/tick data prepared when required.

Prefer candidates whose source code is available and whose logic can be inspected and reproduced. Intake should preserve the original first, establish NoOrders parity, then modularize before optimization.

A public EA can contribute more than a whole strategy: its Entry, Exit, position-management, recovery, trailing, or risk logic may become independently testable research components.

### Track B — Original strategy research

Develop original logic in parallel with public-EA intake.

The architecture should support composition of:

- Entry Signal Module
- Position Manager
- Exit Module / Exit Manager
- Risk Manager

Research examples include grid/averaging, recovery, trailing, basket TP/SL, lot control, and other management logic.

The framework should also support one initial signal creating multiple virtual positions, with different exit logic assigned to each position. Example: five simultaneous initial positions with fixed TP/SL, trailing, signal exit, time exit, and runner exit.

These are new research strategies and must not overwrite or be mislabeled as the original A10-A15 strategies.

## 4. Composition research

After components are verified independently, combinations may be tested, for example:

- A12 Entry + A15 Exit
- A13 Entry + original trailing
- Public-EA Entry + original Recovery
- One Entry + multiple independent Exit modules

Every new composition gets its own identity/version and regression record. A successful combination does not change the frozen parity status of its source modules.

## 5. Immediate order of work

Complete the A10-A15 foundation in this order:

A10 -> A11 -> A12 -> A13 -> A14 -> A15

For each, fill only the missing stages in the foundation completion standard and preserve already-verified reference code.

A14 still requires source-faithful reproduction before later stages.

Only actual compile/backtest/parity evidence may be recorded as PASS.


---

## 6. Central development direction — Logic Builder (2026-10-02)

From this point forward, the central development objective of Multi Alpha Research Lab is to build an **EA Logic Builder** that can reproduce, compose, test, and save trading logic from reusable panel-based parts.

### Primary objective

The existing verified/reference logic set:

- O01
- A10
- A11
- A12
- A13
- A14
- A15

shall be used as the reference curriculum for the Logic Builder.

The Builder is not considered successful merely because indicator controls can be placed on a panel. Its first major goal is:

> Reproduce existing O01 / A10-A15 logic from reusable Builder parts, then demonstrate parity against the frozen/reference implementation under identical test conditions.

### Preserve the current architecture

The current architecture remains valid and must not be discarded:

- FULL strategy verification
- independently selectable ENTRY
- independently selectable MANAGE
- independently selectable EXIT
- Module Registry
- Strategy Instance isolation
- NO_ORDERS / VIRTUAL_NOT_FILL research safety
- frozen parity/reference implementations

The Logic Builder is an additional construction layer that feeds this architecture.

Conceptually:

```text
Reusable Logic Parts
        |
   Logic Builder
        |
 +------+------+------+
 | ENTRY|MANAGE| EXIT |
 +------+------+------+
        |
 Module Registry / Router
        |
 FULL or SPLIT research
        |
 Parity / Backtest / Forward validation
```

### Builder parts

The Builder should grow from reusable typed parts rather than strategy-specific hard-coded screens.

Initial categories:

1. Indicator conditions
   - RSI
   - Moving Average
   - ATR
   - Bollinger Bands
   - later MACD / ADX / other indicators

2. Market/price conditions
   - price distance
   - breakout
   - high/low
   - candle/bar conditions
   - time/session
   - spread/news/filter state

3. Position/cycle state
   - position count
   - average price
   - floating/basket P/L
   - holding time
   - cycle state

4. Actions
   - BUY / SELL signal
   - add position / averaging / grid
   - lot progression
   - TP / SL
   - trailing
   - basket trailing
   - close / exit

5. Logic composition
   - AND
   - OR
   - NOT where required
   - grouped conditions so precedence is explicit and reproducible

### Development method

Do **not** attempt to create a universal Builder all at once.

Develop it by reproducing known strategies:

1. Select one frozen/reference strategy or role.
2. Decompose its ENTRY / MANAGE / EXIT behavior into required parts.
3. Implement only the missing generic Builder parts.
4. Reconstruct the logic in the Builder.
5. Save the Builder definition as a versioned configuration.
6. Run Original/Reference vs Builder under identical data/settings.
7. Compare event-level behavior.
8. Declare Builder parity only after evidence passes.
9. Freeze the verified Builder representation before extending the part library.

As O01 and A10-A15 are reproduced, the reusable part library should expand naturally.

### Parity requirements

Builder reproduction must be compared with the frozen/reference implementation for relevant items including:

- entry time
- entry direction
- executable/reference price as applicable
- initial lot
- additional/grid positions
- position count/state
- management transitions
- exit time
- exit reason
- trailing/basket behavior
- P/L and DD where meaningful
- final cycle/open-position state

Aggregate profit similarity alone is not parity.

### Builder-generated modules

A saved Builder definition should eventually be registerable like any other module, for example:

```text
ENTRY  = BUILDER_E01
MANAGE = BUILDER_M01
EXIT   = BUILDER_X01
```

or as a complete Builder strategy where appropriate.

Builder modules and code-defined modules must be able to coexist. Existing O01/A10-A15 implementations remain frozen references and must not be replaced merely because a Builder version exists.

### Research after reproduction

Only after the Builder can faithfully reproduce reference logic should it become the main tool for creating new combinations and new Alpha research, for example:

```text
A10-like Builder Entry
+ custom ATR condition
+ A12-like Builder Manage
+ custom trailing Exit
```

New Builder combinations are research strategies. They must receive their own identity/version and must never be labeled as parity-equivalent to O01/A10-A15 unless parity was actually established.

### UI direction

Provide a dedicated **LOGIC BUILDER** workspace/page rather than crowding the existing LOGIC/FILTER/PRESET pages.

Target interaction:

```text
LOGIC BUILDER

Logic Name: [................]

GROUP A
  SLOT 01 [RSI.............] [settings]
  AND
  SLOT 02 [MA..............] [settings]

OR

GROUP B
  SLOT 03 [ATR.............] [settings]
  AND
  SLOT 04 [BREAKOUT........] [settings]

Role: [ENTRY / MANAGE / EXIT]

[VALIDATE] [SAVE] [LOAD] [REGISTER]
```

Empty slots must have explicit type/role validation. Invalid combinations must fail safely and must not silently fall back to another module.

### Backtest and optimization

A Builder definition must be serializable so the same exact logic/configuration can be used for:

- parity test
- backtest
- Strategy Tester optimization where explicitly mapped
- demo forward test
- later live execution

Do not create a separate reimplementation for backtesting.

### Safety and non-regression

Logic Builder development must preserve these rules:

1. Current stable runtime/panel baseline is not rewritten merely to add Builder features.
2. Research/parity Builder hosts remain NO_ORDERS unless a separately approved execution host is created.
3. Frozen O01/A10-A15 reference logic is not modified to make Builder parity easier.
4. Existing FULL/SPLIT module selection remains usable.
5. Existing Module Registry remains the integration boundary.
6. Compile PASS requires actual 0-error evidence; parity PASS requires actual test evidence.
7. UI work must not change trading decisions.
8. A Builder definition that fails validation must not trade or fall back silently.

### Immediate Builder milestone

The first Builder milestone is deliberately small.

### Fixed reproduction order (policy decision — 2026-10-02)

The Builder reproduction order is fixed as:

```text
O01 -> A10 -> A11 -> A12 -> A13 -> A14 -> A15
```

**O01 is the mandatory first target.** Do not advance the main Builder reproduction track to A10 until O01 has been reconstructed with Builder parts, parity-tested against the O01 reference, and operated successfully on a demo account with recorded evidence.

After O01 is completed, proceed sequentially through A10, A11, A12, A13, A14, and A15. Do not reorder or skip a target for ordinary implementation convenience. A change to this sequence requires an explicit development-policy decision recorded in GitHub before implementation.

For each target, the completion gate is: Builder reconstruction -> validation -> reference parity evidence -> demo/forward evidence where applicable -> freeze the verified Builder definition -> proceed to the next target.

### LB-01 — O01 Builder completion

LB-01 is specifically the O01 milestone, not "O01 or A10".

- Builder data model / schema
- dedicated Builder panel shell
- empty ordered slots
- part registry
- RSI part
- MA part
- ATR part
- position/cycle-state part needed by the first reproduction
- BUY/SELL or role-output part
- AND/OR grouping
- SAVE/LOAD of a named Builder definition
- registration as a research module
- O01 reference path reconstructed and parity-tested
- O01 Builder definition registered through the existing module architecture
- O01 Builder operated on a demo account and compared with the O01 reference using recorded forward evidence

Only after the O01 Builder completion gate is satisfied may the central reproduction track proceed to A10. After that, expand the part library only as required for A10 -> A11 -> A12 -> A13 -> A14 -> A15.

### Direction-change rule

Do not replace this Logic Builder-centered roadmap with a different primary development direction during ordinary implementation.

If a new idea appears, classify it as one of:

- required for Builder reproduction,
- supporting infrastructure,
- optional future research.

A change to the primary objective should be made only by an explicit development-policy decision and recorded in GitHub before implementation.



### End-state migration policy — Builder replaces strategy-specific implementations (2026-10-02)

O01 and A10-A15 are retained during development as **reference/oracle implementations for comparison, parity, regression, and forward validation**. They are not intended to remain permanent runtime dependencies.

The intended end state is:

```text
DEVELOPMENT
O01 / A10 / A11 / A12 / A13 / A14 / A15 reference code
                         |
                         v
                  LOGIC BUILDER
                         |
                  parity / validation
                         |
                         v
FINAL RUNTIME
LOGIC BUILDER + generic reusable parts + saved Builder definitions
```

After a reference strategy has been fully reconstructed and verified through the required parity/forward gates, its behavior shall be representable by a saved/versioned Builder definition using generic reusable parts.

The long-term objective is to retire strategy-specific O01/A10-A15 runtime implementations from the production/runtime architecture. The names O01, A10, etc. may remain as historical/reference identities or saved Builder-definition names, but their logic must not require dedicated O01/A10-A15 hard-coded runtime modules.

Rules:

1. Do not delete or modify frozen reference implementations during the reproduction phase.
2. Reference modules remain available until the corresponding Builder reproduction has passed the required verification gates and migration has been explicitly approved.
3. Do not create Builder parts such as `O01_RSI` or `A10_ENTRY_SPECIAL` merely to reproduce one strategy. Prefer generic parts such as RSI, MA, ATR, TIME, CYCLE_STATE, GRID, TP/SL, TRAILING, etc., with configurable parameters.
4. Indicator type, timeframe, period, applied price, method, comparison condition, threshold/level, multiplier, and other relevant parameters must be data/configuration wherever practical rather than hard-coded per strategy.
5. The final Builder must support both reconstructed historical strategies and entirely new strategies assembled from the same reusable parts.
6. Reference-loading controls such as `O01 ENTRY` are development/migration aids, not required permanent controls in the final Builder UI.
7. Removal of a strategy-specific runtime path occurs only after evidence-backed Builder equivalence and an explicit migration decision; historical source/evidence remains preserved in GitHub.
8. The architectural destination is **one generic Logic Builder runtime**, not parallel permanent O01/A10-A15 engines.


---

## 7. Primary architecture decision — Builder-Only Runtime (2026-10-02)

The project has adopted `Docs/MultiAlpha_Builder_Only_Architecture_Policy_v1_00.md` as the governing final-architecture policy.

The final normal runtime shall be composed from independently saved and selected **ENTRY / MANAGE / EXIT Builder definitions**. O01 and A10-A15 are reclassified as Legacy Reference / Migration Oracle implementations: preserve them for parity/regression/evidence, but do not treat them as permanent active runtime engines.

This decision supersedes earlier policy language that required permanent coexistence of Builder modules and code-defined O01/A10-A15 modules in the final product. Coexistence remains valid **during migration/testing only**.

Immediate central development order is now:

1. Builder Core/schema/Part Registry and fail-closed validation.
2. Generic independent ENTRY / MANAGE / EXIT evaluators.
3. Generic Route Composer for freely replaceable compatible role modules.
4. Typed MT5 Context Provider.
5. SAVE/LOAD/versioned module and route library.
6. Free-slot Builder UI over the same definitions.
7. Migrate/reference-test O01 -> A10 -> A11 -> A12 -> A13 -> A14 -> A15.
8. Retire strategy-specific active runtime dependencies after evidence-backed migration.
9. Validate Builder-only backtest/demo runtime.
10. Only then create a separately approved execution host.

Do not deepen an O01/A10-specific active runtime path when the same work can be implemented in the generic Builder-only core.


---

## 8. Multi-Instance / Broker / Risk implementation policy (2026-10-02)

The central Builder-only program shall follow `Docs/MultiAlpha_MultiInstance_Broker_Risk_Architecture_v1_00.md`.

Key fixed decisions:

1. Freeze v2.45 as the UI/parts baseline and rebuild in a new Builder-only v3 generation.
2. Support up to 50 independently configured Strategy Instances in one host.
3. Allow each instance to independently select logical symbol, ENTRY, MANAGE, EXIT and Risk Profile.
4. Separate broker symbol resolution/specification from Builder logic.
5. Keep ordinary Expert Properties focused on environment and portfolio-level safety rather than strategy logic parameters.
6. Use both Instance Risk and Portfolio Guard before risk-increasing actions.
7. Build and test a multi-symbol Context Provider and Scheduler; do not rely on a single chart-symbol OnTick path.
8. Keep all central implementation NO_ORDERS until the separately approved execution stage.

The governing implementation gates are M0 through M15 in the architecture document. Do not skip directly to execution, and do not deepen strategy-specific O01/A10 runtime work when the equivalent work belongs in the generic multi-instance Builder core.
