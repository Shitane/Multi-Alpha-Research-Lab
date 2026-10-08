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


## Gate A1 — user-provided MetaEditor and MT5 evidence (2026-10-08)

Test EA: `Parity_Tests/MultiAlpha/MultiAlpha_Capacity100_Store_NoOrders_v1_00.mq5`.
Source under test: `Include/Builder/MultiAlpha_Module_Library_Store_v1_01.mqh`.
MetaEditor screenshot: **0 errors, 0 warnings** (578 ms).
Runtime user log: **2026.10.08 20:35:27.424**, XAUUSD-m,M1, **13/13 [MA_CAP100_CASE] PASS**, final:
`[MA_CAP100_PASS] role_slots=100 parts=100 legacy_import=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

Observed cases: SAVE_SLOT_100, LOAD_SLOT_100, PART_BOUNDARIES, META_PRESERVED, ROLE_ISOLATED, SLOT_101_REJECTED, SLOT_ZERO_INDEX_VALID, WRONG_ROLE_REJECTED, IMPORT_40, LOAD_IMPORT, LEGACY_40_PLUS_EMPTY_60, ROLE_SLOT_INDEPENDENT, REJECT_40_DIRECT_SAVE.

**Gate A1 PASS — in-memory store test only.** This does not certify EA SLOT configuration capacity, disk persistence, restart restore, UI, Interpreter 100-Part evaluation, four-role runtime execution, or 40→100 strategy-decision parity. Legacy 2G/2H/2I/2J PASS logs were also provided, but those are legacy 40-Part gates and must not be used as 100-Part proof.

**Next gate A2:** audit and version 100-Part ENTRY Interpreter; compare 40→100 branch/action outcomes and boundaries, NoOrders. Preserve v3_45 unchanged.


## Gate A2 — ENTRY 100-Part Interpreter evidence (2026-10-08)

Test: `Parity_Tests/MultiAlpha/MultiAlpha_Entry100_Interpreter_NoOrders_v1_00.mq5`.
Source: `Include/Builder/MultiAlpha_Builder_Interpreter_v1_06.mqh`.
User MetaEditor screenshot: **0 errors, 0 warnings** (783 ms).
User MT5 log: **2026.10.08 20:42:29.103**, XAUUSD-m,M1, **10/10 [MA_ENTRY100_CASE] PASS**:
LEGACY_40_EVALUATES, EXTENDED_100_EVALUATES, LEGACY_40_TO_100_PARITY, SELL_BRANCH_PARITY, PART_100_ACTION, PART_100_SELL, CROSS_40_41_BOUNDARY, TRAILING_OR_REJECT, ACTION_ONLY_REJECT, SHORT_40_REJECT.
Final line: `[MA_ENTRY100_PASS] legacy_parity=PASS part100=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A2 PASS for tested ENTRY branches and boundaries only.** This does not prove full O01 source parity, 100-Part schema coverage, live trading, persistence, GRID/MANAGE/EXIT Interpreter semantics, or UI wiring. v3_45 unchanged.

**Next gate:** inspect existing GRID/MANAGE/EXIT schema and runtime action evaluators; migrate structural grammar to 100 Parts without prematurely marking semantic validity GREEN. EA SLOT 100 configuration still pending.


## Gate A3 — MANAGE / EXIT 100-Part structural grammar (2026-10-08)

Source: `Include/Builder/MultiAlpha_Manage_Exit_Grammar_v1_01.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_ManageExit100_Grammar_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (1229 ms).
User MT5 Runtime log **2026.10.08 20:49:46.768**, XAUUSD-m,M1: **10/10 [MA_ROLE100_CASE] PASS**:
MANAGE_EMPTY, MANAGE_PART100, MANAGE_WRONG_ROLE, EXIT_CROSS_40_41, EXIT_TRAILING_OPERATOR, EXIT_ACTION_ONLY, EXIT_CONDITION_ONLY, INVALID_ROLE, SHORT_40_REJECT, EMPTY_PARAMS_REJECT.
Final: `[MA_ROLE100_PASS] structural_only=PASS RUNTIME_SEMANTICS_PROVEN=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A3 structural-only PASS.** MANAGE and EXIT generic runtime action semantics, GREEN validity, full AND/OR semantics, and O01 parity **NOT PROVEN**. Prior ENTRY A2 10/10 PASS reconfirmed from same user log.

