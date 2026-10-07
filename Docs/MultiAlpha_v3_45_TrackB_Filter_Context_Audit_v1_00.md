# Multi Alpha v3.45 — Track B FILTER Context Audit v1.00

**Established:** 2026-10-07  
**Gate:** B-P0-2A — existing FILTER panel/runtime connection audit  
**Baseline:** `Parity_Tests/MultiAlpha/MA_LD2A_O01BuilderBridge_v3_45.mq5`  
**Governing architecture:** `Docs/MultiAlpha_v3_45_Logic_Filter_GlobalSafety_Responsibility_v1_00.md`

## 1. Result

**B-P0-2A: FAIL / BLOCKED for implementation, with root boundary identified.**

The v3.45 EA source clearly contains a FILTER Panel/store/preset UI path, but it explicitly logs that the filter data is **not connected to Runtime**.

Evidence in v3.45:
- `CMultiAlphaFilterStore110 filter_store`
- `CMultiAlphaFilterPanel111 filter_panel`
- `CMultiAlphaSlotFilterPreset120 filter_preset`
- `CMultiAlphaFilterPresetPanel126 filter_preset_panel`
- selected-slot edit updates `filter_store.Set(...)`
- preset save/load copies all 50 filter slots
- log text explicitly states `runtime_connected=0`

Therefore the existing FILTER Panel is currently an editor/storage/preset surface, not the active decision source for Builder Runtime.

## 2. Current v3.45 runtime behavior

The current verified runtime still uses separate O01 runtime helpers:
- `TimeOK()`
- `NewsNewBlocked()`
- `NewsGridBlocked()`
- `SpreadOK()`

At this baseline:
- `TimeOK()` evaluates `runtime_cfg` time inputs.
- `NewsNewBlocked()` returns false.
- `NewsGridBlocked()` returns false.
- `SpreadOK()` returns true.

`RuntimeBuilderEntry315()` reads those helpers and feeds the canonical ENTRY evaluator.

`RuntimeBuilderGridDecision339()` similarly derives GRID time/news/spread state from the runtime helpers/config.

This means the visible FILTER Panel does **not** currently control those runtime gates.

## 3. Existing FILTER storage path visible from v3.45

Conceptual path proven by source:

```text
Selected EA SLOT
   |
   v
filter_store.Get(slot)
   |
   v
CMultiAlphaFilterPanel111
   |
 Event/edit
   v
filter_store.Set(slot, config)
   |
   +--> display refresh
   |
   +--> FILTER preset SAVE/LOAD (50 slots)
```

Current endpoint:
`runtime_connected=0`

This is exactly the missing boundary that B-P0-2 must solve.

## 4. Repository location correction / source recovered

Follow-up recursive Git tree inspection found the exact Filter implementation under:

- `Modules/Common/MultiAlpha_Common_Filter_v1_10.mqh`
- `Modules/Common/MultiAlpha_Filter_Panel_v1_11.mqh`
- `Modules/Common/MultiAlpha_Slot_Filter_Preset_v1_20.mqh`
- `Modules/Common/MultiAlpha_Filter_Preset_Panel_v1_26.mqh`

The earlier lookup only checked `Include/Common/...` because that is the relative include target visible in v3.45. The source is therefore **recovered in GitHub**, not absent.

However, there is a repository/path-layout inconsistency to preserve as evidence: v3.45 includes `../../../Include/Common/...`, while the tracked implementation is under `Modules/Common/...`. Do not silently rewrite this until the user's actual MetaEditor include layout is reconciled.

### Exact Filter schema now confirmed

`SMA_CommonFilterConfig110` supports:
- TIME
- NEWS
- FOMC
- NFP
- CPI
- MONTH END
- MONTH START
- QUARTER END
- YEAR END
- ROLLOVER
- FRIDAY
- SPREAD
- VOLATILITY

Each filter also has a scope:
- `MA_FILTER_NEW_V110`
- `MA_FILTER_ADD_V110`
- `MA_FILTER_BOTH_V110`

This is directly compatible with the architecture decision that Filter Panel owns configuration while strategy/runtime decides when the filter applies.

