# Multi Alpha New Panel - Basic Design Specification v1.00

## Status
This document records the mutually confirmed basic design for the future Multi-Alpha panel architecture.

It does **not** replace the current O01 / Builder completion work. The current EA LOGIC / EA PARTS / Interpreter / Runtime path must first be completed and validated. Working internal components should then be reused from the new panel rather than rewritten without cause.

Current development checkpoint/reference:
`Parity_Tests/MultiAlpha/MA_LD2A_SlotBasicInfoFix_v3_11.mq5`

## 1. New panel direction
The current product uses left and right panels to switch functions.

The future panel will consolidate the operating workspace into **one panel on the left side**.

Target functional views:
- EA SLOT
- LOGIC SLOT
- EA LOGIC
- EA PARTS
- FILTER

This is a UI/workspace reorganization, not a change to the underlying EA concept.

In particular, the current EA LOGIC / EA PARTS implementation should be reused if O01 reproduction, Interpreter validation and runtime testing show no functional defect.

## 2. Core strategy concept
The core Multi-Alpha concept remains:

**ENTRY + GRID + MANAGE + EXIT -> original EA strategy**

Canonical role order:
1. ENTRY
2. GRID
3. MANAGE
4. EXIT

EA SLOT does not edit the logic itself. It references independently stored LOGIC SLOT definitions for these four roles.

Example:
`ENTRY #001 | GRID #002 | MANAGE #003 | EXIT #004`

## 3. EA SLOT

### 3.1 Capacity
EA SLOT capacity is:
- #01-#60
- 20 visible at one time
- pages: #01-#20 / #21-#40 / #41-#60
- UP / DOWN page navigation

### 3.2 EA SLOT responsibility
Each EA SLOT stores/owns runtime/configuration information including:
- EA SLOT ON/OFF
- Symbol input and resolved broker symbol
- Magic Number
- ENTRY LOGIC SLOT reference
- GRID LOGIC SLOT reference
- MANAGE LOGIC SLOT reference
- EXIT LOGIC SLOT reference
- FILTER settings
- other EA-SLOT-specific settings defined later

EA SLOT does not contain a duplicated copy of the referenced logic.

### 3.3 ON/OFF and runtime validity
EA SLOT ON/OFF controls whether the EA SLOT is intended to run.

Editing and saving remain available even when EA SLOT is OFF.

The EA SLOT may be switched ON even when one or more of its four referenced LOGIC SLOTs are unusable.

However, actual EA execution is permitted only when all four required role references are usable:

`ENTRY VALID + GRID VALID + MANAGE VALID + EXIT VALID -> runtime allowed`

Example:
`ENTRY VALID + GRID VALID + MANAGE VALID + EXIT INVALID -> EA SLOT may remain ON, but runtime must not execute`

Do not automatically substitute another LOGIC SLOT.

## 4. Magic Number manual override
EA SLOT provides three UI elements:
1. manual numeric input
2. ENTER
3. current Magic Number display

ENTER confirms the entered value and updates the EA SLOT's current Magic Number.

This field is not an EA SLOT-number selector.

## 5. Symbol Resolver
EA SLOT provides three UI elements:
1. manual symbol input
2. ENTER
3. resolved broker-symbol display

The user may enter a symbol name such as:
- US500
- USA30
- XAUUSD
- XAUUSD-m

ENTER sends the input to Symbol Resolver.

Symbol Resolver maps the logical/user-entered symbol to the broker's usable symbol, and the resolved symbol is displayed and used by that EA SLOT.

Strategy logic must not hard-code broker suffixes.

## 6. LOGIC SLOT

### 6.1 Independent capacity
LOGIC SLOT is independent for each canonical role:
- ENTRY #001-#100
- GRID #001-#100
- MANAGE #001-#100
- EXIT #001-#100

Total capacity: **400 independent LOGIC SLOTs**.

Internally these are separate namespaces, e.g.:
- ENTRY-001
- GRID-001
- MANAGE-001
- EXIT-001

The same numeric ID in different roles does not mean the same logic.

### 6.2 Paging
Each role displays 20 LOGIC SLOTs at a time.

Target pages:
- #001-#020
- #021-#040
- #041-#060
- #061-#080
- #081-#100

UP / DOWN changes the visible page.

### 6.3 LOGIC SLOT status
LOGIC SLOT has no separate ENABLED state.

Status/lamp concept:
- unsaved -> lamp OFF
- SAVED + VALID -> green lamp, usable
- SAVED + INVALID -> red lamp, saved work-in-progress, not runtime-usable

INVALID logic is allowed to be saved.

### 6.4 SAVE-time validation
When SAVE SLOT is pressed for a LOGIC SLOT:
1. save the selected logic definition/settings
2. run Interpreter validation
3. immediately update VALID/INVALID status and the green/red lamp

