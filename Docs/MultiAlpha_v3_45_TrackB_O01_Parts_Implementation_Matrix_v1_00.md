# Multi Alpha v3.45 — Track B O01 Parts Implementation Matrix v1.00

**Established:** 2026-10-07  
**Track:** B — LOGIC SLOT / LOGIC PARTS Construction Completeness  
**Baseline:** `Parity_Tests/MultiAlpha/MA_LD2A_O01BuilderBridge_v3_45.mq5`  
**Parent policy:** `Docs/MultiAlpha_v3_45_Dual_Track_Development_Priority_v1_00.md`

> **Architecture correction / governing classification (2026-10-07):**  
> This matrix must be read together with `Docs/MultiAlpha_v3_45_Logic_Filter_GlobalSafety_Responsibility_v1_00.md`.  
> The earlier audit correctly identified that several canonical O01 gates are absent from the EA PARTS picker, but absence does **not** automatically mean they must be added as ordinary strategy Parts. Each item must first be classified as Logic (L), Filter reference (F), Global Safety (G), or Host/Execution (H). Filter configuration belongs to FILTER Panel; Logic Parts only reference `FILTER_*_OK` at the role/branch where the filter applies. Warning 8%, Grid Pause 12%, Emergency Close 15% and emergency protection belong to Global Safety / Expert Properties and are not user-removable Logic Parts.

## 1. Gate objective

Determine whether O01 can actually be reconstructed through the normal editable Builder path:

`LOGIC SLOT -> EDIT -> EA PARTS -> APPLY -> SAVE -> LOAD -> Interpreter -> Runtime`

This audit deliberately distinguishes:
- canonical 40-Part definition exists,
- schema knows the Part,
- EA PARTS picker exposes the Part,
- required parameters can be edited,
- saved definition can persist it,
- Interpreter/runtime actually consumes it.

Source existence alone is not PASS.

## 2. Source set inspected

- `MA_LD2A_O01BuilderBridge_v3_45.mq5`
- `MultiAlpha_O01_Canonical_40Parts_v1_00/v1_01/v1_02.mqh`
- `MultiAlpha_Builder_Parts_Picker_v1_15.mqh`
- `MultiAlpha_Builder_FreeSlot_Panel_v1_26.mqh`
- `MultiAlpha_Builder_Part_Schema_v1_00/v1_01/v1_02/v1_03.mqh`
- `MultiAlpha_Builder_Interpreter_v1_05.mqh`
- `MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh`
- `MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh`
- `MultiAlpha_Module_Library_Store_v1_00.mqh`
- `MultiAlpha_Module_Edit_Nav_v1_03.mqh`

## 3. High-level finding

**Track B is currently PARTIAL / FAIL for full O01 reconstruction from the UI.**

The runtime/canonical path is ahead of the EA PARTS editing path.

v3.45 contains canonical O01 Parts and runtime decisions that are not all selectable/editable in `MultiAlpha_Builder_Parts_Picker_v1_15`.

This explains the observed user symptom: entering a LOGIC SLOT through EDIT can reach EA PARTS but some logic required by the saved/canonical O01 definition is absent from the picker or has no correct parameter editor.

## 4. ENTRY matrix