The existing `SMA_FilterPermission110` already defines:
- `new_entry`
- `add_entry`
- `new_reason`
- `add_reason`

Therefore the typed Filter Context should build on this existing contract instead of inventing a parallel boolean model.

## 4A. Prior blocked statement superseded

v3.45 includes these files through a relative path that resolves outside the repository root used by the checked-in EA path:

- `../../../Include/Common/MultiAlpha_Common_Filter_v1_10.mqh`
- `../../../Include/Common/MultiAlpha_Filter_Panel_v1_11.mqh`
- `../../../Include/Common/MultiAlpha_Slot_Filter_Preset_v1_20.mqh`
- `../../../Include/Common/MultiAlpha_Filter_Preset_Panel_v1_26.mqh`

The exact files are now located under `Modules/Common/`. The earlier BLOCKED reason is resolved. The remaining issue is the `Include/Common` vs `Modules/Common` path/layout mismatch, which must be handled deliberately rather than guessed.

## 5. Required target interface

Once the actual Common filter schema is available, introduce a strategy-neutral typed context boundary. Conceptually:

```text
FILTER Panel configuration
        |
        v
Filter Store (selected EA SLOT)
        |
        v
Filter Evaluator / Context Provider
        |
        +--> time_ok
        +--> news_ok
        +--> spread_ok
        +--> day_ok (only if real panel/schema supports separate day)
        |
        v
Builder Context
        |
        v
FILTER_*_OK reference Parts
```

Important:
- FILTER Parts carry no duplicate session/news/spread numeric values.
- They read booleans/state from the typed Filter Context.
- Role/branch placement decides when a filter applies.
- Global Safety is not part of this Filter Context.

## 6. Compatibility bridge for v3.45

Do not immediately replace `TimeOK()/NewsNewBlocked()/SpreadOK()` in the DEMO path.

Safe migration sequence:
1. obtain/inspect actual Common Filter sources,
2. define typed Filter Context,
3. add NoOrders deterministic evaluator tests,
4. add `FILTER_TIME_OK/FILTER_NEWS_OK/FILTER_SPREAD_OK` schema/picker support,
5. prove UI config -> store -> context -> Part decision,
6. compare Filter Context outputs against reference O01 behavior,
7. only then version a Runtime bridge,
8. keep v3.45 unchanged as the known DEMO baseline.

## 7. B-P0-2 sub-gates

### B-P0-2A — locate and audit existing Filter implementation
Current status: **PASS by source.** Exact Filter config/panel/preset sources were recovered under `Modules/Common/`.

Required files:
- `MultiAlpha_Common_Filter_v1_10.mqh`
- `MultiAlpha_Filter_Panel_v1_11.mqh`
- `MultiAlpha_Slot_Filter_Preset_v1_20.mqh`
- `MultiAlpha_Filter_Preset_Panel_v1_26.mqh`

### B-P0-2B — define typed Filter Context
**DESIGN READY.** Reuse the existing `SMA_FilterPermission110` contract as the minimum runtime permission boundary.

Initial mapping:
- Filter engine evaluates all enabled configured filters.
- Scope NEW affects `permission.new_entry`.
- Scope ADD affects `permission.add_entry`.
- Scope BOTH affects both.
- Disabled filters are neutral/pass.
- EXIT and Global Safety are unaffected.

For Logic Builder integration, do not duplicate every filter parameter into a Part. The first generic bridge should expose filter permission/state to the Interpreter. Exact Part granularity (single aggregate permission Part vs named per-filter reference Parts) must be decided from the desired Builder composition semantics before code change.

### B-P0-2C — add F-reference Parts to schema/picker
Not started until 2B.

### B-P0-2D — deterministic NoOrders test
Not started.

### B-P0-2E — UI/store/context round-trip
Not started.

## 8. No-change decision

No MQL5 behavior code is changed in this gate.

Reason: implementing guessed Filter fields would violate the evidence-first policy and could create a second incompatible filter model.

