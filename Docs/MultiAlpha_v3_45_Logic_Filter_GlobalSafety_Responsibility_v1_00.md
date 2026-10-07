# Multi Alpha v3.45 — Logic / Filter / Global Safety Responsibility v1.00

**Established:** 2026-10-07  
**Status:** CURRENT ARCHITECTURE DECISION / MUST BE REFERENCED BEFORE BUILDER WORK  
**Baseline:** `Parity_Tests/MultiAlpha/MA_LD2A_O01BuilderBridge_v3_45.mq5`  
**Parent:** `Docs/MultiAlpha_v3_45_Dual_Track_Development_Priority_v1_00.md`

## 1. Fixed product model

For the current Multi Alpha design, one EA strategy is defined as:

```text
ENTRY Module
+ GRID Module
+ MANAGE Module
+ EXIT Module
+ FILTER Panel
= EA LOGIC
```

Account/EA-wide protection and execution policy are **not strategy Logic Parts**. They are configured through **Expert Properties / Global Safety**.

```text
EA LOGIC
  = ENTRY + GRID + MANAGE + EXIT + FILTER

GLOBAL / EXPERT PROPERTIES
  = account/EA-wide safety and execution settings
```

This separation is authoritative for Track B and future panel development.

## 2. Three responsibility layers

### Layer A — Logic Modules / LOGIC SLOT

Four independent role definitions:
1. ENTRY
2. GRID
3. MANAGE
4. EXIT

LOGIC PARTS express strategy mechanics and decisions: indicator conditions, position state, distance/lot mechanics, trailing/TP/SL mechanics, branch/action semantics, and references to Filter results where required.

A Logic Module does **not own the numeric configuration of shared filters** and does **not own mandatory Global Safety thresholds**.

### Layer B — FILTER Panel

FILTER Panel owns shared filter configuration, for example:
- trading/session time filter
- news filter
- spread filter
- weekday/day filter
- other reusable common filters added later

The Filter Panel answers typed current-state results such as:
- `FILTER_TIME_OK`
- `FILTER_NEWS_OK`
- `FILTER_SPREAD_OK`
- `FILTER_DAY_OK`

LOGIC PARTS may reference these results to decide **where and when a configured filter applies**.

Example:

```text
ENTRY:
CYCLE_NEW
AND FILTER_TIME_OK
AND FILTER_NEWS_OK
AND FILTER_SPREAD_OK
AND ATR_RANGE
AND RSI_THRESHOLD
AND BUY
```

GRID may intentionally omit `FILTER_TIME_OK` if the strategy allows management/grid continuation outside the new-entry session.

Thus:
- Filter Panel = **what the filter condition/configuration is**
- Logic Part = **where/when that filter result is required**

Do not duplicate filter numeric settings inside each role definition unless a future design explicitly defines a role-local filter rather than a shared Filter Panel filter.

### Layer C — Expert Properties / Global Safety

Mandatory EA/account-wide protection is configured outside LOGIC SLOT and outside FILTER Panel.

Current O01 safety baseline:
- Warning DD = 8%
- Grid Pause DD = 12%
- Emergency Close DD = 15%

The 15% Emergency Close is a top-level safety action. It must not depend on the user remembering to place an EXIT Part or Filter Part.

The 12% Grid Pause is also a Global Safety state applied to GRID execution permission. It is not a required user-placed GRID Part.

The 8% Warning is Global Safety telemetry/state, not a strategy decision Part.

Global Safety must remain effective regardless of which ENTRY/GRID/MANAGE/EXIT definitions are selected.

## 3. Evaluation hierarchy

Conceptual evaluation:

```text
Market / account / broker snapshot
          |
          +--> Global Safety state
          |      Warning 8%
          |      Grid Pause 12%
          |      Emergency Close 15%
          |
          +--> Filter Engine
          |      TIME / NEWS / SPREAD / DAY / ...
          |      -> typed FILTER_* results
          |
          +--> Logic Builder
                 ENTRY
                 GRID
                 MANAGE
                 EXIT
                 using FILTER_* reference Parts where placed
          |
          v
Safety arbitration / Execution Adapter
```