**Next:** inspect and version GRID 100-Part validation/decision. Legacy GRID interpreter is fixed 40 and enforces one exact 33-Part O01 plan; GRID OFF is a distinct valid no-grid mode with ORANGE status, not a generic addition veto. Do not certify generic GRID until evidence.


## Gate A4 — GRID 100-Part compatibility gate (2026-10-08)

Source: `Include/Builder/MultiAlpha_Grid100_Compatibility_Gate_v1_00.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_Grid100_Compatibility_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (1176 ms).
User MT5 log: **2026.10.08 20:53:58.697–.698**, XAUUSD-m,M1, **10/10 [MA_GRID100_CASE] PASS**:
GRID_OFF_AT_PART100, GRID_OFF_NO_ADD, GRID_OFF_SELL_NO_ADD, GRID_OFF_CONFLICT, GRID_OFF_DUPLICATE, UNPROVEN_PART41_REJECT, GRID_OFF_PARAMS_REJECT, EMPTY_PARAMS_REJECT, EMPTY_GRID_REJECT, SHORT_40_REJECT.
Final: `[MA_GRID100_PASS] grid_off=PASS fail_closed=PASS LEGACY_O01_RUNTIME_PARITY_PROVEN=0 GENERIC_GRID_RUNTIME_PROVEN=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A4 PASS only for GRID OFF and conservative fail-closed rejection tests.** Legacy O01 GRID runtime parity and arbitrary generic 100-Part GRID semantics **NOT PROVEN**. The test does not certify generic GRID green-lamp eligibility or live trading. v3_45 untouched.

**Next priority:** implement/verify independent 100 EA SLOT configuration storage and four-role references, with 100th EA SLOT and 50/51/60/61 boundary tests. Avoid conflating EA SLOT count with the already-tested 100-per-role LOGIC SLOT store.


## Gate A5 — 100 EA SLOT independent four-role reference store (2026-10-08)

Source: `Include/Builder/MultiAlpha_EA_Slot_Store_v1_00.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_EASlot100_Store_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (548 ms).
User MT5 log: **2026.10.08 20:58:00.484**, XAUUSD-m,M1, **15/15 [MA_EASLOT100_CASE] PASS**:
SAVE_SLOT_100, LOAD_SLOT_100, FOUR_REFS_INDEPENDENT, NAME_ENABLED_ROUNDTRIP, UNSAVED_99_OFF, SLOT_0_REJECT, SLOT_101_REJECT, BOUNDARIES_1_50_51_60_61_100, REF_0_REJECT, REF_101_REJECT, REF_COUNT_REJECT, SAVE_DISABLED, DISABLED_NOT_ENABLED, CLEAR_100, INVALID_SAVE_ATOMIC.
Final: `[MA_EASLOT100_PASS] ea_slots=100 refs=4 boundaries=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A5 PASS for in-memory EA SLOT storage only.** LOGIC SLOT definition resolution, four-role Interpreter semantic validity, FILTER mapping, disk persistence/restart restore, multi-slot runtime, and live orders **NOT PROVEN**. v3_45 unchanged.

**Next gate A6:** design and verify disk persistence/reload with schema version and atomicity/fail-closed handling, preserving separate EA SLOT IDs and per-role LOGIC SLOT IDs; do not wire to v3_45 until verified.


## Gate A6 — EA SLOT 100 disk roundtrip and truncated-file rejection (2026-10-08)

