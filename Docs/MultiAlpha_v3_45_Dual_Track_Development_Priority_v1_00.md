# Multi Alpha v3.45 — Dual-Track Development Priority v1.00

**Established:** 2026-10-07  
**Status:** CURRENT HIGHEST-PRIORITY DEVELOPMENT POLICY  
**Common baseline:** `Parity_Tests/MultiAlpha/MA_LD2A_O01BuilderBridge_v3_45.mq5`

## 1. Purpose

For the immediate development period, Multi Alpha development is fixed to two highest-priority tracks sharing **v3.45 as the common verified baseline**.

- **Track A — O01 Reference vs Builder Runtime / Demo Parity**
- **Track B — LOGIC SLOT / LOGIC PARTS Construction Completeness**

These tracks are separate during investigation so that runtime behavior changes are not mixed with Builder/Parts editing changes. They must later converge to prove the central Multi Alpha product claim:

> A strategy can be constructed from generic LOGIC PARTS, saved as role-specific LOGIC SLOT definitions, loaded by the generic Builder Runtime, and reproduce the reference strategy's decisions/lifecycle without relying on a hidden O01-specific fallback.

Until this proof is complete, unrelated expansion, cosmetic redesign, A10-A15 migration, broad multi-instance work, and new Alpha strategy development are lower priority unless required to unblock one of these two tracks.

## 2. Baseline rule — v3.45

v3.45 is the current integrated baseline.

Do not casually edit/overwrite the verified v3.45 baseline. New work branches/versioned files must identify whether they belong to Track A or Track B. A change discovered in one track is not automatically merged into the other track.

Before changing behavior:
1. identify the failing gate/evidence,
2. locate the responsible layer,
3. make the smallest versioned change,
4. compile locally,
5. run the appropriate NO_ORDERS or DEMO test,
6. record PASS/FAIL evidence,
7. only then consider convergence.

Known v3.45 demo evidence already obtained:
- Builder initial ENTRY 0.01: PASS
- Builder GRID 0.02: PASS
- Basket trailing decision: PASS
- EXIT broker close: PASS
- owned positions 2 -> 0 / flat recovery: PASS
- diagnostic ENTRY gate tracing available through `[MA_BUILDER345_ENTRY_GATE_DIAG]`

This evidence is valuable but does **not** by itself prove that the same behavior is fully reconstructible from editable/saved generic LOGIC PARTS.

---

# TRACK A — O01 Reference vs Builder Runtime / Demo Parity

## A1. Objective

Continue running the currently installed demo environment and compare the original/reference O01 (Gold Session Guard RSI30) with the Builder path derived from v3.45.

The objective is not profit similarity. The objective is **event/decision/lifecycle parity with attributable ownership**.

## A2. Evidence to compare

For each comparable cycle, record/compare at minimum:
- timestamp/tick/bar
- logical/resolved symbol
- Magic
- order/position ownership and comment
- ENTRY decision, direction, RSI/ATR/gates, lot, price
- GRID decision, distance, order count, lot progression, price
- MANAGE state changes
- single/basket trailing activation, peak/stop/step state where relevant
- EXIT decision/reason
- close orders and resulting owned count/lots
- flat recovery
- next-cycle/re-entry eligibility
- time/news/spread/safety blocks when exercised

Do not attribute a GSG order to Builder or a Builder order to GSG without Magic/comment/runtime evidence.

## A3. Current diagnostic priority

If GSG and Builder diverge:
1. align the exact timestamp/tick,
2. inspect `MA_BUILDER345_ENTRY_GATE_DIAG` and corresponding reference state,
3. identify the first differing gate/decision,
4. distinguish decision mismatch from execution mismatch,
5. do not patch 40 Parts or Runtime until the mismatch is source/evidence proven.

RSI thresholds must be compared using unrounded values:
- BUY: strict `RSI < 30`
- SELL: strict `RSI > 70`

## A4. Runtime gates still requiring evidence

Track A remains open until evidence covers, as applicable:
- repeated ENTRY -> GRID -> MANAGE -> EXIT cycles
- re-entry after a completed cycle
- restart/re-attach with open positions
- trailing-state reconstruction/recovery
- one-order-per-bar recovery after restart
- Symbol + Magic isolation
- duplicate-order prevention
- send/close failure handling
- DD Warning 8%
- DD Grid Pause 12%
- DD Emergency Close 15%
- emergency-lock persistence/post-emergency behavior
- time/session behavior
- news/spread behavior