The Filter source has now been recovered in GitHub under `Modules/Common/`. The next correct action is B-P0-2B/C: preserve the existing schema/scope contract, reconcile the repository include path deliberately, and add a NoOrders Filter Context/Interpreter bridge before any DEMO runtime replacement.

## 9. B-P0-2B/C implementation — 2026-10-07

Versioned NoOrders components added without changing v3.45 DEMO runtime:

- `Include/Builder/MultiAlpha_Builder_Filter_Context_v1_00.mqh`
- `Include/Builder/MultiAlpha_Builder_Part_Schema_v1_04.mqh`
- `Parity_Tests/MultiAlpha/MultiAlpha_Filter_Context_Builder_NoOrders_v1_00.mq5`

### Design decision

The first generic Builder bridge uses **permission references**, not duplicated individual filter settings:

- `FILTER_NEW_OK` — ENTRY-only reference to `SMA_FilterPermission110.new_entry`
- `FILTER_ADD_OK` — GRID-only reference to `SMA_FilterPermission110.add_entry`

This deliberately reuses the existing Filter system's NEW / ADD / BOTH scope semantics.

Why this is preferable at this gate:
- Filter Panel already owns TIME/NEWS/FOMC/NFP/CPI/calendar/rollover/Friday/spread/volatility settings.
- Each existing Filter has NEW/ADD/BOTH scope.
- Logic Builder does not need to duplicate those numeric settings.
- ENTRY and GRID can independently reference the resulting permission.
- EXIT and Global Safety remain unaffected.

A future requirement to reference a specific individual filter independently inside arbitrary branch logic may justify additional typed Parts, but it is not invented here.

### Schema rules

`FILTER_NEW_OK` is allowed only in ENTRY.
`FILTER_ADD_OK` is allowed only in GRID.
Both must have an empty parameter string. A saved Part such as `FILTER_NEW_OK;START=10` is rejected because Filter parameters belong to Filter Panel.

### Deterministic NoOrders source test

The new test verifies:
1. schema accepts ENTRY `FILTER_NEW_OK`,
2. schema accepts GRID `FILTER_ADD_OK`,
3. duplicated Filter parameters are rejected,
4. Filter permission true + signal true => BUY true,
5. Filter permission false + signal true => BUY false,
6. Filter permission true + signal false => BUY false,
7. no broker operations are present.

**Source implementation: PASS.**
**MetaEditor compile/runtime test: NOT TESTED until user executes it locally.**

### Important boundary

This test starts from an already evaluated `SMA_FilterPermission110`. The repository currently contains the Filter config/store/UI/preset contract, but the production evaluator that converts TIME/NEWS/SPREAD/etc current market/calendar state into `SMA_FilterPermission110` still needs to be identified or implemented as the next sub-gate.

### Next gate — B-P0-2D/E

1. inspect repository for an existing Common Filter evaluator,
2. if one exists, reuse it;
3. otherwise implement a strategy-neutral NoOrders evaluator from the confirmed `SMA_CommonFilterConfig110` schema,
4. connect selected EA SLOT's `filter_store.Get(slot)` to that evaluator,
5. prove config -> permission -> FILTER_NEW_OK/FILTER_ADD_OK decision,
6. only after that add Picker buttons in a new Picker version,
7. keep v3.45 DEMO runtime unchanged.


## 10. Local compile evidence — v1.00 include-depth FAIL / v1.01 fix

User MetaEditor evidence on 2026-10-07 showed:

`file 'Experts\\Include\\Builder\\MultiAlpha_Builder_Part_Schema_v1_04.mqh' not found`

with 1 error, 0 warnings.

Root cause is source-proven path depth in the NoOrders test:
- test location: `MQL5/Experts/Parity_Tests/MultiAlpha/`
- v1.00 used `../../Include/...`
- that resolves to `MQL5/Experts/Include/...`, matching the MetaEditor error.
- correct repository/runtime depth is `../../../Include/...`, the same depth pattern used by v3.45.

