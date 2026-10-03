# Multi Alpha Logic Builder - Fixed Development Plan v1.00

## Status
This document is the current development source of truth for Logic Builder work.

## Fixed base
Development resumes from:
`Parity_Tests/MultiAlpha/MultiAlpha_Runtime_Panel_BuilderSlotEdit_NoOrders_v2_68.mq5`

v2.69/v2.70 are reference work only. Useful generic Builder changes may be selectively ported, but the left-panel Builder migration is not the active development base.

## Product concept
Multi Alpha Research Lab is an environment for creating and testing original strategies by freely combining independently built modules:

EA PARTS -> MODULE BUILDER -> ENTRY / MANAGE / EXIT MODULES -> SLOT STRATEGY -> SYMBOL RESOLVER -> GENERIC RUNTIME -> GLOBAL SAFETY -> EXECUTION.

ENTRY, MANAGE and EXIT modules are independent reusable definitions. They are not fixed O01/A10 IDs.

## UI ownership during Builder completion
Do not redesign/unify the panels yet.

Right workspace remains:
- SLOT: strategy/runtime assignment
- EA LOGIC: module builder
- EA PARTS: reusable parts picker/editor

Left FILTER and PRESET remain as existing functionality. Cosmetic panel unification is postponed until Builder + Symbol Resolver + demo execution are working.

## Builder capacity
Each ENTRY / MANAGE / EXIT module has 40 part slots:
- 8 visible rows per page
- 5 pages
- slots 01-08, 09-16, 17-24, 25-32, 33-40

Total editable capacity across the three roles is 120 slots.

The storage/schema must use 40 as the role capacity. Do not implement 40 only as a visual UI extension.

## Module and strategy persistence
Role save/load becomes the module persistence concept:
- SAVE MODULE / LOAD MODULE for one ENTRY, MANAGE or EXIT definition.
- Existing legacy 24-slot files should remain readable where practical; missing slots 25-40 are EMPTY.
- Combined ENTRY + MANAGE + EXIT persistence is the strategy-definition concept.

Saved Builder Definition is the runtime source of truth. UI state must not become a hidden runtime dependency.

## SLOT
Each SLOT ultimately owns:
- Enabled
- logical Symbol
- Entry Module
- Manage Module
- Exit Module
- independent Builder/strategy definition

Target: up to 50 independent SLOTs.

## Symbol Resolver
Implement after Builder module persistence/evaluation is stable.

A SLOT stores a logical symbol such as XAUUSD. Symbol Resolver maps it to the broker symbol, e.g. XAUUSD -> XAUUSD-m for TitanFX Demo.

No Builder strategy should hard-code TitanFX suffixes.

## Generic runtime
Runtime evaluates the Saved Builder Definition using generic ENTRY / MANAGE / EXIT evaluators.

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
Development order:
1. Freeze v2.68 as baseline.
2. Expand Builder role capacity from 24 to 40 (8 x 5) end-to-end.
3. Make one-role persistence a formal reusable Module Definition.
4. Complete Canonical Schema / loader compatibility.
5. Complete generic ENTRY evaluator.
6. Complete generic MANAGE evaluator.
7. Complete generic EXIT evaluator.
8. Compose independently selected ENTRY + MANAGE + EXIT in SLOT.
9. Reproduce O01 from Builder definitions and verify parity in NO_ORDERS.
10. Implement Symbol Resolver.
11. Strategy Tester validation.
12. Add explicit Demo Execution Safety Gate.
13. TitanFX Demo / XAUUSD-m validation.
14. Only after functional completion, unify panel design.

## Safety during development
- Preserve NO_ORDERS / VIRTUAL NOT FILL until the explicit demo gate.
- Do not change broker execution while developing Builder storage/UI/evaluation.
- Do not mix panel redesign into functional Builder gates.
- Make one small GitHub change at a time.
- Never overwrite a confirmed older version by default.
- User local MetaEditor 0 errors / 0 warnings is the only Compile PASS.
- User local MT5 runtime is the final Runtime PASS.

## Immediate gate
Gate B40-1:
- create a new Builder panel version based on v1_22
- expand role capacity 24 -> 40
- page count 3 -> 5
- keep 8 visible rows
- update indexing/range/navigation
- update role and combined persistence format for 40/120
- preserve compatibility with legacy 24/72 files where practical
- integrate it into a short-named EA derived from v2.68
- compile locally before any further runtime change