Source: `Include/Builder/MultiAlpha_EASlot_Disk_v1_00.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_EASlot100_Disk_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (624 ms).
User MT5 tester log: **2026.10.08 21:01:27.428–.447**, XAUUSD-m,M1, **11/11 [MA_DISK100_CASE] PASS**:
SAVE_SLOT100_MEMORY, SAVE_SLOT51_MEMORY, DISK_WRITE, DISK_READ, RESTORE_100, RESTORE_51, UNSAVED_99, INVALID_FILENAME_REJECT, CORRUPT_FIXTURE_WRITE, TRUNCATED_REJECT, FAILED_LOAD_PRESERVES_100.
Final: `[MA_DISK100_PASS] disk_roundtrip=PASS corrupt_fail_closed=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A6 PASS for same-run EA SLOT-only disk roundtrip and truncated-file rejection.** The test rewrites its test file to a deliberately truncated fixture, and deletes it afterward. Actual terminal restart/reinitialization persistence, full LOGIC SLOT (100 Parts) definitions, FILTER data, arbitrary corruption/checksum validation, crash-safe rename guarantees, and live runtime remain **NOT PROVEN**. v3_45 untouched.

**Next:** inspect and implement LOGIC SLOT 100×100 versioned persistence with fail-closed loading, followed by multi-run restart evidence; avoid declaring the full workspace persistence complete based on this gate.


## Gate A7 — LOGIC SLOT 4 roles × 100 slots × 100 Parts disk roundtrip (2026-10-08)

Source: `Include/Builder/MultiAlpha_LogicSlot_Disk_v1_00.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_LogicSlot100_Disk_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (656 ms).
User MT5 tester log: **2026.10.08 21:09:29.440–.460**, XAUUSD-m,M1, **12/12 [MA_LOGICDISK100_CASE] PASS**:
SAVE_GRID_SLOT100, SAVE_MANAGE_SLOT51, DISK_WRITE, DISK_READ, RESTORE_GRID_PART100, RESTORE_MANAGE_41_100, ROLE_ISOLATION, UNSAVED_99, BAD_FILENAME_REJECT, CORRUPT_FIXTURE, TRUNCATED_REJECT, FAILED_LOAD_PRESERVES_GRID.
Final: `[MA_LOGICDISK100_PASS] roles=4 slots_per_role=100 parts=100 disk_roundtrip=PASS truncated_fail_closed=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A7 PASS for representative LOGIC SLOT in-run disk roundtrip and truncated-file rejection only.** No all-400-populated stress proof, checksum/bit-flip detection, restart proof, FILTER persistence, multi-file transactional consistency, role Interpreter runtime validity, or real orders. Test uses placeholder Parts to verify storage, not validated trading grammar. v3_45 unchanged.

**Next:** versioned checksums/bit-flip tests, multi-file consistency between EA SLOT refs and LOGIC definitions, and restart proof; preserve fail-closed semantics.


## Gate A8 — EA SLOT → four role LOGIC SLOT reference integrity (2026-10-08)

Source: `Include/Builder/MultiAlpha_Saved_Ref_Gate_v1_00.mqh`.
Test: `Parity_Tests/MultiAlpha/MultiAlpha_SavedRef100_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (618 ms).
User MT5 tester log: **2026.10.08 21:17:26.908**, XAUUSD-m,M1, **18/18 [MA_REF100_CASE] PASS**:
UNSAVED_EA_REJECT, SAVE_EA100, UNSAVED_ROLE_REJECT, SAVE_ROLE_0, SAVE_ROLE_1, SAVE_ROLE_2, SAVE_ROLE_3, FOUR_REFS_RESOLVE, RESOLVE_NOT_SEMANTIC_CERTIFICATION, ROLE_3_INDEX99, ROLE_3_INDEX100_REJECT, DISABLE_REFERENCED_ROLE, ROLE_OFF_REJECT, RE_ENABLE_ROLE, EA_OFF_SAVE, EA_OFF_REJECT, INVALID_EA0_REJECT, INVALID_EA101_REJECT.
Final: `[MA_REF100_PASS] structural_refs=PASS semantics_proven=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A8 PASS for in-memory structural reference resolution only.** EA LOGIC references are 1..100 and LOGIC library indices 0..99. The gate rejects missing/disabled roles and EA OFF. This does NOT establish Interpreter semantics, GRID OFF valid orange handling, persistence integrity across separate files, filter resolution, or runnable/live execution. v3_45 unchanged.

**Next:** address semantic validity and GRID OFF behavior explicitly before using structural resolution for runnable/lamp gating; separately test restored EA/LOGIC snapshots together and corruption/consistency.