An INVALID result must not reject or erase the saved work-in-progress definition.

## 7. EA LOGIC and EA PARTS
The current Builder concept is retained.

Confirmed relationship:

**LOGIC SLOT -> EA LOGIC manages/selects the logic -> EA PARTS edits that logic's Parts/order/parameters -> Interpreter validates -> definition is saved to the selected LOGIC SLOT**

EA LOGIC is the management/selection entry for saved logic/module definitions.

EA PARTS is where the selected logic's individual Parts, ordering and parameters are edited.

The new one-panel UI should call/reuse the existing working Builder components where practical. Do not rebuild them solely because the panel layout changes.

## 8. FILTER

### 8.1 Ownership
FILTER is primarily an **EA SLOT function**.

LOGIC SLOT does not have a separate dedicated FILTER configuration.

If filter-like logic is required as part of constructing ENTRY / GRID / MANAGE / EXIT logic itself, it belongs in EA PARTS (LOGIC PARTS) as part of that logic definition.

### 8.2 EA SLOT FILTER behavior
Each EA SLOT can open/edit its FILTER panel.

FILTER includes:
- overall FILTER ON/OFF
- individual Filter Part ON/OFF

Effective behavior:
- overall OFF -> filter inactive
- overall ON + zero individual Filter Parts ON -> filter inactive
- overall ON + one or more individual Filter Parts ON -> filter active

When active, the EA SLOT list should visually indicate FILTER active (for example, a green background).

FILTER remains editable/saveable even if the EA SLOT itself is OFF.

## 9. SAVE SLOT / SAVE ALL

### 9.1 EA SLOT screen
The EA SLOT screen provides:
- SAVE SLOT
- SAVE ALL

**EA SLOT / SAVE SLOT**
Saves only the currently selected EA SLOT, including its EA-SLOT-specific configuration such as:
- ON/OFF
- Symbol / resolved symbol information
- Magic Number
- ENTRY / GRID / MANAGE / EXIT LOGIC SLOT references
- FILTER settings
- other EA-SLOT-specific settings

It does not save/edit the contents of the referenced LOGIC SLOTs.

**EA SLOT / SAVE ALL**
Saves the corresponding configuration for all EA SLOT #01-#60, including FILTER settings.

### 9.2 LOGIC SLOT screen
The LOGIC SLOT screen also provides:
- SAVE SLOT
- SAVE ALL

**LOGIC SLOT / SAVE SLOT**
Saves the currently selected role-specific LOGIC SLOT, for example MANAGE #001, including the EA LOGIC / EA PARTS definition needed to reproduce that logic:
- ordered Parts
- Part parameters
- logic/module definition metadata required for reproduction
- associated logic settings

It then performs Interpreter validation and immediately updates VALID/INVALID status.

There is no dedicated LOGIC SLOT FILTER to save.

**LOGIC SLOT / SAVE ALL**
Saves all logic definitions/settings for:
- ENTRY #001-#100
- GRID #001-#100
- MANAGE #001-#100
- EXIT #001-#100

That is all 400 LOGIC SLOTs.

## 10. Complete environment reproduction
The persistence design goal is:

**EA SLOT SAVE ALL + LOGIC SLOT SAVE ALL = enough saved configuration to reproduce the complete Multi-Alpha user setup**

EA SLOT SAVE ALL owns the 60 runtime/configuration containers and their FILTER settings.

LOGIC SLOT SAVE ALL owns the 400 reusable role-specific logic definitions.

The two persistence domains must remain conceptually separate.

## 11. Startup restoration and portable backup
On MT5 startup, Multi-Alpha should automatically restore the state that was saved when the previous MT5 session was closed / last persisted.

Persistence must also support a portable backup that can be moved to another PC so that the same Multi-Alpha setup can be reproduced there.

Exact file format, versioning, migration and import/export UI are implementation details to be designed later. The requirement for automatic restoration and portable backup is fixed.

## 12. Current-development-first rule
The future panel must not interrupt or invalidate the current development sequence.

Fixed sequence:
1. use the current v3_11-era implementation as the development checkpoint
2. reconfirm O01 behavior from actual source
3. reproduce O01 through the current EA LOGIC / EA PARTS Builder path
4. verify Parts, order and Interpreter behavior carefully
5. complete the Runtime path required for demo-account operation
6. perform actual demo validation
7. inspect/clean/refactor code after functional confirmation
8. then construct the new left-side one-panel UI
9. reuse confirmed EA LOGIC / EA PARTS / Interpreter / Runtime components rather than replacing them without a demonstrated need

## 13. Safety and runtime constraints
During construction/validation, preserve the established safety approach including NO_ORDERS / VIRTUAL NOT FILL where applicable.