| O01 behavior / Part | Canonical 40P | Schema | Picker selectable | Required params editable | Runtime gate | Status |
|---|---:|---:|---:|---:|---:|---|
| CYCLE_NEW | YES | YES | YES | n/a | YES | PARTIAL |
| EMERGENCY_UNLOCKED | YES | YES | **NO** | n/a | YES | **MISSING UI** |
| TIME_ALLOWED | YES | YES | YES | no params | YES | PARTIAL |
| NEWS_CLEAR | YES | YES | **NO** | n/a | YES | **MISSING UI** |
| SPREAD_OK | YES | YES | **NO** | n/a | YES | **MISSING UI** |
| ATR_RANGE #1 | YES | YES | YES | TF/PERIOD/MIN/MAX | YES | PARTIAL |
| ATR_RANGE #2 | YES | YES | YES | TF/PERIOD/MIN/MAX | YES | PARTIAL |
| SIDE_COUNT BUY=0 | YES | YES | YES | SIDE/COND/VALUE | YES | PARTIAL |
| RSI_THRESHOLD BUY | YES | YES | YES | TF/PERIOD/PRICE/COND/LEVEL | YES | PARTIAL |
| BUY | YES | YES | YES | n/a | Interpreter action | PARTIAL |
| SIDE_COUNT SELL=0 | YES | YES | YES | SIDE/COND/VALUE | YES | PARTIAL |
| RSI_THRESHOLD SELL | YES | YES | YES | TF/PERIOD/PRICE/COND/LEVEL | YES | PARTIAL |
| SELL | YES | YES | YES | n/a | Interpreter action | PARTIAL |
| AND / OR branch grammar | YES | YES | YES | n/a | Interpreter v1_05 | PARTIAL |
| ONE_ORDER_PER_BAR | schema allows ENTRY | YES | **not shown in ENTRY picker** | editor exists generically | dispatch/runtime separate | **MISSING UI / ownership review** |
| INITIAL_LOT | schema allows ENTRY | YES | **not shown in ENTRY picker** | editor exists | dispatch uses runtime_cfg | **MISSING UI / runtime binding** |
| FILTERS_OK | not in canonical ENTRY recipe | YES | YES | n/a | canonical runtime uses individual gates | REVIEW |

### ENTRY critical result
The canonical ENTRY definition cannot currently be rebuilt exactly from the normal picker because **EMERGENCY_UNLOCKED, NEWS_CLEAR and SPREAD_OK are not exposed in ENTRY EA PARTS**. ONE_ORDER_PER_BAR and INITIAL_LOT also require an ownership/binding decision because schema/edit support exists but ENTRY UI/runtime definition ownership is incomplete.

## 5. GRID matrix

| O01 behavior / Part | Canonical 40P | Schema | Picker selectable | Required params editable | Grid Interpreter/runtime | Status |
|---|---:|---:|---:|---:|---:|---|
| SIDE_COUNT | YES | YES | YES | YES | YES | PARTIAL |
| MAX_ORDERS | YES | YES | YES | YES | YES | PARTIAL |
| DD_BELOW 12% | YES | YES | **NO** | **NO** | YES gate / schema | **MISSING UI** |
| TRAILING_PAUSE | YES | YES | YES | ENABLED | YES | PARTIAL |
| GRID_TIME_ALLOWED | YES | YES | **NO** | **NO** | YES | **MISSING UI** |
| GRID_NEWS_CLEAR | YES | YES | **NO** | **NO** | YES | **MISSING UI** |
| SPREAD_OK | YES | YES | **NO** | n/a | YES | **MISSING UI** |
| ONE_ORDER_PER_BAR | YES | YES | YES | ENABLED | YES | PARTIAL |
| LAST_PRICE | YES | YES | YES | n/a | YES | PARTIAL |
| FIXED_DISTANCE | YES | YES | YES | POINTS | calculation present | PARTIAL |
| DYNAMIC_DISTANCE | YES | YES | YES | START_ORDER/START_POINTS/MULT | calculation present | PARTIAL |
| DISTANCE_REACHED | YES | YES | **NO** | **NO** | YES | **MISSING UI** |
| LOT_MULTIPLIER | YES | YES | YES | MULT | calculation present | PARTIAL |
| MAX_LOT | YES | YES | YES | LOT | YES | PARTIAL |
| MAX_TOTAL_LOT | YES | YES | YES | LOT | YES | PARTIAL |
| ADD_BUY | YES | YES | YES | n/a | YES | PARTIAL |
| ADD_SELL | YES | YES | YES | n/a | YES | PARTIAL |
| AND / OR | YES | YES | YES | n/a | fixed Grid plan | PARTIAL |

### GRID critical result
The canonical GRID v1_01 definition has **33 ordered slots**, but the picker cannot create several mandatory guards: **DD_BELOW, GRID_TIME_ALLOWED, GRID_NEWS_CLEAR, SPREAD_OK, DISTANCE_REACHED**. Therefore UI-built GRID cannot currently equal the canonical/runtime GRID.

Also note: `MultiAlpha_Builder_Grid_Interpreter_v1_00` validates an **exact fixed 33-slot O01 plan**. This proves O01 ordering but is not yet a fully generic arbitrary GRID expression interpreter. Track B must preserve parity while moving toward generic composition rather than hard-coding O01 forever.