## A5. Track A safety

Demo execution only for execution evidence. Preserve explicit account/symbol/Magic safety and hedging requirements.

Parity/research harnesses remain NO_ORDERS / VIRTUAL_NOT_FILL unless a specific demo-execution gate has already been approved.

## A6. Track A completion condition

Track A is not complete merely because one profitable cycle matches.

PASS requires sufficient event-level evidence that the Builder Runtime can repeatedly own and execute the O01 lifecycle and that important state/restart/safety behavior is understood and reproducible.

---

# TRACK B — LOGIC SLOT / LOGIC PARTS Construction Completeness

## B1. Objective

Make the internal Builder genuinely capable of constructing the logic that Track A is proving at runtime.

The current problem to solve is explicit:

> From LOGIC SLOT, pressing EDIT and moving into the LOGIC PARTS workspace may reveal that the required logic/Part is missing, not editable, not correctly parameterized, not persisted, not interpreted, or not connected to Runtime.

A Part is **not complete merely because an enum/ID/label exists**.

## B2. Required end-to-end Part path

Every required generic Part must be checked through this complete path:

```text
LOGIC SLOT
  -> EDIT
EA LOGIC / Builder
  -> EA PARTS
select Part
  -> edit parameters
  -> APPLY/place into ordered slot
  -> SAVE definition
  -> LOAD definition
  -> Interpreter validation/evaluation
  -> Generic Runtime context/decision
```

A Part receives PASS only when the relevant stages are actually connected and verified.

## B3. Mandatory implementation matrix

Maintain an evidence matrix for every O01-required behavior with at least these columns:

| Role | Required behavior | Part exists | Visible/selectable | EDIT parameters | APPLY/slot | SAVE | LOAD | Interpreter | Runtime context | Decision parity | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|

Statuses:
- PASS
- PARTIAL
- MISSING
- BLOCKED
- NOT TESTED

Do not convert PARTIAL/NOT TESTED to PASS based on source appearance alone.

## B4. Canonical role order

All new work uses the canonical four-role order:

1. ENTRY
2. GRID
3. MANAGE
4. EXIT

Do not reintroduce legacy three-role or ENTRY/MANAGE/GRID/EXIT indexing into new code/data.

## B5. O01 as the first construction proof

O01 is the first reference recipe used to prove the Builder, not a permanent special-case Builder.

At minimum, audit/reconstruct:

### ENTRY
- CYCLE_NEW
- EMERGENCY_UNLOCKED/state input
- TIME_ALLOWED
- NEWS_CLEAR
- SPREAD_OK
- ATR range #1
- ATR range #2
- SIDE_COUNT
- RSI period/TF/price/threshold/comparison
- Trade side enabled
- one-order-per-bar
- BUY/SELL branch/action semantics
- initial lot/sizing ownership

### GRID
- side position count
- max orders
- DD Grid Pause state
- trailing pause
- grid time policy / allow outside session
- news/spread gates
- one-order-per-bar
- newest/last entry price
- fixed distance
- dynamic distance/start/multiplier
- side-aware distance reached
- lot multiplier
- max single lot
- max total side lot
- ADD BUY / ADD SELL action semantics
- broker lot normalization boundary

### MANAGE
- side/position state
- weighted average/move points
- trailing/basket state ownership where MANAGE owns state
- count-change/reset semantics
- Overlap behavior and action ordering
- required phase/priority semantics

### EXIT
- Virtual SL
- Single/Basket exit mode
- Single Fixed TP
- Basket Fixed TP
- Money TP where required
- Single Trailing
- Basket Trailing
- activation/step/stop semantics
- count-change reset
- close-opposite option
- close reason/event metadata

### Shared / Host / Safety
Do not force host/safety behavior into strategy Parts merely to make O01 fit:
- Demo-only lock
- hedging requirement
- Symbol Resolver/broker suffix
- DD 8/12/15 calculations and persistent emergency state
- broker order API
- telemetry/panel display

These must be connected through typed Context/Safety/Execution boundaries.

## B6. Logic composition is a P0 issue

The Builder must correctly represent branch/group semantics, not only a flat list of Parts.

For example, O01 ENTRY conceptually requires BUY and SELL branches such as:

```text
(BUY gates AND RSI<30 AND BUY)
OR
(SELL gates AND RSI>70 AND SELL)
```

