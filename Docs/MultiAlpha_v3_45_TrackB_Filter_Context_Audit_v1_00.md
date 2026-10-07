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