## Gate A9 — Restored EA SLOT + LOGIC SLOT cross-file references (2026-10-08)

Test: `Parity_Tests/MultiAlpha/MultiAlpha_RestoredRef100_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (866 ms).
User MT5 tester log: **2026.10.08 21:21:50.262–.277**, XAUUSD-m,M1, **26/26 [MA_RESTORE_REF_CASE] PASS**:
EA100_SOURCE_SAVE; ROLE_SOURCE_SAVE_0..3; EA_DISK_SAVE; LOGIC_DISK_SAVE; EA_DISK_RESTORE; LOGIC_DISK_RESTORE; RESTORED_FOUR_REFS; RESTORED_STRUCTURAL_ONLY; GRID_OFF_PART100_PRESERVED; GRID_OFF_NOT_UNSAVED; GRID_OFF_NOT_GENERIC_OFF; REMOVE_REFERENCED_EXIT; MISSING_EXIT_REJECT; MISSING_EXIT_REASON; RESTORE_EXIT_MEMORY; DISABLE_MANAGE; DISABLED_MANAGE_REJECT; DISABLED_MANAGE_REASON; RE_ENABLE_MANAGE; EA_DISABLE; EA_OFF_REJECT; EA_OFF_REASON.
Final: `[MA_RESTORE_REF_PASS] cross_file_refs=PASS grid_off_storage=PASS semantics_proven=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A9 PASS only for representative same-run restored cross-file structural references.** GRID OFF storage remains saved/enabled, but GRID OFF semantic validation/orange lamp is NOT proven. No checksum or cross-generation snapshot consistency, terminal restart, complete 400-definition stress, FILTER persistence, or live orders. v3_45 unchanged.

**Next:** snapshot generation consistency and integrity checks, then GRID OFF semantic/lamp integration before runnable certification.


## Gate A10 — Snapshot pair generation and accidental corruption detection (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Snapshot_Manifest_v1_00.mqh` (warning fix commit `74da6c1`), `Parity_Tests/MultiAlpha/MultiAlpha_SnapshotPair100_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors / 0 warnings** (761 ms).
User MT5 Strategy Tester log: **2026.10.08 21:33:13.729–.766**, XAUUSD-m,M1, **15/15 [MA_PAIR100_CASE] PASS**:
EA_SETUP; LOGIC_SETUP; EA_SNAPSHOT_WRITE; LOGIC_SNAPSHOT_WRITE; MANIFEST_WRITE_G1; PAIR_G1_VALID; WRONG_GENERATION_REJECT; EA_CHANGE; EA_REWRITE; STALE_EA_REJECT; MANIFEST_WRITE_G2; PAIR_G2_VALID; BITFLIP_FIXTURE; BITFLIP_REJECT; MISSING_MANIFEST_REJECT.
Final: `[MA_PAIR100_PASS] generation_gate=PASS bitflip_detection=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A10 PASS (tested fixture only).** Manifest binds the EA and LOGIC snapshots with generation and size/Adler32 fingerprints, rejecting stale snapshot, wrong expected generation, single-byte change, or missing manifest. **NOT PROVEN:** startup fail-closed integration, power-loss/partial-write recovery, cryptographic tamper resistance, multi-process concurrency, comprehensive 100x400 persistence stress, semantic role validation, GRID OFF orange lamp, broker trading, or original O01 parity. v3_45 unchanged.


## Gate A11 — Verified pair load and destination preservation (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Verified_Pair_Load_v1_00.mqh` and `Parity_Tests/MultiAlpha/MultiAlpha_VerifiedPairLoad_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (922 ms).
User MT5 Strategy Tester log: **2026.10.08 21:38:31.815–.846**, XAUUSD-m,M1, **17/17 [MA_VERIFIED_LOAD_CASE] PASS**:
SOURCE_EA; SOURCE_GRID; DISK_EA; DISK_LOGIC; MANIFEST; DEST_SENTINEL; WRONG_GEN_REJECT; WRONG_GEN_PRESERVES; VALID_LOAD; VALID_EA_REPLACED; VALID_GRID_RESTORED; SOURCE_EA_CHANGE; STALE_DISK_WRITE; STALE_REJECT; STALE_PRESERVES_BOTH; MISSING_MANIFEST_REJECT; MISSING_PRESERVES.
Final: `[MA_VERIFIED_LOAD_PASS] verify_before_load=PASS reject_preserves_destinations=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A11 PASS for tested NoOrders fixtures only.** The separate verified-pair loader verifies manifest, stages EA and LOGIC parsing, reverifies manifest, and then applies both stores. Wrong generation, changed EA snapshot, and missing manifest are rejected while existing settings remain. **NOT PROVEN:** actual startup path calling this loader, concurrent modification during commit, process crash atomicity, semantic role validity, GRID OFF orange lamp, generic GRID runtime, live orders, or full O01 parity. v3_45 unchanged.