Emergency Close has priority over normal strategy logic.

## 4. Filter application timing

The Builder controls filter application by placement of Filter-reference Parts.

Examples:

### New ENTRY only
Place `FILTER_TIME_OK` in ENTRY and omit it from GRID/MANAGE/EXIT.

### ENTRY and GRID news block
Place `FILTER_NEWS_OK` in ENTRY and GRID.

### Spread required before opening/adding positions
Place `FILTER_SPREAD_OK` in ENTRY and GRID, but normally not in EXIT.

### EXIT safety
Normal EXIT logic should generally remain executable even when shared entry filters are blocked. A Filter Part is used in EXIT only when the strategy explicitly requires it.

This provides per-role/per-branch timing without duplicating Filter Panel configuration.

## 5. O01 migration rule

O01 source currently contains checks that historically live inside the monolithic strategy. During Builder migration, classify each behavior by responsibility rather than mechanically turning every source condition into a Logic Part.

### Logic Module candidates
- CYCLE_NEW / position-state conditions
- ATR/RSI and other strategy indicators
- SIDE/POSITION count
- grid distance mechanics
- lot progression mechanics
- trailing/TP/SL strategy mechanics
- BUY/SELL/ADD/CLOSE strategy actions

### Filter references
Historical O01 checks for shared time/news/spread behavior should migrate to `FILTER_*_OK` reference Parts connected to Filter Panel state, where the desired role/timing is expressed by Part placement.

### Global Safety
Historical O01 Warning 8%, Grid Pause 12%, Emergency Close 15%, emergency lock/post-emergency protection belong to Global Safety / Expert Properties and host state, not to user-removable strategy Parts.

## 6. Anti-duplication rules

Do not implement the same setting independently in:
- Filter Panel and LOGIC SLOT, or
- Global Safety and LOGIC SLOT.

A Logic Part may **reference a shared state**, but should not silently own a duplicate numeric configuration.

Examples:
- Good: `FILTER_NEWS_OK` reads Filter Engine result.
- Bad: each ENTRY module separately stores the same shared news-before/news-after minutes.
- Good: GRID execution checks Global Safety `grid_pause_active`.
- Bad: user must place `DD_BELOW=12` in every GRID definition for safety to work.
- Good: Emergency Close executes at Global Safety layer.
- Bad: 15% close works only if an EXIT module contains an emergency Part.

## 7. Track A parity implication

Reference O01 parity must compare **effective behavior**, not insist that the Builder uses the same monolithic ownership structure.

If original O01 checks Time/News/Spread internally but Builder obtains equivalent state from Filter Engine, parity can PASS when the effective decision/timing is equivalent and evidence proves the same result.

Likewise, 8/12/15 safety parity is validated at Global Safety level, not by requiring those conditions inside role definitions.

## 8. Track B implementation implication

Before adding a missing Part, classify it:

- **L = Logic Part**
- **F = Filter-reference Part**
- **G = Global Safety / Expert Property**
- **H = Host/Execution infrastructure**

Only L and F belong in the normal Logic Parts picker.

F Parts expose a result/reference; their configuration remains in FILTER Panel.

G/H items must not be added merely to make a 40-Part O01 recipe visually resemble the monolithic source.

## 9. New-panel implication

The future one-panel design must preserve separate functional ownership:
- EA SLOT selects strategy/runtime assignment
- LOGIC SLOT stores ENTRY/GRID/MANAGE/EXIT definitions
- EA LOGIC / EA PARTS edits those definitions
- FILTER configures shared filters
- Expert Properties owns Global Safety and other EA-wide settings

The panel may visually integrate access, but data ownership must remain separated.

## 10. Required development check

Before every Track B Part addition:
1. read this document,
2. classify L/F/G/H,
3. confirm no duplicate owner exists,
4. add only the minimum generic interface required,
5. test SAVE/LOAD and Interpreter semantics,
6. confirm Global Safety remains independent.

This architecture decision overrides earlier provisional Track B wording that treated every O01 gate as a required strategy Part.