Global Safety remains outside role logic:
- Warning DD 8%
- Grid Pause DD 12%
- Emergency Close DD 15%

Global Safety is not an EXIT LOGIC SLOT.

## 14. Open UI details
The following are intentionally not fixed by this document unless separately agreed later:
- exact pixel geometry/colors/spacing of the new panel
- exact action/label of every row-level button
- purpose of currently undefined blank fields in the EA SLOT mockup
- exact backup file format/import-export UI
- detailed FILTER Parts list and FILTER panel layout

These details must not be invented during implementation; confirm them when their development gate is reached.


## 15. Confirmed green-lamp validity rules and GRID OFF Part (2026-10-08)

This section supplements the user-confirmed new-panel mockups and takes precedence over any older interpretation that GRID must contain an active grid-addition algorithm to be VALID. It does not alter the four-role requirement or global DD safety.

### 15.1 LOGIC SLOT row lamp

Each role-specific LOGIC SLOT row (#001-#100) has a lamp in the blank space immediately next to its slot number, as shown in the LOGIC SLOT mockup.

- **Green ON**: the slot contains a saved, Interpreter-validated, usable logic definition.
- **Red ON**: a saved definition exists but is INVALID, consistent with section 6.3.
- **Lamp OFF**: no saved definition.
- Evaluate independently for ENTRY, GRID, MANAGE and EXIT. Matching slot numbers in different roles are independent.
- Recompute immediately on SAVE SLOT/validation and on LOAD/restore. A green lamp must not be inferred merely from nonempty text, a slot number, or an ON switch.

### 15.2 EA SLOT LOGIC lamp

The EA SLOT list has a LOGIC indicator space for each EA SLOT row, as shown in the EA SLOT mockup.

The indicator is **green only if all four referenced role-specific LOGIC SLOT definitions are usable**:
`ENTRY VALID && GRID VALID && MANAGE VALID && EXIT VALID`.

- If any referenced slot is absent, unsaved, INVALID or otherwise unusable, the EA SLOT LOGIC indicator must **not** be green.
- EA SLOT ON/OFF is independent of this LOGIC validity indicator. An OFF EA SLOT can still display green if its four referenced logic definitions are valid.
- This is a visual summary of logic completeness, not an execution authorization by itself. Runtime still applies EA SLOT ON/OFF, Filter, global safety and execution gates.
- Update immediately when any referenced LOGIC SLOT validity changes, or when the EA SLOT's role references change, and after saved state is restored.
- Do not substitute another LOGIC SLOT to make the lamp green.

### 15.3 Explicit GRID ON/OFF Logic Part

EA PARTS must provide a dedicated **GRID ON/OFF** Part for the GRID role, allowing a strategy with no averaging/grid additions to have a valid GRID LOGIC SLOT.

- A GRID definition containing **one valid `GRID OFF` Part** is a complete, valid no-grid definition, even when no other GRID Parts are present.
- SAVE SLOT and Interpreter validation must accept this definition as VALID, light the GRID LOGIC SLOT lamp green, and allow the EA SLOT LOGIC lamp to be green if ENTRY, MANAGE and EXIT are also valid.
- At runtime, `GRID OFF` must deterministically disable all grid-addition decisions/actions for that GRID definition; it must not disable ENTRY, MANAGE or EXIT.
- `GRID ON` selects grid-enabled behavior, but does **not** by itself establish a complete valid grid-addition strategy; its required supporting conditions/actions must still pass Interpreter validation.
- Avoid contradictory configurations: when `GRID OFF` is present, it has precedence over other GRID addition Parts; validation and runtime must not permit any GRID ADD order from that definition. The detailed editing UX for contradictory Parts can be decided at implementation time, but safety behavior is fixed.
- `GRID OFF` is a strategy-level choice and is **distinct** from the global 12% DD Grid Pause. Global Safety remains mandatory and cannot be bypassed by GRID ON/OFF.

### 15.4 Acceptance gates

The following are design requirements, **not yet implementation PASS claims**:

1. Save a GRID LOGIC SLOT containing only `GRID OFF` -> Interpreter VALID -> GRID row lamp green.
2. Reference that GRID slot from an EA SLOT whose other three roles are VALID -> EA SLOT LOGIC lamp green.
3. Make any one of the four role references INVALID -> EA SLOT LOGIC lamp not green.
4. Turn EA SLOT OFF while keeping all four roles VALID -> LOGIC lamp remains green; execution remains disabled.
5. NoOrders/runtime decision test with `GRID OFF` -> GRID addition always denied; ENTRY/MANAGE/EXIT remain unaffected.
6. SAVE/LOAD/restart -> same GRID OFF definition, validation and lamp states restored.

Keep the current O01/Builder completion and NoOrders gates as the active development priority; implement these panel rules when the relevant Builder validation/persistence and new-panel gates are reached.