Resolution:
- keep v1.00 as failed evidence,
- create `Parity_Tests/MultiAlpha/MultiAlpha_Filter_Context_Builder_NoOrders_v1_01.mq5`,
- change only the three Builder include paths from `../../Include/` to `../../../Include/`,
- no Filter/Interpreter/decision behavior changed.

Gate status:
- v1.00 local compile: **FAIL — include path only**
- v1.01 source fix: **PASS**
- v1.01 local compile: **NOT TESTED**


## 11. Local compile evidence — v1.01 type visibility FAIL / architecture correction

User MetaEditor evidence on 2026-10-07:
- include-depth failure from v1.00 is resolved,
- v1.01 test reaches source parsing,
- first error: `undeclared identifier 'SMA_BuilderFilterContext100'`,
- subsequent 25 errors / 2 warnings are cascading from unavailable Filter Context declarations.

Source review found `MultiAlpha_Builder_Filter_Context_v1_00.mqh` directly included `Modules/Common/MultiAlpha_Common_Filter_v1_10.mqh` and exposed `SMA_FilterPermission110` in the Builder API.

This is rejected as the final dependency direction: Builder should not require the concrete Filter UI/store module merely to represent evaluated permission.

Correction:
- keep Context v1_00 and test v1_01 as failed evidence,
- add `MultiAlpha_Builder_Filter_Context_v1_01.mqh`,
- Builder context now owns only typed evaluated values: new_entry_ok, add_entry_ok, new_reason, add_reason,
- remove direct Common Filter include/dependency from Builder Context,
- add setter `MABuilderFilterContextSet101(...)`,
- production Filter->Builder conversion will be a separate adapter boundary,
- add `MultiAlpha_Filter_Context_Builder_NoOrders_v1_02.mq5`.

Gate status:
- test v1_01 local compile: **FAIL — Builder/Common dependency/type visibility**
- Builder Filter Context v1_01 source: **PASS**
- test v1_02 source: **PASS**
- test v1_02 local compile: **NOT TESTED**

No DEMO runtime behavior changed.


## 12. Local MetaEditor compile evidence — v1.02 PASS

User MetaEditor screenshot evidence on 2026-10-07 confirms:

`MultiAlpha_Filter_Context_Builder_NoOrders_v1_02.mq5`

Compile result:
- **0 errors**
- **0 warnings**
- 1416 msec elapsed
- cpu = AVX2 + FMA3

Loaded dependency chain visible in MetaEditor:
- `MultiAlpha_Builder_Part_Schema_v1_04.mqh`
- `MultiAlpha_Builder_Part_Schema_v1_03.mqh`
- `MultiAlpha_Builder_Part_Schema_v1_02.mqh`
- `MultiAlpha_Builder_Part_Schema_v1_01.mqh`
- `MultiAlpha_Builder_Filter_Context_v1_01.mqh`
- `MultiAlpha_Builder_Interpreter_v1_05.mqh`
- `MultiAlpha_Builder_Interpreter_v1_02.mqh`

Gate update:
- Builder Filter Context v1.01 compile integration: **PASS**
- Part Schema v1.04 compile integration: **PASS**
- Interpreter v1.05 compile integration with FILTER_NEW_OK test definition: **PASS**
- B-P0-2D compile gate: **PASS**
- B-P0-2D deterministic runtime log gate: **NOT TESTED**

Next evidence required:
attach/run the compiled NoOrders test and confirm:
- `[MA_FILTERCTX102_CASE] filter=1 signal=1 BUY=1`
- `[MA_FILTERCTX102_CASE] filter=0 signal=1 BUY=0`
- `[MA_FILTERCTX102_CASE] filter=1 signal=0 BUY=0`
- `[MA_FILTERCTX102_PASS] ... NO_ORDERS=1 ...`

No DEMO execution path is changed by this compile PASS.


## 13. B-P0-2D deterministic runtime evidence — PASS

User MT5 runtime evidence on 2026-10-07 at 23:29:17.857:

```text
[MA_FILTERCTX102_CASE] filter=1 signal=1 BUY=1 B0=TRUE => TRUE BUY=TRUE SELL=FALSE
[MA_FILTERCTX102_CASE] filter=0 signal=1 BUY=0 B0=FALSE => FALSE BUY=FALSE SELL=FALSE filter_reason=TEST_FILTER_BLOCK
[MA_FILTERCTX102_CASE] filter=1 signal=0 BUY=0 B0=FALSE => FALSE BUY=FALSE SELL=FALSE
[MA_FILTERCTX102_PASS] schema=PASS context=PASS interpreter=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1
```

Strict result:
- filter permission TRUE + strategy signal TRUE -> BUY TRUE: **PASS**
- filter permission FALSE + strategy signal TRUE -> BUY FALSE: **PASS**
- filter permission TRUE + strategy signal FALSE -> BUY FALSE: **PASS**
- schema -> Builder Filter Context -> Interpreter chain: **PASS**
- NoOrders safety declaration: **PASS**
- broker actions armed = 0: **PASS**
- virtual not fill = 1: **PASS**

**B-P0-2D: PASS.**

This proves an evaluated Filter permission can deterministically participate in generic Builder branch decisions. It does not yet prove the visible FILTER Panel/store produces that permission.

Next gate: **B-P0-2E — actual Filter Panel/Store -> evaluator/permission -> Builder Context round trip.**


## 14. B-P0-2E source implementation — Filter Store -> Evaluator -> Builder Context

Repository inspection found `Modules/Common/MultiAlpha_Common_Filter_v1_00.mqh` already contains the earlier evaluator semantics:
- `MAFilterScopeBlocks100`
- `MAFilterTimeInside100`
- `MAFilterBlock100`
- `MAFilterEvaluate100`

v1.10 expanded the Filter schema but retained only config/external-state/permission/store contracts. Therefore the v1.00 evaluator semantics were migrated forward in a new versioned component rather than modifying v1.10 in place.

Added:
- `Modules/Common/MultiAlpha_Common_Filter_Evaluator_v1_11.mqh`
- `Include/Common/MultiAlpha_Filter_To_Builder_Adapter_v1_00.mqh`
- `Parity_Tests/MultiAlpha/MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_00.mq5`

Evaluator v1.11 handles the confirmed v1.10 enabled flags/scopes:
TIME, NEWS, FOMC, NFP, CPI, MONTH END, MONTH START, QUARTER END, YEAR END, ROLLOVER, FRIDAY, SPREAD, VOLATILITY.

Responsibility boundary:
- TIME uses config + supplied datetime.
- NEWS/FOMC/NFP/CPI/calendar/rollover/Friday/spread/volatility use `SMA_FilterExternalState110`.
- The evaluator does not invent calendar/news/spread/ATR data acquisition.
- Scope NEW/ADD/BOTH controls which permission is blocked.
- first enabled blocking condition supplies the reason.
- all filters OFF remains neutral/ALLOW.

Adapter converts `SMA_FilterPermission110` to the independent `SMA_BuilderFilterContext101`.

NoOrders test covers:
- all OFF -> NEW/ADD allow,
- NEWS NEW -> NEW blocked / ADD allowed,
- NEWS ADD -> NEW allowed / ADD blocked,
- NEWS BOTH -> both blocked,
- TIME NEW 10:00-14:00 -> 11:00 allow / 15:00 NEW block / ADD unaffected,
- SPREAD BOTH external block -> both blocked.

Status:
- source implementation: **PASS**
- local MetaEditor compile: **NOT TESTED**
- deterministic runtime: **NOT TESTED**
- production v3.45 DEMO connection: **NOT CHANGED / NOT TESTED**


## 15. B-P0-2E local compile evidence — v1.00 runtime path FAIL / v1.01 correction

User MetaEditor screenshot on 2026-10-07 showed:
`file 'Modules\\Common\\MultiAlpha_Common_Filter_Evaluator_v1_11.mqh' not found`
with 1 error, 0 warnings.

This exposed an important repository/runtime layout distinction.

The known compiling v3.45 baseline includes Common Filter files from:
`../../../Include/Common/...`

Therefore the MetaEditor runtime include location is `MQL5/Include/Common/`, even though recovered/reference Common sources also exist in GitHub under `Modules/Common/`.