AND/OR grouping, precedence and action binding must be explicit/deterministic. A visually populated 40-Part list that evaluates with different grouping is FAIL.

## B7. Persistence proof

For each role definition:
1. construct through UI,
2. SAVE,
3. clear/change UI state,
4. LOAD,
5. verify semantic identity,
6. run Interpreter against deterministic context,
7. compare decision with the expected/reference result.

UI objects are editors only. The saved Builder Definition is the runtime source of truth.

## B8. Track B completion condition

Track B reaches its first major PASS when O01 can be constructed from generic Parts through the normal LOGIC SLOT -> EDIT -> LOGIC PARTS workflow, saved/loaded without semantic loss, and evaluated correctly without hidden O01-specific decision fallback.

---

# 3. Convergence Gate — the central proof

Track A and Track B converge only after both are independently credible.

Final first-strategy proof:

```text
Generic LOGIC PARTS
        |
        v
ENTRY / GRID / MANAGE / EXIT definitions
        |
        v
role-specific LOGIC SLOT SAVE
        |
        v
LOAD exact saved definitions
        |
        v
Generic Interpreter / Runtime
        |
        v
Safety / Execution Adapter
        |
        v
DEMO lifecycle
        |
        v
Reference O01 event-level comparison
```

The convergence PASS requires evidence that the **saved definitions created through the Builder** are the definitions actually consumed by the runtime that produces the compared demo decisions/orders.

A hidden O01-specific fallback, duplicated hard-coded decision path, or manually injected runtime configuration invalidates this proof.

---

# 4. Priority control / anti-drift rules

Until the convergence gate is reached:

1. v3.45 remains the common baseline/reference.
2. Track A and Track B are the two highest-priority development streams.
3. Every proposed change must state A, B, or convergence.
4. Do not redesign the new panel cosmetically unless required to expose/test Track B functionality.
5. New-panel work must reuse proven Builder/Interpreter/Runtime internals.
6. Do not start A10-A15 migration as the mainline before the O01 construction/runtime proof is accepted.
7. Do not create O01-specific Parts when a reusable generic Part can express the behavior.
8. Do not mark a Part PASS from existence alone.
9. Do not mark Runtime parity PASS from profit/backtest similarity alone.
10. Preserve historical evidence and verified versions.
11. Use versioned minimal changes; avoid large mixed refactors.
12. GitHub is the durable source of truth.

# 5. Required start-of-work checklist

Before each future development step:
1. read this document,
2. identify current track (A/B/convergence),
3. confirm the v3.45 baseline and latest accepted evidence,
4. inspect relevant source before modifying,
5. state the exact gate to close,
6. avoid unrelated changes.

At the end of each step:
1. record source change,
2. record compile result,
3. record runtime/test evidence,
4. update PASS/FAIL/UNKNOWN,
5. identify the next gate without skipping unresolved failures.

# 6. Relationship to new-panel development

The future one-panel UI remains a target, but it must not replace working internals merely for appearance.

Track B directly prepares the new panel by proving:
- LOGIC SLOT selection/edit ownership,
- EA LOGIC / EA PARTS editing,
- four-role definition integrity,
- SAVE/LOAD,
- validation/status.

New-panel UI work should consume these proven mechanisms. Cosmetic consolidation is secondary to the two priority tracks during this phase.

# 7. Immediate next work

- **Track A:** keep v3.45 demo/reference comparison running and capture the next matching or divergent cycle with exact diagnostic evidence.
- **Track B:** build the complete O01-required Parts implementation matrix from the actual v3.45 source and linked Builder/Registry/Schema/Interpreter/Persistence files; then close missing/partial items one evidence-backed gate at a time.


## 8. Governing responsibility split — Logic / Filter / Global Safety

Track B and convergence work must also read:

`Docs/MultiAlpha_v3_45_Logic_Filter_GlobalSafety_Responsibility_v1_00.md`

Fixed model:

`ENTRY + GRID + MANAGE + EXIT + FILTER Panel = EA LOGIC`

Shared filter configuration belongs to FILTER Panel. Logic Parts reference typed `FILTER_*_OK` states to specify where/when a filter applies. Warning 8%, Grid Pause 12%, Emergency Close 15% and mandatory emergency protection belong to Expert Properties / Global Safety and remain effective independently of user-built Logic Slots.

Do not add an O01 source gate to EA PARTS until it is classified as Logic (L), Filter reference (F), Global Safety (G), or Host/Execution (H).