**Next:** test GRID OFF semantic validity + orange lamp in the saved four-role aggregation without treating structural resolution alone as runnable proof.


## Gate A12 — Saved GRID OFF lamp / EA preview aggregation (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Saved_Grid_Lamp100_v1_00.mqh`, `Parity_Tests/MultiAlpha/MultiAlpha_SavedGridLamp100_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors, 0 warnings** (1634 ms).
User MT5 Strategy Tester log: **2026.10.08 21:48:02.940**, XAUUSD-m,M1, **15/15 [MA_GRID_LAMP100_CASE] PASS**: UNSAVED_OFF, INVALID_REF_RED, SAVE_GRID_OFF, GRID_ORANGE, EA_UNSAVED, EA_SAVE, EA_PREVIEW_ORANGE, NOT_RUNNABLE, SAVE_CONFLICT, CONFLICT_RED, EA_CONFLICT_RED, SAVE_DISABLED, DISABLED_RED, EA_OFF_SAVE, EA_OFF_LAMP.
Final: `[MA_GRID_LAMP100_PASS] cases=15 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A12 PASS only for tested saved-definition lamp classification and EA preview.** GRID OFF is ORANGE, unsaved OFF, invalid/conflicting/disabled RED; EA preview inherits GRID OFF orange while not asserting runnable when other role semantics remain unproven. **NOT PROVEN:** actual UI lamp rendering, complete ENTRY/MANAGE/EXIT runtime semantics, generic GRID ON execution, live orders, or original O01 parity. v3_45 unchanged.


## Gate A13 — Saved four-role structural audit and fail-closed lamps (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Saved_Four_Role_Audit100_v1_00.mqh`, `Parity_Tests/MultiAlpha/MultiAlpha_SavedFourRole100_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors / 0 warnings** (1660 ms).
User MT5 Strategy Tester log: **2026.10.08 21:56:32.006**, XAUUSD-m,M1. **16/16 printed `[MA_FOUR_ROLE100_CASE]` lines PASS**: UNSAVED_ENTRY_OFF; UNSAVED_MANAGE_OFF; INVALID_REF_RED; SAVE_GRID_OFF; GRID_ORANGE; SAVE_BAD_ENTRY; ENTRY_BAD_RED; SAVE_EMPTY_MANAGE; MANAGE_EMPTY_RED; SAVE_EMPTY_EXIT; EXIT_EMPTY_RED; EA_SAVE; FOUR_ROLE_NOT_RUNNABLE; FOUR_ROLE_LAMPS; EA_OFF_SAVE; EA_OFF_REJECT.
Final: `[MA_FOUR_ROLE100_PASS] cases=15 structural_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**Gate A13 PASS for 16 printed fixture assertions only.** The final `cases=15` string is an incorrect hardcoded case count and must be corrected to 16; it does not alter the observed 16 PASS assertions. Structural audit marks GRID OFF ORANGE and refuses to certify saved ENTRY/MANAGE/EXIT runtime semantics, correctly keeping the combined EA non-runnable. **NOT PROVEN:** interpreter runtime equivalence, UI rendering, generic GRID ON, broker orders, or original O01 parity. v3_45 unchanged.


## Gate A14-1 — Saved ENTRY 100-Part vector evaluation (2026-10-08)