Correction:
- preserve `Modules/Common/MultiAlpha_Common_Filter_Evaluator_v1_11.mqh` as source/history evidence,
- add runtime include copy `Include/Common/MultiAlpha_Common_Filter_Evaluator_v1_11.mqh`,
- create `MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_01.mq5`,
- v1.01 changes only evaluator include from `../../../Modules/Common/...` to `../../../Include/Common/...`,
- other Builder/Common includes already use `Include/...`.

Gate:
- B-P0-2E test v1.00 local compile: **FAIL — runtime include path only**
- runtime evaluator Include/Common source: **PASS**
- test v1.01 source fix: **PASS**
- test v1.01 local compile: **NOT TESTED**


## 16. B-P0-2E local compile evidence — v1.01 Adapter path FAIL / v1.02 correction

User MetaEditor screenshot on 2026-10-07 showed 29 errors, 0 warnings after the top-level evaluator path was corrected.

Source inspection identified the remaining path inconsistency inside:
`Include/Common/MultiAlpha_Filter_To_Builder_Adapter_v1_00.mqh`

It still included:
`../../Modules/Common/MultiAlpha_Common_Filter_v1_10.mqh`

while the confirmed runtime layout is `MQL5/Include/Common/`.

Because the Adapter failed to establish its Common Filter dependency, later calls to `MAFilterPermissionToBuilder100` appeared undeclared and generated cascading parse errors.

Correction:
- preserve Adapter v1_00 and test v1_01 as failed evidence,
- add `Include/Common/MultiAlpha_Filter_To_Builder_Adapter_v1_01.mqh`,
- v1_01 uses same-directory `#include "MultiAlpha_Common_Filter_v1_10.mqh"`,
- Builder Context include remains `../Builder/MultiAlpha_Builder_Filter_Context_v1_01.mqh`,
- add test `MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_02.mq5` using Adapter v1_01.

No evaluator logic, scope semantics, test expectations, or DEMO runtime behavior changed.

Gate:
- test v1_01 local compile: **FAIL — nested Adapter include path**
- Adapter v1_01 source fix: **PASS**
- test v1_02 source fix: **PASS**
- test v1_02 local compile: **NOT TESTED**


## 17. B-P0-2E MetaEditor compile evidence — v1.02 PASS

User MetaEditor screenshot evidence on 2026-10-07 confirms:

`MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_02.mq5`

Compile result:
- **0 errors**
- **0 warnings**
- 548 ms elapsed
- cpu = AVX2 + FMA3

Visible dependency chain:
- `MultiAlpha_Common_Filter_Evaluator_v1_11.mqh`
- `MultiAlpha_Common_Filter_v1_10.mqh`
- `MultiAlpha_Filter_To_Builder_Adapter_v1_01.mqh`
- `MultiAlpha_Builder_Filter_Context_v1_01.mqh`

Strict gate update:
- runtime Include/Common layout: **PASS**
- Filter Evaluator v1.11 compile integration: **PASS**
- Filter -> Builder Adapter v1.01 compile integration: **PASS**
- Builder Filter Context v1.01 compile integration: **PASS**
- B-P0-2E compile gate: **PASS**
- B-P0-2E deterministic runtime gate: **NOT TESTED**

Next evidence required is the NoOrders runtime output from v1.02. Expected cases include ALL_OFF, NEWS NEW/ADD/BOTH, TIME inside/outside, SPREAD BOTH, followed by:
`[MA_FILTERE100_PASS] store=PASS evaluator=PASS scope=PASS adapter=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`

No v3.45 DEMO execution behavior has been changed.


## 18. B-P0-2E deterministic runtime evidence — PASS

User MT5 runtime evidence on 2026-10-07 at 23:50:08.964 from:
`MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_02`

