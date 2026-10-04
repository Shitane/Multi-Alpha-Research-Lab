# Multi Alpha Logic Builder - Fixed Development Plan v1.00

## Status
This document is the current development source of truth for Logic Builder work.

## Fixed base
Development resumes from:
`Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_BuilderSlotEdit_NoOrders_v2_68.mq5`

v2.69/v2.70 are reference work only. Useful generic Builder changes may be selectively ported, but the left-panel Builder migration is not the active development base.

## Product concept
Multi Alpha Research Lab is an environment for creating and testing original strategies by freely combining independently built modules:

EA PARTS -> MODULE BUILDER -> ENTRY / GRID / MANAGE / EXIT MODULES -> SLOT STRATEGY -> SYMBOL RESOLVER -> GENERIC RUNTIME -> GLOBAL SAFETY -> EXECUTION.

ENTRY, GRID, MANAGE and EXIT modules are independent reusable definitions. They are not fixed O01/A10 IDs.

## UI ownership during Builder completion
Do not redesign/unify the panels yet.

Right workspace remains:
- SLOT: strategy/runtime assignment
- EA LOGIC: module builder
- EA PARTS: reusable parts picker/editor

Left FILTER and PRESET remain as existing functionality. Cosmetic panel unification is postponed until Builder + Symbol Resolver + demo execution are working.


## Fixed Module Role Order

The canonical module role order is permanently fixed as:

1. ENTRY
2. GRID
3. MANAGE
4. EXIT

Canonical internal role indexes:
- Role 0 = ENTRY
- Role 1 = GRID
- Role 2 = MANAGE
- Role 3 = EXIT

Use this same order consistently in UI buttons, arrays, persistence, Module Slot Library, Strategy SLOT references, validation, logging and Generic Runtime. Do not use ENTRY / MANAGE / GRID / EXIT ordering in new code.

Rationale follows the strategy lifecycle:
ENTRY creates the initial position; GRID handles averaging/additional entries; MANAGE handles already-open position/basket management; EXIT closes positions.

Legacy three-role data must be migrated explicitly. Old role index 1 (legacy MANAGE) must not be blindly treated as new Role 1, because new Role 1 is GRID and legacy MANAGE contains logic that must be semantically split between GRID and MANAGE.

## Builder capacity
Each ENTRY / GRID / MANAGE / EXIT module has 40 part slots:
- 10 visible rows per page
- 4 pages
- slots 01-10, 11-20, 21-30, 31-40

Total editable capacity across the four module roles is 160 slots.

GRID is an independent reusable module for averaging/add-on order logic (distance, lot progression, maximum orders/lots, add-buy/add-sell, etc.). MANAGE is reserved for position-management behavior such as trailing/basket management.

The storage/schema must use 40 as the role capacity. Do not implement 40 only as a visual UI extension.

## Module and strategy persistence
Role save/load becomes the module persistence concept:
- SAVE MODULE / LOAD MODULE for one ENTRY, MANAGE or EXIT definition.
- Existing legacy 24-slot files should remain readable where practical; missing slots 25-40 are EMPTY.
- Combined ENTRY + GRID + MANAGE + EXIT persistence is the strategy-definition concept.

Saved Builder Definition is the runtime source of truth. UI state must not become a hidden runtime dependency.

## SLOT
Each SLOT ultimately owns:
- Enabled
- logical Symbol
- Entry Module
- Grid Module
- Manage Module
- Exit Module
- independent Builder/strategy definition

Target: up to 50 independent SLOTs.

## Symbol Resolver
Implement after Builder module persistence/evaluation is stable.

A SLOT stores a logical symbol such as XAUUSD. Symbol Resolver maps it to the broker symbol, e.g. XAUUSD -> XAUUSD-m for TitanFX Demo.

No Builder strategy should hard-code TitanFX suffixes.

## Generic runtime
Runtime evaluates the Saved Builder Definition using generic ENTRY / GRID / MANAGE / EXIT evaluators.

O01 is the first parity/reference recipe only. Runtime must not silently fall back to O01-specific logic.

## Canonical schema
Internal part IDs and parameter keys must be canonical. UI labels may be abbreviated, but stored definitions use canonical IDs.

Legacy aliases should be absorbed by the loader where compatibility is required.

## Global safety
Global Safety is outside Builder strategy logic:
- Warning DD 8%
- Grid Pause DD 12%
- Emergency Close 15%

15% Emergency Close is not an EXIT module condition.

