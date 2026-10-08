# B-P0-2K — MANAGE / EXIT Interpreter source audit

Date: 2026-10-08
Status: SOURCE AUDIT PASS / GENERAL VALIDATOR NOT IMPLEMENTED

## Source reviewed

- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_01.mqh`: MANAGE allows SIDE_COUNT, POSITION_COUNT, AVG_PRICE, LAST_PRICE, MOVE_POINTS, SINGLE_TRAILING, BASKET_TRAILING; EXIT allows SIDE_COUNT, POSITION_COUNT, AVG_PRICE, MOVE_POINTS, VIRTUAL_SL, FIXED_TP, SINGLE_TRAILING, BASKET_TRAILING, CLOSE_SIDE.
- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_03.mqh`: MANAGE adds OVERLAP; EXIT adds BASKET_FIXED_TP, SINGLE_MONEY_TP, CLOSE_OPPOSITE.
- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_04.mqh`: FILTER references are ENTRY/GRID only.
- `Include/Builder/MultiAlpha_Builder_Saved_Manage_Action_Evaluator_v1_00.mqh`: legacy O01-specific Manage decision logic; requires MAX_ORDERS, FIXED_DIST, DYNAMIC_DIST, LOT_MULT, ADD GRID action. These are not a complete generic MANAGE grammar and include grid-addition responsibilities.
- `Include/Builder/MultiAlpha_Builder_Saved_Exit_Action_Evaluator_v1_00.mqh`: legacy O01-specific Exit evaluator; requires VIRTUAL_SL, FIXED_TP, SINGLE_TRAIL, BASKET_TRAIL, CLOSE action. Not a generic four-role validator.
- `Include/Builder/MultiAlpha_Logic_Validity_v1_00.mqh`: non-ENTRY roles other than GRID OFF fail closed with ROLE_INTERPRETER_NOT_PROVEN.

## Architectural consequence

Do not infer MANAGE or EXIT semantic validity from SaveDefinition, enabled flags, or schema acceptance alone. Do not reclassify O01's legacy Manage grid-addition code as a universal MANAGE Interpreter. The four-role runtime gate must remain fail-closed until role-specific grammar, action coverage, and dispatcher semantics are tested.

## Next implementation sequence

1. Define a role-specific, ordered 40-Part MANAGE and EXIT grammar and accepted action semantics from existing schema and actual generic runtime usage; distinguish trailing state updates from close actions.
2. Add versioned headless validator, with tests for empty, malformed, incomplete, valid representative, unsupported parts and role crossing.
3. Connect validated saved-role results to B-P0-2J aggregate and retest NoOrders.
4. Only after generic GRID ON, MANAGE, EXIT are all proven may four saved definitions yield GREEN/ORANGE execution eligibility. Then verify new-panel display and actual runtime separately.

GRID OFF remains a valid no-grid GRID role with ORANGE status; it is not an extra order-rejection filter. v3_45 demo must remain unchanged.