Confirmed cases:
- ALL_OFF_NEW = 1: **PASS**
- ALL_OFF_ADD = 1: **PASS**
- NEWS_NEW_NEW = 0: **PASS**
- NEWS_NEW_ADD = 1: **PASS**
- NEWS_ADD_NEW = 1: **PASS**
- NEWS_ADD_ADD = 0: **PASS**
- NEWS_BOTH_NEW = 0: **PASS**
- NEWS_BOTH_ADD = 0: **PASS**
- TIME_INSIDE_NEW = 1: **PASS**
- TIME_OUTSIDE_NEW = 0: **PASS**
- TIME_OUTSIDE_ADD_UNSCOPED = 1: **PASS**
- SPREAD_BOTH_NEW = 0: **PASS**
- SPREAD_BOTH_ADD = 0: **PASS**

Final runtime line:
`[MA_FILTERE100_PASS] store=PASS evaluator=PASS scope=PASS adapter=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1`

Strict result:
- Filter Store round trip: **PASS**
- Evaluator permission generation: **PASS**
- NEW / ADD / BOTH scope semantics: **PASS**
- Filter -> Builder Adapter: **PASS**
- Builder Filter Context handoff: **PASS**
- NoOrders safety: **PASS**
- broker actions armed = 0: **PASS**
- virtual not fill = 1: **PASS**

Combined with B-P0-2D runtime evidence at 23:29:17.857:
- Builder Filter Context -> generic Logic Interpreter decision participation: **PASS**

Therefore the currently proven NoOrders chain is:

`Filter Store -> Evaluator -> NEW/ADD Scope -> Filter Permission -> Builder Context -> FILTER reference predicate -> Logic Interpreter decision`

**B-P0-2E: PASS.**

Important boundary:
This does NOT yet prove the visible FILTER Panel edits and persists the same Store values, nor that v3.45 DEMO runtime consumes this new chain. Those remain separate gates.

Next gate:
**B-P0-2F — visible FILTER Panel / UI edit -> Store persistence -> Evaluator permission round trip, NoOrders.**
After that, connect the proven chain to saved Builder role definitions and only later to DEMO runtime.


## 19. B-P0-2F source audit and visible Panel harness

v3.45 source audit confirms the existing UI write path already exists:

`filter_store.Get(selected slot) -> filter_panel.Event(...) -> filter_store.Set(selected slot, edited config) -> RefreshCommonFilter202()`

Slot switching also reloads the selected slot's Filter config.

However v3.45 explicitly logs `runtime_connected=0`; therefore Panel->Store exists, but Store->new Evaluator->Builder Context is not yet connected to production runtime.

Repository reproducibility issue found:
v3.45 includes Filter UI files from `Include/Common/`, while GitHub only retained some copies under `Modules/Common/`. To make GitHub reproduce the runtime layout, mirrored without behavior changes:
- `Include/Common/MultiAlpha_Filter_Panel_v1_11.mqh`
- `Include/Common/MultiAlpha_Filter_Preset_Panel_v1_26.mqh`

Added NoOrders harness:
`Parity_Tests/MultiAlpha/MultiAlpha_Filter_Panel_Store_Evaluator_NoOrders_v1_00.mq5`

Purpose:
- display the real Filter Panel v1.11,
- use the real Filter Store110,
- route actual panel click/end-edit events through the same Get -> Event -> Set pattern,
- evaluate resulting Store config through Evaluator v1.11,
- convert permission through Adapter v1.01 to Builder Context v1.01,
- log state after every UI edit,
- no broker calls.

For deterministic visible verification, NEWS and SPREAD scopes are set to BOTH and external NEWS/SPREAD block states are TRUE inside this test only. Therefore:
- NEWS OFF + SPREAD OFF -> allow,
- click NEWS ON -> NEW/ADD blocked, reason NEWS,
- NEWS OFF -> allow again,
- click SPREAD ON -> NEW/ADD blocked, reason SPREAD.

This test does not change v3.45 production runtime.

Gate:
- existing v3.45 Panel -> Store source path: **PASS**
- GitHub runtime Filter Panel layout reproducibility: **PASS after mirror**
- B-P0-2F test source: **PASS**
- B-P0-2F local compile: **NOT TESTED**
- B-P0-2F visible UI runtime round trip: **NOT TESTED**
