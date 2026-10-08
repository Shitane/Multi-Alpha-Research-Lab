# Multi-Alpha 100 SLOT / 100 PARTS — legacy migration audit v1.00

**Product specification fixed:** 100 EA SLOTs, 100 LOGIC SLOTs per each of 4 roles, 100 ordered Parts per LOGIC SLOT. See section 16 of `Docs/MultiAlpha_New_Panel_Basic_Design_v1_00.md`.

**Status:** source inspection and central constants created. No legacy module rewired. No compile, runtime, persistence or trading parity PASS claimed.

## Verified hardcoded limits from GitHub source

| Component | Existing implementation | Required treatment |
|---|---|---|
| `MultiAlpha_Module_Library_Store_v1_00.mqh` | `MA_MLS100_SLOT_COUNT=50`, `MA_MLS100_PART_COUNT=40`, `m[4][50]`, `part[40]`, `param[40]`, loops 50/40 | Versioned 100×100 per-role store; preserve legacy adapter/roundtrip |
| `MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh` | 50 instances × 4 roles × 40 Parts; loops/bounds 50/40 | Audit whether instance represents EA SLOT or logic workspace; do not silently reinterpret identity |
| `MultiAlpha_Logic_Validity_v1_00.mqh` | exact ArraySize 40, loop 40; non-ENTRY fail-closed | 100-aware version with GRID OFF conflict protection and evidence-backed role validity |
| `MultiAlpha_Builder_Interpreter_v1_05.mqh` | `MA_BUILDER_INTERPRETER_103_SLOTS=40`, temporary branch-action array 40 | New version with 100 capacity and branch-index bounds tests; preserve 40-Part behavior |
| `MultiAlpha_Manage_Exit_Grammar_v1_00.mqh` | exact 40 and loop 40 | Versioned 100-Part structural validator; **not** semantic/runtime validity proof |
| `Docs/MultiAlpha_New_Panel_Basic_Design_v1_00.md` | older 60 EA SLOT references, 20-per-page / 3 pages, SAVE ALL 60 | Section 16 overrides: 100 EA SLOT, 5 pages, SAVE ALL 100 |
| `Include/Builder/MultiAlpha_Capacity_v1_00.mqh` | NEW canonical 100/100/100 limits and 20/page | Use in new modules after tests, not a retroactive upgrade of old modules |

## Migration risks / gates

1. **Do not bulk replace numeric 40**: 40 may mean a count, an unrelated parameter or a fixed legacy array; audit each code path.
2. **Do not bulk replace 50/60**: distinguish EA SLOT containers, per-role LOGIC SLOT storage and UI pages. IDs are 1-based; arrays 0-based.
3. **RAM and stack**: 400 role slots × 100 Parts × 2 strings plus metadata is nontrivial; avoid huge value copies, use measured memory/runtime tests and safe allocation.
4. **Compatibility**: legacy 40 Parts retained at indices 0..39; indices 40..99 EMPTY. No order/parameter changes; test AND/OR branch evaluation, including Part 100.
5. **Saved definitions**: existing memory stores are not disk persistence. Design explicit format version and migration before claiming restart/PC backup.
6. **Boundaries**: slots 1, 50, 51, 60, 61, 100 and invalid 0/101; Parts 1, 40, 41, 100 and invalid 101; independent role ID collision.
7. **Safety**: no broker orders, no silent fallback; v3_45 untouched; GRID OFF ORANGE retained. Global DD8/12/15 remains separate.
8. **Runtime validity**: do not promote saved/schema-valid MANAGE/EXIT to GREEN until complete generic semantics proven. Prior B-P0-2K test is still 40-based and must be retested under new capacity.

## Implementation order

A. New versioned 100-Part, 100-slot store and migration adapter, NoOrders tests.
B. New versioned 100-Part ENTRY branch Interpreter and exact 40→100 parity tests.
C. New versioned 100-Part GRID/MANAGE/EXIT grammar + runtime action semantics, tests.
D. EA SLOT 100 configuration, four-role reference resolution, filter/symbol/magic isolation.
E. Versioned disk persistence and restore/portable backup.
F. UI paging and actual runtime wiring; NoOrders, demo parity, performance tests.

Every step requires explicit compile and runtime evidence before marking PASS.
