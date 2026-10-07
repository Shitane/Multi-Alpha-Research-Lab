# B-P0-2H — LOGIC SLOT validity and future-panel lamp contract

Date: 2026-10-08
Status: SOURCE AUDIT COMPLETE / IMPLEMENTATION NOT YET TESTED

## Confirmed source findings

- `Include/Builder/MultiAlpha_Module_Library_Store_v1_00.mqh` stores 4 roles x 50 slots x 40 Parts, with saved/enabled/name/Part/parameter fields and in-memory SaveDefinition/LoadDefinition.
- `IsSaved` and `IsEnabled` are **not** semantic Interpreter validity checks. Existing state enum distinguishes EMPTY, SAVED_DISABLED and SAVED_ENABLED, but has no INVALID state.
- `Include/Builder/MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh` has 50 workspaces, 4 roles and 40 Parts; PutRole/GetRole are in-memory, not persistent disk save.
- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_04.mqh` validates FILTER_NEW_OK only in ENTRY and FILTER_ADD_OK only in GRID.
- `Include/Builder/MultiAlpha_Builder_Interpreter_v1_05.mqh` has ENTRY branch/action validation, not a generic four-role validity engine.
- New-panel specification requires 100 LOGIC SLOTs **per role**, 60 EA SLOTs, and lamp GREEN only for saved and semantically VALID definitions. Existing 50-slot store is not the final capacity.

## Mandatory status contract

Role-specific LOGIC SLOT:
- EMPTY (not saved) -> lamp OFF.
- SAVED + Interpreter INVALID -> lamp RED; retain definition for editing.
- SAVED + Interpreter VALID -> lamp GREEN, regardless of EA SLOT ON/OFF.
- A saved/ENABLED flag alone must never light GREEN.

EA SLOT:
- GREEN iff all four referenced role-specific LOGIC SLOTs are SAVED + VALID.
- Missing/invalid role -> not green. ON/OFF independent of validity lamp.
- No fallback to another slot.

GRID:
- A single GRID OFF Part is a complete VALID GRID definition, with no addition action.
- GRID ON alone is not automatically a complete valid grid strategy.
- Global DD 12% Grid Pause remains independent.

## Next safe implementation gate

Create a **headless** role validity evaluator and deterministic NoOrders tests first. Do not connect broker execution or build new panel UI yet.

Tests required: EMPTY; saved-invalid; saved-valid ENTRY; GRID OFF alone valid; GRID ON alone incomplete; EA SLOT four-role aggregate; invalid one role -> aggregate not green; EA SLOT disabled but four valid -> green; save/load retains semantic identity.

Do not claim disk persistence or 100/60 capacities until implemented and tested. Use versioned files and preserve v3_45 demo unchanged.