Test: `Parity_Tests/MultiAlpha/MultiAlpha_SavedEntry100_Evaluate_NoOrders_v1_00.mq5`; MetaEditor screenshot 0 errors / 0 warnings (713 ms). User MT5 tester XAUUSD-m,M1, 2026.10.08 22:02:25.144–.145: **12/12 `[MA_SAVED_ENTRY100_CASE]` PASS**: UNSAVED_REJECT, SAVE_SLOT100, BUY_BRANCH, SELL_BRANCH, BOTH_BRANCHES, NEITHER_BRANCH, SAVE_PART100, PART100_BUY, SAVE_ACTION_ONLY, ACTION_ONLY_REJECT, SAVE_DISABLED, DISABLED_REJECT. Final `[MA_SAVED_ENTRY100_PASS] cases=12 saved_entry_vector_evaluation=PASS indicator_values_external=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**A14-1 PASS only for saved ENTRY truth-vector evaluation.** Indicator values are supplied externally as booleans; actual RSI/ATR computation, live order handling, original O01 parity, MANAGE/EXIT runtime semantics and EA SLOT GREEN/runnable are **NOT PROVEN**. Stable v3_45 unchanged.


## Gate A14-2 — MANAGE / EXIT 100-Part intent-only evaluation (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Manage_Exit_Intent100_v1_00.mqh`, `Parity_Tests/MultiAlpha/MultiAlpha_ManageExit100_Intent_NoOrders_v1_00.mq5`.
MetaEditor screenshot: **0 errors / 0 warnings** (1307 ms). User Strategy Tester log: **2026.10.08 23:33:07.240**, XAUUSD-m,M1, **10/10 `[MA_ME_INTENT100_CASE]` PASS**: MANAGE_TRUE, MANAGE_FALSE, EXIT_TRUE, EXIT_FALSE, OR_REJECT, MULTI_ACTION_REJECT, ACTION_FIRST_REJECT, SHORT_FLAGS_REJECT, WRONG_ROLE_REJECT, EXIT_RECOVERY.
Final: `[MA_ME_INTENT100_PASS] cases=10 intent_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.

**A14-2 PASS for limited boolean-condition-to-action-intent semantics only.** This implementation conservatively rejects OR and multiple actions, and does not execute trailing, basket management, close, position modification, or orders. Conditions are supplied as external truth flags, not calculated from market or position state. Saved-definition integration, original O01 parity, full runtime semantics and GREEN/runnable certification **NOT PROVEN**. v3_45 unchanged.


## Gate A14-3 — Saved MANAGE / EXIT 100-Part intent integration (2026-10-08)

Sources: `Include/Builder/MultiAlpha_Saved_Manage_Exit_Intent100_v1_00.mqh`, `Parity_Tests/MultiAlpha/MultiAlpha_SavedManageExit100_Intent_NoOrders_v1_00.mq5`.
User MetaEditor screenshot: **0 errors / 0 warnings** (1428 ms). User MT5 Strategy Tester log: **2026.10.08 23:38:21.664**, XAUUSD-m,M1, **18/18 `[MA_SAVED_ME100_CASE]` PASS**: UNSAVED_REJECT, SAVE_MANAGE100, MANAGE_TRUE, MANAGE_FALSE, SAVE_EXIT100, EXIT_TRUE, EXIT_FALSE, ROLE_MISMATCH_UNSAVED, WRONG_ROLE_REJECT, INDEX_100_REJECT, INDEX_NEGATIVE_REJECT, SHORT_FLAGS_REJECT, SAVE_DISABLED, DISABLED_REJECT, SAVE_INVALID, INVALID_REJECT, RECOVERY_SAVE, RECOVERY_EVALUATE.
Final: `[MA_SAVED_ME100_PASS] cases=18 saved_intent_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`.
**A14-3 PASS limited saved in-memory definition -> external condition flags -> action intent only.** Not a proof of actual indicator/position condition evaluation, broker operations, full MANAGE/EXIT runtime semantics, restored disk-to-runtime execution, O01 original parity, or GREEN/runnable eligibility. Keep v3_45 unchanged.
