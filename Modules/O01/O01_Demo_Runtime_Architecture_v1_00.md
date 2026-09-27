# O01 Demo Runtime Architecture v1.00

Status: DESIGN GATE. This document fixes the architecture before broker-order implementation.

## Purpose

Use one O01 Demo Runtime EA on multiple charts and select the strategy structure per EA instance. The immediate parity experiment is three charts on one demo account:

1. Original O01 EA — reference, Magic 46102030.
2. O01 Demo Runtime — FULL mode, Magic 46102031.
3. O01 Demo Runtime — SPLIT mode, Magic 46102032.

Charts 2 and 3 use the same EA binary. Their Expert Properties / panel settings select the structure.

## Non-negotiable parity rule

FULL and SPLIT are independent comparison paths.

- FULL must call the frozen whole-strategy reproduction path. It must not be implemented as a wrapper that simply recomposes the split modules.
- SPLIT must use independently callable Entry / Manage / Exit responsibilities.
- The already verified O01 decision/lifecycle behavior is the baseline. Selector, panel, preset, routing, and execution plumbing must not silently alter signal timing.
- Existing research/parity hosts remain NO ORDERS / VIRTUAL NOT FILL. Demo broker execution is added only in a separate Demo Runtime host.

## Runtime structure selector

Initial selector:

- FULL
- SPLIT

Initial module selection in SPLIT:

- Entry = O01
- Manage = O01
- Exit = O01

The selector is designed for future module IDs (A10+, O02+, etc.) without changing the host architecture.

Suggested stable identities:

- O01 = 101
- NONE = 0

The first implementation may expose only O01 choices while preserving the enum/router shape for later expansion.

## Expert Properties -> panel -> runtime

The startup source is Expert Properties. The host captures an immutable startup snapshot after mapping inputs to runtime configuration.

The panel must expose:

- Structure: FULL / SPLIT
- Entry Module
- Manage Module
- Exit Module

Panel semantics remain:

- APPLY: validate and apply panel values to current runtime.
- SAVE: save the complete named preset, including Structure and module selections.
- NEXT: select a named preset.
- LOAD: load and validate the selected named preset.
- DELETE: delete the selected named preset.
- REFRESH: restore the Expert Properties startup snapshot, including Structure/module selections.

Magic Number is instance identity and MUST NOT be stored in a named strategy preset.

MT5 standard .set files remain separate from O01 named presets.

## Safe structure/module switching gate

Structure or module routing may change only while the EA instance is flat and its lifecycle is idle.

Required gate:

- managed position count = 0
- cycle state = NONE
- no pending execution transition

If the gate is closed, APPLY/LOAD must reject the routing change and keep the currently active routing. The panel/log must report MODULE CHANGE BLOCKED with the reason.

This prevents FULL-created positions from being handed to SPLIT (or another future module combination) mid-cycle.

## Responsibility boundaries

### FULL

Frozen whole-strategy reproduction. Owns its original decision/lifecycle timing. The Demo Runtime host supplies only instance identity, validated runtime configuration where explicitly supported, and demo execution plumbing.

### ENTRY

New-cycle entry decision only. No broker-order ownership.

### MANAGE

Grid/add-position decisions and side/cycle lifecycle management. O01 requires this layer because grid behavior cannot safely be hidden inside a generic Entry or Exit module.

### EXIT

Virtual SL / fixed TP / single trailing / basket trailing close decisions and exit state.

### SAFETY

Cross-cutting host safety. Warning 8%, Grid Pause 12%, Emergency Close 15% are O01 defaults, but exact semantics must remain source-faithful. Account-wide Balance/Equity DD can couple the three EAs on one demo account, so DD-safety parity is tested separately from normal signal parity.

### EXECUTION ADAPTER

The only layer allowed to translate decisions into broker demo orders. It must isolate positions by Symbol + Magic and must not be introduced into existing NoOrders parity hosts.

## State ownership

Each EA instance owns independent runtime/lifecycle state. Broker positions are identified by Symbol + Magic.

FULL state and SPLIT state must not be shared implicitly. A routing change is permitted only through the flat/idle gate and must perform an explicit state reset before the new route becomes active.

## Three-chart parity comparison

Compare these independently:

- signal timestamp
- BUY / SELL direction
- requested lot
- initial vs Grid stage
- Grid number and requested lot
- close timestamp
- close reason
- trailing activation / lifecycle state
- final managed position count

Actual fill price is recorded but is not required to be byte-for-byte equal because the three EAs submit sequential broker requests. Signal/decision parity and execution/fill parity are separate measurements.

## Implementation gates

Gate 0 — DONE before demo execution:
- architecture documented
- stable selector/module IDs defined
- startup/panel/preset semantics fixed
- flat/idle routing gate specified
- Magic excluded from presets

Gate 1 — NoOrders router:
- add Structure + Entry/Manage/Exit selections to runtime settings, Expert Properties, panel, preset schema
- route FULL and SPLIT in a NoOrders host
- confirm FULL path still uses frozen monolithic reproduction
- confirm SPLIT path preserves the frozen split baseline
- rerun O01 parity regression if routing touches decision timing

Gate 2 — Demo execution adapter:
- create a separate O01 Demo Runtime EA
- explicit DEMO execution mode
- Symbol + Magic isolation
- order/open/grid/close result logging
- no changes to frozen research/parity hosts

Gate 3 — three-chart forward parity:
- Original Magic 46102030
- Runtime FULL Magic 46102031
- Runtime SPLIT Magic 46102032
- compare normal lifecycle events first
- test DD/emergency behavior separately

## Current caution discovered during source review

The current Entry and Exit modules are decision-only and NoOrders. The current Core Interface directly contains Entry/Exit but does not yet expose a dedicated Manage module. Therefore SPLIT must not be declared architecturally complete until O01 grid/manage behavior has been extracted or wrapped with parity preserved.

The Full Reproduction module is already a thin compatibility layer over the frozen monolithic implementation and is the correct independent FULL reference path.

No demo-order code is authorized by this design document alone.


## Gate 1 implementation note — 2026-09-27

Gate 1 has started with decision-only, NO ORDERS infrastructure:

- O01_GSG_RSI30_Manage_Module_v1_40.mqh — first dedicated grid/manage decision module.
- O01_GSG_RSI30_Logic_Router_v1_40.mqh — stable FULL/SPLIT selector contract, O01=101 module identity, and flat/idle route-change gate.

Important: these files are scaffolding until compile and parity regression are completed. They are not yet approved as a replacement for the frozen split baseline. In particular, broker lot normalization remains host/execution responsibility, matching the current runtime host's separation of decision logic from symbol-specific execution constraints.

FULL dispatch is deliberately not reimplemented inside the router. The host must dispatch FULL to the frozen whole-strategy reproduction path, keeping FULL independent from SPLIT.