## Execution gates
Development order:
1. Freeze v2.68 as baseline.
2. Expand Builder role capacity from 24 to 40 (8 x 5) end-to-end.
3. Make one-role persistence a formal reusable Module Definition.
4. Complete Canonical Schema / loader compatibility.
5. Complete generic ENTRY evaluator.
6. Complete generic MANAGE evaluator.
7. Complete generic EXIT evaluator.
8. Compose independently selected ENTRY + GRID + MANAGE + EXIT in SLOT.
9. Reproduce O01 from Builder definitions and verify parity in NO_ORDERS.
10. Implement Symbol Resolver.
11. Strategy Tester validation.
12. Add explicit Demo Execution Safety Gate.
13. TitanFX Demo / XAUUSD-m validation.
14. Only after functional completion, unify panel design.

## Safety during development
- Preserve NO_ORDERS / VIRTUAL NOT FILL until the explicit demo gate.
- Do not change broker execution while developing Builder storage/UI/evaluation.
- Do not mix panel redesign into functional Builder gates.
- Make one small GitHub change at a time.
- Never overwrite a confirmed older version by default.
- User local MetaEditor 0 errors / 0 warnings is the only Compile PASS.
- User local MT5 runtime is the final Runtime PASS.

## Immediate gate
Gate B40-1:
- create a new Builder panel version based on v1_22
- expand the Builder from the legacy 3-role/24-slot layout to four independent module roles: ENTRY / GRID / MANAGE / EXIT
- module capacity = 40
- visible rows = 10
- page count = 4
- update indexing/range/navigation
- update module and combined persistence format for 40 slots per module / 160 total
- preserve compatibility with legacy 24/72 files where practical
- integrate it into a short-named EA derived from v2.68
- compile locally before any further runtime change
## Fixed Module Slot Library Specification

The reusable module layer is fixed as follows.

### Module slot capacity
Each module role has 50 independent Module Slots:
- ENTRY MODULE: #01-#50
- GRID MODULE: #01-#50
- MANAGE MODULE: #01-#50
- EXIT MODULE: #01-#50

Each saved Module Slot contains one module definition with up to 40 Builder Parts, displayed as 10 rows x 4 pages.

The architecture is therefore:
EA PARTS -> LOGIC BUILDER -> MODULE SLOT LIBRARY -> STRATEGY SLOT -> Symbol Resolver -> Generic Runtime -> Global Safety -> Execution.

### Module role selection UI
Provide role-selection buttons for ENTRY / GRID / MANAGE / EXIT.

Selecting a role opens that role's 50-slot Module Slot selector. Reuse the current Strategy SLOT selection/enabling interaction pattern where practical rather than introducing an unrelated navigation method.

Each Module Slot must support:
- slot number #01-#50
- module name
- EMPTY / SAVED state
- ENABLED / DISABLED state
- EDIT action
- saved 40-Part module definition and parameters

EDIT opens the Logic Builder for that exact Module Slot. Saving writes the Builder definition back to that Module Slot.

### Enabled-only Strategy selection
A Strategy SLOT may select only Module Slots that are currently SAVED and ENABLED for the corresponding role.

Example:
- enabled ENTRY modules: #01, #03, #13
- Strategy ENTRY selector must offer only #01, #03, #13
- DISABLED and EMPTY Module Slots must not appear as selectable candidates.

This filtering is independent for ENTRY, GRID, MANAGE and EXIT.

### Referenced module becomes disabled
If a Strategy SLOT already references a Module Slot and that Module Slot is later disabled, do not silently substitute another module.

Keep the stored reference visible and mark it invalid/disabled, for example:
ENTRY #13 [DISABLED]
STATE INVALID

The affected Strategy SLOT must not begin new trading through an invalid required module reference until the reference is made valid again or the user explicitly selects another enabled Module Slot.

No automatic fallback or automatic module-number replacement is allowed.

### Module Slot state model
Module Slots have three distinct states:
1. EMPTY
2. SAVED + DISABLED
3. SAVED + ENABLED

Disabling a Module Slot must not erase its saved logic or parameters. Re-enabling restores it as a selectable candidate.

Deletion/clearing and disabling are separate operations.

### Strategy SLOT references
Strategy SLOT #01-#50 stores module references, not independent duplicated copies of the module logic.

Target display/reference structure:
- ENTRY: module slot number + module name
- GRID: module slot number + module name
- MANAGE: module slot number + module name
- EXIT: module slot number + module name

Example:
ENTRY  #13 RSI_ENTRY_A
GRID   #18 GRID_200_1.5
MANAGE #07 BASKET_TRAIL
EXIT   #09 TP_VSL

This enables controlled module reuse and module-by-module comparison across Strategy Slots.

### Separation of capacities
Do not confuse these two capacities:
- Module Slot Library capacity: 50 saved modules per role
- Logic Builder capacity inside each Module Slot: 40 Parts (10 x 4)

With four roles, the library can hold up to 200 Module Slots total, while each individual Module Slot contains at most 40 Parts.
