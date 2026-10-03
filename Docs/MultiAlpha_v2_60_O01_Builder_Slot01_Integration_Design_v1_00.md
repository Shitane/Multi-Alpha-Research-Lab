# Multi Alpha Research Lab — v2_60 O01 Builder / SLOT #01 Integration Design v1.00

**Established:** 2026-10-03  
**Status:** CURRENT IMPLEMENTATION DESIGN  
**Baseline:** `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_60`

## 1. Immediate objective

The current priority is one end-to-end path:

```text
O01 reference behavior
        |
        v
generic EA PARTS only
        |
        v
ENTRY / MANAGE / EXIT Builder definitions
        |
        v
embed/select those definitions in SLOT #01
(no fixed O01 runtime identity)
        |
        v
Symbol Resolver
        |
        v
SLOT #01 instance context / Magic / FILTER / state
        |
        v
Global Safety
        |
        v
Execution Adapter
        |
        v
TitanFX DEMO
```

O01 is the first proof case. The runtime must not solve this by calling a permanent O01-specific strategy engine behind the Builder.

## 2. Meaning of "put O01 into SLOT #01"

SLOT #01 shall not contain a hard-coded enum such as O01.

It shall contain/configure references to actual Builder definitions plus instance-local configuration:

```text
SLOT #01
  ENABLE
  Logical Symbol
  Resolved Broker Symbol
  Magic
  FILTER settings
  ENTRY Definition
  MANAGE Definition
  EXIT Definition
  independent runtime state
```

For the first proof, the definitions may be named O01_ENTRY / O01_MANAGE / O01_EXIT for human identification, but the runtime interprets their generic parts. The name O01 has no strategy-specific execution privilege.

Later, any saved ENTRY/MANAGE/EXIT can replace one of these without recompiling the EA.

## 3. Current v2_60 gaps that this integration must remove

Current v2_60 still contains legacy startup/runtime items such as one InpMagic, O01-specific Expert Properties, O01 runtime_cfg, O01 adapter/core calls, and legacy route IDs. It also currently rejects DEMO at OnInit.

These are reference/migration paths, not the final Builder path.

The integration must progressively establish a separate Builder-driven path first, verify it, then retire/bypass the legacy O01 strategy path for SLOT #01.

Do not simply remove the NO_ORDERS reject and expose the legacy O01 runtime as if Builder integration were complete.

## 4. Builder data model

Each role has 24 ordered slots. Each occupied slot stores at least:

```text
PartDefinition
  part_id
  role
  parameter_schema_version
  parameters
```

The role definition stores:

```text
BuilderDefinition
  definition_id/name
  role = ENTRY | MANAGE | EXIT
  definition_version
  slots[24]
  validation result
```

SLOT #01 composes three definitions:

```text
BuilderRoute
  entry_definition
  manage_definition
  exit_definition
```

The saved Builder Definition is the source of truth. UI controls edit it; runtime consumes the same saved/in-memory definition.

## 5. Canonical generic Part IDs

The integration shall normalize current historical naming differences into one canonical vocabulary. UI captions may remain short.

### Common / state
- CYCLE_NEW
- FILTERS_OK
- SIDE_COUNT
- POSITION_COUNT
- AVG_PRICE
- LAST_PRICE
- MOVE_POINTS

### Indicators / conditions
- RSI_THRESHOLD
- ATR_RANGE

### Manage
- INITIAL_LOT
- MAX_ORDERS
- ONE_ORDER_PER_BAR
- TRAILING_PAUSE
- FIXED_DISTANCE
- DYNAMIC_DISTANCE
- LOT_MULTIPLIER
- MAX_LOT
- MAX_TOTAL_LOT

### Exit
- VIRTUAL_SL
- FIXED_TP only if confirmed required by the O01 reference
- SINGLE_TRAILING
- BASKET_TRAILING

### Logic
- AND
- OR

### Actions
- BUY
- SELL
- ADD_BUY
- ADD_SELL
- CLOSE_SIDE

Aliases used by old seed/evaluator files (for example FIXED_DIST, LOT_MULT, MAX_TOTAL, TRAIL_PAUSE, ONE/BAR, SIGNAL BUY) may be accepted only by a migration/normalization layer. New v2_60-line saves must use canonical IDs.

## 6. Parameter schemas needed for O01

### SIDE_COUNT
```text
SIDE = BUY | SELL | CURRENT
COND = EQ | GT | GE | LT | LE
VALUE = integer
```

This replaces strategy-specific BUY_SIDE_ZERO / SELL_SIDE_ZERO in new saves.

### RSI_THRESHOLD
```text
TF = CURRENT or timeframe
PERIOD = 8
PRICE = CLOSE
COND = LT | GT | LE | GE
LEVEL = numeric
```

### ATR_RANGE
```text
TF
PERIOD
MIN_POINTS
MAX_POINTS
```

O01 requires two ATR range checks from the current reference settings.

### INITIAL_LOT
```text
LOT = 0.01
```

### MAX_ORDERS
```text
COUNT = 10
```

### FIXED_DISTANCE
```text
POINTS = 200
```

