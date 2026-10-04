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

Right workspace remains:
- SLOT: strategy/runtime assignment
- EA LOGIC: Module Library / Logic Builder
- EA PARTS: reusable parts picker/editor

### Fixed left LOGIC panel direction
The old left LOGIC panel contents are legacy O01/A10-specific information and are no longer the product model.

**Mainline specification: inherit the existing left LOGIC panel's visual design, but discard its legacy contents and rebuild it as the Strategy Dashboard.**

The Strategy Dashboard is the read-only/current-state overview for the selected Strategy SLOT. The right workspace remains the place where strategies, modules and Parts are selected or edited.

Target ownership:
- Left LOGIC / Strategy Dashboard: selected Strategy SLOT overview and execution readiness.
- Right EA LOGIC: Module Library and Logic Builder editing.
- Right EA PARTS: reusable Parts selection/editing.

Legacy strategy-specific fields such as Brick Size, BB Period, Entry Run, TP/SL bricks, Cooldown, Single Dist and Basket Start are not part of the new Strategy Dashboard. Strategy-specific parameters belong to Module/Parts definitions.

### Strategy Dashboard implementation gates
Develop the new left dashboard incrementally and stop for the user's local MetaEditor/MT5 confirmation after each gate.

**Gate LD-1 — Dashboard shell**
- Create the new left Strategy Dashboard shell and display layout.
- Reuse the existing left LOGIC panel's overall visual language (panel size/background/transparency/spacing where practical).
- Do not display the legacy O01/A10 logic-specific fields in the new dashboard.
- This gate is primarily visual/layout verification; do not pretend unconnected fields are live data.
- Preserve NO_ORDERS / VIRTUAL NOT FILL.

**Gate LD-2 — Strategy basic information**
Connect the dashboard basic information to the selected Strategy SLOT:
- SLOT number
- Enabled state
- logical Symbol
- Magic

Do not hard-code broker symbol suffixes. Broker-resolved symbol is a later Symbol Resolver concern.

**Gate LD-3 — Four Module references and validity**
Connect the selected Strategy SLOT's four Module references to the dashboard in canonical order:
1. ENTRY
2. GRID
3. MANAGE
4. EXIT

For each role display:
- Module Slot number
- Module name
- Module validity/status

INVALID is a valid saved development state and must remain visible. INVALID does not mean delete the Module or reject SAVE.

**Gate LD-4 — Strategy aggregate status**
Derive and display the selected Strategy SLOT's aggregate state from Strategy Enabled plus its required Module references/statuses.

Target states:
- READY
- INVALID
- INCOMPLETE
- DISABLED

An INVALID required Module must prevent runtime execution of that Strategy, but must not erase or automatically replace the stored Module reference.

After LD-1 through LD-4 are confirmed, continue the mainline Strategy reference gates (SL-1/SL-2) and Generic Runtime work. Dashboard work must not reintroduce fixed O01/A10 runtime ownership.


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
Development proceeds one compile-checked gate at a time:

1. Gate M4-1: starting from v2.68, change only the Builder skeleton from 3 roles to the canonical 4 roles ENTRY / GRID / MANAGE / EXIT. Keep 24 Parts and NO_ORDERS. Do not create the 50-slot Module Library yet.
2. Gate M4-2: expand each role from 24 Parts to 40 Parts, with 10 visible rows x 4 pages, including indexing/navigation and persistence.
3. Gate M4-3: split EA PARTS semantically into ENTRY / GRID / MANAGE / EXIT. Inspect O01 behavior before moving mixed legacy MANAGE parts; do not classify by name alone.
4. Gate ML-1: create a dedicated Module Slot Library data store: 50 slots independently for ENTRY, GRID, MANAGE and EXIT.
5. Gate ML-2: create Module Slot selector UI with role, #01-#50, Module Name, Enabled and EDIT.
6. Gate ML-3: connect EDIT to the 40-Part Logic Builder and verify independent Module Slot retention.
7. Gate LD-1: rebuild the left LOGIC panel shell as the Strategy Dashboard while inheriting the existing visual design.
8. Gate LD-2: connect SLOT number, Enabled, logical Symbol and Magic to the selected Strategy SLOT.
9. Gate LD-3: display selected ENTRY / GRID / MANAGE / EXIT Module Slot number, name and validity.
10. Gate LD-4: derive/display Strategy READY / INVALID / INCOMPLETE / DISABLED.
11. Gate SL-1: make Strategy SLOT #01-#50 store references to four Module Slot IDs rather than duplicated module logic.
12. Gate SL-2: expose only SAVED + ENABLED modules as new Strategy selection candidates; preserve disabled references as INVALID with no automatic substitution.
13. Gate RT-1: connect the four referenced modules to Generic Runtime under NO_ORDERS.
14. Gate O01-1: reproduce O01 from four generic module definitions and perform parity validation.
15. Gate SR-1: implement Symbol Resolver after Builder/module persistence/runtime are stable.
16. Strategy Tester validation.
17. Add explicit Demo Execution Safety Gate.
18. TitanFX Demo / resolved broker-symbol validation.
19. Only after functional completion, perform remaining cosmetic panel unification.

Each gate stops for the user's local MetaEditor compile and MT5 confirmation before the next gate begins.

## Deferred panel/UI improvement register

The following visual issue was confirmed during the user's local Gate M4-2 runtime check and is deliberately deferred so functional Builder development is not mixed with panel redesign.

### EA LOGIC lower-area text/control overlap
- In the 40-Part Builder panel, the lower area around `Name 40`, `Name 160`, `Ready` and `READ` has insufficient vertical spacing.
- Text, edit controls and status/readout lines can visually overlap.
- This is a recorded panel-development improvement item, not a reason to alter the functional M4 gates.
- Do not forget or silently close this item after Builder/runtime work is complete.
- During the final panel-development / layout-unification stage, adjust row spacing, vertical margins, edit-control positions and the status/readout area so that no text or controls overlap.
- Re-check this layout at the target MT5 panel size after the final functional architecture is stable.

## Safety during development
- Preserve NO_ORDERS / VIRTUAL NOT FILL until the explicit demo gate.
- Do not change broker execution while developing Builder storage/UI/evaluation.
- Do not mix panel redesign into functional Builder gates.
- Make one small GitHub change at a time.
- Never overwrite a confirmed older version by default.
- User local MetaEditor 0 errors / 0 warnings is the only Compile PASS.
- User local MT5 runtime is the final Runtime PASS.

## Current gate status
- Gate M4-1: PASS by user local MetaEditor and MT5 runtime confirmation.
- Gate M4-2: PASS by user local MetaEditor (0 errors / 0 warnings) and MT5 01-10 / 11-20 / 21-30 / 31-40 page confirmation.
- Current development gate: M4-3 semantic split of legacy MANAGE content into GRID / MANAGE / EXIT after source inspection.

## Historical M4-1 gate definition
Gate M4-1:
- base strictly on v2.68
- add the fourth Builder role and fix canonical ordering to ENTRY / GRID / MANAGE / EXIT
- keep the current 24-Part / 8-row / 3-page Builder capacity unchanged in this gate
- update only the minimum Builder panel/picker/workspace/composer integration needed for the four-role skeleton
- keep GRID semantic contents intentionally unassigned until Gate M4-3 where legacy MANAGE behavior is inspected and split
- do not implement 40 Parts, 50 Module Slots, Strategy Module references, Generic Runtime changes, Symbol Resolver or Demo execution in this gate
- use a short EA filename suitable for Strategy Tester
- stop after GitHub commit and wait for the user's local MetaEditor compile result

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


## Fixed Strategy Dashboard and Production Cleanup Plan (2026-10-05)

This section is the mainline rule for the remaining development. Do not repeat the failed approach of replacing the whole legacy panel at once.

### Strategy Dashboard rebuild baseline
Return the visual-development baseline to `MA_Builder_ModuleValid_v2_82`.