## 6. MANAGE matrix

Canonical v1_02 MANAGE:
`POSITION_COUNT AND AVG_PRICE AND LAST_PRICE AND MOVE_POINTS AND OVERLAP`

| Part | Canonical | Schema | Picker selectable | Params editable | Runtime | Status |
|---|---:|---:|---:|---:|---:|---|
| POSITION_COUNT | YES | YES | YES (label via SPACER) | n/a | state read | PARTIAL |
| AVG_PRICE | YES | YES | YES | n/a | state read | PARTIAL |
| LAST_PRICE | YES | YES | **NO in MANAGE picker** | n/a | state read | **MISSING UI** |
| MOVE_POINTS | YES | YES | YES | n/a | state read | PARTIAL |
| OVERLAP | YES | YES v1_03 | **NO** | **NO** | v3.45 ManageDecision parses it | **MISSING UI** |
| AND | YES | YES | YES | n/a | schema/ordering | PARTIAL |

The MANAGE picker additionally exposes SINGLE_TRAILING and BASKET_TRAILING, but those are not the canonical v1_02 MANAGE recipe shown above. Do not use their mere presence as proof that canonical MANAGE can be reconstructed.

## 7. EXIT matrix

Canonical v1_02 EXIT:
`POSITION_COUNT AND AVG_PRICE AND MOVE_POINTS AND VIRTUAL_SL OR FIXED_TP OR SINGLE_TRAILING OR BASKET_TRAILING OR BASKET_FIXED_TP OR SINGLE_MONEY_TP OR CLOSE_OPPOSITE`

| Part | Canonical | Schema | Picker selectable | Params editable | Runtime/evaluator | Status |
|---|---:|---:|---:|---:|---:|---|
| POSITION_COUNT | YES | YES | **NO** (EXIT COUNT maps SIDE_COUNT) | n/a | evaluator state | **MISSING UI / wrong mapping** |
| AVG_PRICE | YES | YES | YES | n/a | YES | PARTIAL |
| MOVE_POINTS | YES | YES | YES | n/a | YES | PARTIAL |
| VIRTUAL_SL | YES | YES | YES | POINTS | YES | PARTIAL |
| FIXED_TP | YES | YES | YES | POINTS only | evaluator | PARTIAL / scope semantics review |
| SINGLE_TRAILING | YES | YES | YES | START/LOCK/DISTANCE/STEP | YES | PARTIAL |
| BASKET_TRAILING | YES | YES | YES | START/LOCK/DISTANCE/STEP | YES | PARTIAL |
| BASKET_FIXED_TP | YES | YES v1_03 | **NO** | **NO** | evaluator/schema path | **MISSING UI** |
| SINGLE_MONEY_TP | YES | YES v1_03 | **NO** | **NO** | evaluator/schema path | **MISSING UI** |
| CLOSE_OPPOSITE | YES | YES v1_03 | **NO** | **NO** | evaluator/schema path | **MISSING UI** |
| CLOSE_SIDE | picker has it | YES | YES | n/a | execution action concept | not canonical v1_02 slot |

### EXIT critical result
The EXIT picker is materially behind canonical v1_02. In particular, **POSITION_COUNT is not correctly selectable from EXIT**, and the three v1_03 schema additions **BASKET_FIXED_TP, SINGLE_MONEY_TP, CLOSE_OPPOSITE** are absent from the picker/editor.

## 8. Persistence findings

There are currently multiple storage layers:

1. `CMultiAlphaBuilderFreeSlotPanel126`
   - 4 roles x 40 slots
   - role SAVE/LOAD and SAVEALL/LOADALL UI exists.

2. `CMultiAlphaBuilderSlotWorkspaceStore103`
   - 50 strategy workspaces x 4 roles x 40 Parts
   - in-memory runtime workspace.

3. `CMultiAlphaModuleLibraryStore100`
   - 4 roles x 50 module slots x 40 Parts
   - in-memory module library with saved/enabled state.

This is structurally promising, but Track B requires an explicit proof that:
`LOGIC SLOT EDIT -> picker APPLY -> SAVE & BACK -> Module Library -> selected Strategy/Workspace -> runtime GetRole()`
preserves the exact same Parts/params.