### DYNAMIC_DISTANCE
```text
START_ORDER = 3
START_POINTS = 300
MULT = 1.20
```

### LOT_MULTIPLIER
```text
MULT = 1.50
```

### MAX_LOT
```text
LOT = 5.00
```

### MAX_TOTAL_LOT
```text
LOT = 1.20
```

### ONE_ORDER_PER_BAR
```text
ENABLED = 1
```

### TRAILING_PAUSE
```text
ENABLED = 1
```

### VIRTUAL_SL
```text
POINTS = 1500
```

### SINGLE_TRAILING
```text
START = 110
LOCK = 60
DISTANCE = 50
STEP = 10
```

### BASKET_TRAILING
```text
START = 100
LOCK = 50
DISTANCE = 50
STEP = 10
```

Use DISTANCE as the canonical key. Historical DIST must be normalized on load.

## 7. O01 ENTRY Builder design

The current O01 reference uses RSI(8), lower 30, upper 70, new-cycle/side-zero gating and filters. It also has ATR1/ATR2 range filters.

The target Builder definition is conceptually:

```text
BUY branch:
  CYCLE_NEW
  AND FILTERS_OK
  AND SIDE_COUNT(SIDE=BUY, EQ, 0)
  AND RSI_THRESHOLD(TF=CURRENT, PERIOD=8, PRICE=CLOSE, LT, 30)
  AND ATR_RANGE(ATR1 reference settings)
  AND ATR_RANGE(ATR2 reference settings)
  -> BUY

OR

SELL branch:
  CYCLE_NEW
  AND FILTERS_OK
  AND SIDE_COUNT(SIDE=SELL, EQ, 0)
  AND RSI_THRESHOLD(TF=CURRENT, PERIOD=8, PRICE=CLOSE, GT, 70)
  AND ATR_RANGE(ATR1 reference settings)
  AND ATR_RANGE(ATR2 reference settings)
  -> SELL
```

Because repeating both ATR parts in both branches may exceed/pressure the 24-slot UI, the interpreter/runtime shall support role-level preconditions where appropriate, or a reusable FILTERS_OK context may include the configured SLOT-local common filters/volatility filter. The exact 24-slot expression must be validated against the O01 reference before freezing.

Do not silently omit ATR behavior merely to fit the UI.

## 8. FILTER relationship

The v2_60 left FILTER panel is SLOT-local and shall be used rather than duplicating every calendar/time/spread filter as Builder parts.

For SLOT #01, FILTER state may include:
- trading time
- FOMC
- NEWS
- NFP
- CPI
- month/quarter/year boundaries
- rollover
- Friday
- spread
- volatility/ATR range where configured

Builder uses the generic FILTERS_OK condition to query SLOT #01's evaluated filter state.

O01's existing time/news semantics must be mapped carefully, including the difference between blocking new ENTRY and allowing/blocking MANAGE. Do not assume one FILTERS_OK boolean is sufficient for every role; provide role-scoped filter results such as ENTRY_FILTER_OK and MANAGE_FILTER_OK if required by parity.

## 9. O01 MANAGE Builder design

The current v2_60 reference values are the target, not older test seed values:

```text
Initial Lot           0.01
Lot Multiplier        1.50
Max Lot               5.00
Max Total Lots/Side   1.20
Max Orders            10
Fixed Distance        200
Dynamic Start Order   3
Dynamic Start Points  300
Distance Multiplier   1.20
Allow Grid Outside Time = true
One Order Per Bar     = true
Pause Grid While Trailing = true
```

The MANAGE definition must represent:
- existing side/position state
- max-order gate
- trailing-pause gate
- role-specific FILTER/time/news/spread permission
- one-order-per-bar
- fixed/dynamic grid distance
- lot progression
- max lot / max total lot
- side-correct ADD action

The first implementation may keep ADD_BUY and ADD_SELL as generic actions. A later ADD_SAME_SIDE action is acceptable only if its semantics are generic and parity-tested.

## 10. O01 EXIT Builder design

The current v2_60 reference values are:

```text
Virtual SL            1500
Single Trail Start     110
Single Trail Lock       60
Single Trail Distance   50
Single Trail Step       10
Basket Trail Start     100
Basket Trail Lock       50
Basket Trail Distance   50
Basket Trail Step       10
```

EXIT evaluation requires instance-local:
- side
- position count
- average price
- current executable price
- move points
- trailing state

The Builder must express VIRTUAL_SL, SINGLE_TRAILING and BASKET_TRAILING with their complete parameters.

FIXED_TP must not be assumed from the current picker default. Its exact use in the O01 reference must be confirmed before it is included in the frozen O01 Builder definition.

## 11. EA PARTS UI changes

Current v1.10 already exposes many required buttons, but the following work is required:

1. Add CYCLE_NEW to ENTRY.
2. Add/configure ATR_RANGE in the actual O01 ENTRY workflow.
3. Make SIDE_COUNT editable (SIDE / COND / VALUE).
4. Add INITIAL_LOT to MANAGE.
5. Normalize canonical Part IDs.
6. Normalize parameter keys (especially DIST -> DISTANCE, VALUE/LOT/COUNT).
7. Ensure both SINGLE and BASKET trailing persist all four parameters.
8. Provide role-scoped filter semantics rather than duplicate filter configuration.
9. Validator must reject missing/invalid required parameters.
10. UI APPLY writes exactly the definition consumed by runtime.

## 12. SLOT #01 composition design

The SLOT #01 state shall be extended from legacy route IDs to Builder composition:

```text
Instance #01
  enabled = true
  logical_symbol = XAUUSD
  resolved_symbol = XAUUSD-m (example, resolver result)
  magic = #01-owned Magic
  entry_definition = selected/saved Builder ENTRY
  manage_definition = selected/saved Builder MANAGE
  exit_definition = selected/saved Builder EXIT
  filter_config = #01 local
  runtime_state = #01 local
```

The definitions may be loaded from SAVE24 or embedded/copied into the instance's route snapshot. The runtime must use a validated immutable snapshot/version while the instance is active so editing a library definition cannot silently mutate a live cycle.

Applying a changed route while #01 owns positions requires a safe transition rule; no hot replacement across an active cycle unless explicitly supported and validated.

## 13. Symbol Resolver integration

The Builder definition uses a logical symbol, not XAUUSD-m.

For #01:

```text
SLOT #01 logical_symbol = XAUUSD
          |
          v
Symbol Resolver
          |
          +-- validates broker symbol
          +-- obtains Point/Digits/TickSize/TickValue/VolumeMin/Max/Step
          |
          v
resolved_symbol = XAUUSD-m on the current TitanFX demo example
```

Indicator handles, tick reads, position ownership queries and execution must use the resolved symbol from #01 context, not chart _Symbol by assumption.

Resolver failure or ambiguity makes #01 INVALID and broker actions remain blocked.

## 14. #01 instance-local Magic and state

SLOT #01 owns its Magic. It is not taken from one global Magic shared by all 50 instances.

For the first O01 demo, all mutable O01 state currently represented by globals such as virtual/live position state, trail state and last-bar markers must be moved/represented in #01 instance state on the Builder path.

This first #01 implementation must already use structures that can later become instances[50], even if only #01 is enabled during the first demo.

## 15. Global Safety boundary

Warning 8%, Grid Pause 12%, Emergency Close 15% remain Expert Properties / EA-global safety.

They are not Builder parts and are not stored inside O01 ENTRY/MANAGE/EXIT.

Execution order:

```text
Builder decision
    |
#01 ownership/risk checks
    |
EA Global Safety
    |
Execution Adapter
    |
Broker
```

At 12%, risk-increasing grid ADD requests are blocked by Global Safety. At 15%, Emergency Close has priority over normal Builder EXIT behavior.

## 16. Integration phases

### Phase A — Parts/schema
Create canonical Part Registry/schema and migration aliases. Complete parameter editing for O01-required generic parts.

**Gate:** UI definition round-trip and validation; NO ORDERS.

### Phase B — Build O01 in actual v2_60-line panel
Construct ENTRY, MANAGE and EXIT using EA LOGIC + EA PARTS. SAVE24/LOAD24 and SAVE72 must preserve complete semantics.

**Gate:** actual panel-created definitions equal normalized expected definitions.

### Phase C — SLOT #01 Builder composition
Replace/bypass legacy O01/A10 route selection for the Builder path with three selected Builder definitions and #01 local Symbol/Magic/FILTER.

**Gate:** #01 validates from Builder definitions only; no O01 strategy dispatch.

### Phase D — Generic Builder runtime
Context Provider evaluates indicators/filter/position/cycle state for #01. Generic role evaluators produce ENTRY/MANAGE/EXIT actions.

**Gate:** NO_ORDERS parity against O01 reference and Strategy Tester evidence.

### Phase E — Symbol Resolver
Wire verified resolver/spec snapshot into #01 context and remove chart-symbol assumptions from the Builder path.

**Gate:** actual TitanFX demo symbol resolution/spec read-only evidence.

### Phase F — controlled DEMO
Connect validated #01 Builder actions through Global Safety and Execution Adapter.

**Gate:** broker ownership audit, Magic isolation, state audit, demo execution/forward evidence.

## 17. Definition of success

The first O01 Builder milestone is successful only when:

1. O01 logic is assembled with generic EA PARTS in the v2_60-line panel.
2. ENTRY/MANAGE/EXIT are independent Builder definitions.
3. SLOT #01 receives/composes those definitions rather than selecting a hard-coded O01 runtime module.
4. #01 owns its Symbol, Magic, FILTER and mutable runtime state.
5. Symbol Resolver supplies the actual broker symbol/spec.
6. runtime evaluates the Builder definitions directly.
7. Global Safety remains outside Builder logic.
8. NO_ORDERS/Tester evidence passes.
9. TitanFX demo executes the Builder decisions through the controlled adapter.
10. no hidden O01-specific execution path is required.

Only after this end-to-end path is proven should the central implementation effort expand to #02-#50 or migrate A10.