The legacy LOGIC panel policy is:
- preserve the proven panel geometry, theme, spacing, tabs and left/right alignment;
- remove/replace legacy logic-specific contents incrementally;
- rebuild the inside as the new Strategy Dashboard;
- never create a visually similar replacement panel when the existing proven canvas can be reused;
- one visible change per gate where practical;
- do not proceed to the next gate until the user confirms local MetaEditor 0 errors / 0 warnings and the MT5 screen is acceptable.

Dashboard implementation sequence:
- LD-1A: create a new-version baseline derived from v2_82 with no intentional visual change. Confirm identical layout first.
- LD-1B: replace only the legacy LOGIC panel title/header with Strategy Dashboard wording. Do not move or resize the panel.
- LD-1C: replace only the basic-information content with SLOT # / ENABLED / SYMBOL / MAGIC placeholders. Keep the existing canvas.
- LD-1D: add ENTRY / GRID / MANAGE / EXIT display rows, still without broad layout redesign.
- LD-1E: add the Strategy Status display area.
- LD-2: connect SLOT # / Enabled / Symbol / Magic to current Strategy SLOT data.
- LD-3: connect ENTRY / GRID / MANAGE / EXIT module number, module name and VALID/INVALID to Strategy references and Module Library.
- LD-4: derive the whole-Strategy state READY / INVALID / INCOMPLETE / DISABLED from the four module references and Strategy state.

The experimental Dashboard versions created during the earlier replacement attempt remain in Git history/reference only and are not the visual baseline.

### Continue to demo before structural cleanup
After Dashboard gates, continue the functional mainline through:
Builder/Module Library -> Strategy references -> Generic Runtime -> Symbol Resolver -> Global Safety -> NO_ORDERS runtime validation -> Strategy Tester -> Demo Execution Safety Gate -> TitanFX demo deployment.

Do not perform a large architecture cleanup in the middle of functional parity work. Preserve NO_ORDERS / VIRTUAL NOT FILL until the explicit demo execution gate.

### Gate RC-1: Production Cleanup / Architecture Freeze
After the EA has reached the demo-account deployment milestone and its required behavior has been confirmed, perform a dedicated cleanup gate before future cosmetic redesign.

RC-1 objectives:
1. Separate UI from trading/runtime behavior so future panel design changes do not require editing Strategy, Runtime, Safety or Execution code.
2. Establish one production main EA and a small, explicit production dependency set.
3. Create a Production Dependency Manifest listing every file required by the current production EA and its purpose.
4. Move obsolete/experimental versions out of the active production path while preserving Git history.
5. Remove obsolete includes and hidden legacy UI dependencies from the production mainline only after dependency inspection.
6. Centralize shared UI geometry/theme constants where practical so panel coordinates, spacing, fonts and theme are not duplicated across unrelated runtime files.
7. Keep Strategy / Module Library / Runtime / Safety / Symbol Resolver / Persistence interfaces independent from visual layout.
8. Re-run local MetaEditor compile, Strategy Tester and demo runtime checks after cleanup before declaring the architecture frozen.

Target production separation:
- Main: production EA composition only.
- UI: Strategy Dashboard, Strategy Slot, Module Library, Logic Builder, EA Parts and shared UI theme/layout.
- Strategy: Strategy Slot references, Module Library model and validation.
- Runtime: ENTRY / GRID / MANAGE / EXIT generic evaluation/runtime.
- Safety: global DD warning 8%, Grid Pause 12%, Emergency Close 15%.
- Core: Symbol Resolver and persistence/common services.
- Execution: demo/live execution adapter isolated from UI.

### Post-RC-1 change rule
After Architecture Freeze:
- UI-only requests must not modify Runtime / Strategy / Safety / Execution unless a documented interface change is genuinely required.
- A panel-design change must first be implemented inside the UI layer and validated visually.
- Functional changes and cosmetic changes use separate gates/commits.
- Production files are never overwritten blindly; keep a confirmed rollback point.
- Git history/archive may retain old versions, but only files listed in the Production Dependency Manifest are considered required for the current release.
- Local MetaEditor 0 errors / 0 warnings remains the only Compile PASS.
- Local MT5/demo behavior remains the Runtime PASS.