That round-trip is **NOT YET PASSED by this source audit**.

## 9. Interpreter findings

### ENTRY
`CMultiAlphaBuilderInterpreter105` correctly introduces explicit ENTRY branch semantics:
- AND inside branch
- OR between completed action branches
- BUY/SELL terminates a branch

This is a strong foundation for generic ENTRY composition.

### GRID
`CMultiAlphaBuilderGridInterpreter100` currently expects the exact canonical 33-slot O01 GRID plan. Good for parity proof; insufficient as final proof of arbitrary generic GRID composition.

### MANAGE
v3.45 performs schema/state checks and separately parses specific OVERLAP behavior. Generic composition is not yet at the same maturity as ENTRY.

### EXIT
v3.45 uses the O01-specific exit evaluator `CMultiAlphaBuilderO01ExitEvaluator100`. This is useful as an oracle/migration evaluator but must not become the hidden permanent Builder-only implementation.

## 10. P0 gaps to close first

Recommended Track B implementation order:

### B-P0-1 — Responsibility classification, then picker completeness
Before adding anything to EA PARTS, classify every O01 behavior as **L / F / G / H** under the governing responsibility document.

Current direction:
- ENTRY shared Time/News/Spread checks -> **F** references such as FILTER_TIME_OK / FILTER_NEWS_OK / FILTER_SPREAD_OK.
- GRID shared Time/News/Spread checks -> **F** references where O01 timing requires them.
- Warning 8%, Grid Pause 12%, Emergency Close 15% and emergency protection -> **G**, not user-placed Parts.
- MANAGE LAST_PRICE / OVERLAP and genuine strategy mechanics -> **L** candidates.
- EXIT POSITION_COUNT, BASKET_FIXED_TP, SINGLE_MONEY_TP, CLOSE_OPPOSITE -> **L** candidates subject to source/parity confirmation.
- ONE_ORDER_PER_BAR / INITIAL_LOT / broker normalization -> classify ownership explicitly before implementation.

Only after classification, add missing **L/F** picker items and parameter/reference editors without changing verified DEMO trading behavior.

### B-P0-2 — Schema/picker identity test
For every picker button, verify emitted canonical Part ID is accepted by the role schema with the emitted parameter string.

### B-P0-3 — UI round-trip persistence
For each role:
- construct/edit
- SAVE
- leave/clear
- LOAD
- compare all 40 Part IDs + params byte/semantic-equivalent

### B-P0-4 — LOGIC SLOT SAVE & BACK round-trip
Prove Module Library EDIT/SAVE & BACK loads and saves the same 40-slot definition and that selected Strategy workspace receives the intended definition only.

### B-P0-5 — deterministic Interpreter parity
Feed controlled contexts into the saved definitions and compare decisions to canonical O01 expectations.

### B-P0-6 — remove hidden-definition ambiguity
Prove Runtime consumes the saved UI-built definitions rather than a separately seeded canonical O01 array or hard-coded fallback.

## 11. Current Track B gate status

- 4 roles x 40 storage skeleton: **PASS by source**
- canonical O01 40-Part recipes: **PASS by source**
- ENTRY branch grammar: **PASS by source**
- all canonical O01 Parts exposed in EA PARTS: **FAIL**
- all required O01 Part parameters editable: **FAIL**
- GRID generic composition: **PARTIAL**
- MANAGE generic composition: **PARTIAL**
- EXIT generic composition: **PARTIAL / O01-specific evaluator**
- LOGIC SLOT -> EDIT navigation exists: **PASS by source**
- full UI SAVE/LOAD/runtime round trip: **NOT TESTED / not yet evidence-backed**
- UI-built O01 consumed by demo Runtime: **NOT PROVEN**

## 12. Next gate

**B-P0-1: O01 responsibility classification (L/F/G/H), then picker completeness for L/F items only.**

This gate must be implementation-only on the Builder/UI definition path. It must not alter v3.45's verified DEMO decision/dispatch behavior.

After source implementation:
1. local MetaEditor compile must show 0 errors / 0 warnings,
2. open each role through LOGIC SLOT -> EDIT -> EA PARTS,
3. visually confirm all canonical Parts are selectable,
4. confirm parameter editors emit schema-valid strings,
5. only then proceed to SAVE/LOAD round-trip.
