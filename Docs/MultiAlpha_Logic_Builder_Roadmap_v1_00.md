# Multi Alpha Research Lab — Logic Builder Roadmap v1.00

**Established:** 2026-10-02  
**Status:** Central development roadmap

## Mission

Make the EA Logic Builder the center of future Multi Alpha Research Lab development.

The Builder will let trading logic be assembled from reusable parts in an MT5 panel, saved as a versioned definition, registered as an ENTRY / MANAGE / EXIT module (or complete strategy where appropriate), and tested through the same Multi Alpha runtime.

The first purpose is **reproduction, not invention**.

Use the existing O01 and A10-A15 logic as reference targets. Reproduce their behavior with Builder parts and prove parity against the frozen/reference implementations. Once reproduction is reliable, use the same Builder to create new combinations and new Alpha research.

## What remains protected

Do not discard or rewrite the architecture already established:

- O01 / A10 / A11 / A12 / A13 / A14 / A15 frozen/reference logic
- FULL route
- SPLIT ENTRY / MANAGE / EXIT routes
- Module Registry and routing
- per-role settings
- parity/regression testing
- NO_ORDERS / VIRTUAL_NOT_FILL research safety
- Strategy Instance isolation
- stable runtime/panel baselines

The Builder sits above reusable parts and below the existing Module Registry/runtime.

```text
PART REGISTRY
     |
LOGIC BUILDER
     |
+----+------+----+
| ENTRY | MANAGE | EXIT |
+----+------+----+
     |
MODULE REGISTRY / ROUTER
     |
FULL / SPLIT RESEARCH RUNTIME
     |
PARITY / BACKTEST / FORWARD
```

## Reference-driven build order

The Builder is developed by reproducing known logic, not by trying to implement every possible indicator/action in advance.

For each reference target:

1. Freeze/identify the reference implementation.
2. Decompose it into ENTRY / MANAGE / EXIT behavior.
3. List the generic parts required.
4. Add only missing reusable parts.
5. Reconstruct the logic in the Builder.
6. Save/version the Builder definition.
7. Run identical-condition parity tests.
8. Compare event-level behavior.
9. Record PASS only from actual evidence.
10. Freeze the verified Builder definition.

Reference set:

```text
O01
A10
A11
A12
A13
A14
A15
```

The reproduction order is **fixed** and must not follow a different dependency/convenience order:

```text
O01 -> A10 -> A11 -> A12 -> A13 -> A14 -> A15
```

**O01 is the mandatory first Builder target.** The central Builder track does not proceed to A10 until O01 has been reconstructed in the Builder, parity-tested against the O01 reference, and successfully operated on a demo account with recorded forward evidence. After O01, proceed sequentially through A10, A11, A12, A13, A14, and A15. Reordering or skipping requires an explicit policy decision recorded in GitHub before implementation.

## Builder part model

### Conditions / indicators

Examples:

- RSI
- Moving Average
- ATR
- Bollinger Bands
- MACD
- ADX
- price/high/low/breakout
- candle/bar state
- session/time
- spread/news/filter state

### Position / cycle state

Examples:

- open-position count
- direction count
- average price
- last-entry price
- distance from entry/average
- basket/floating P/L
- holding time
- cycle state
- cooldown state

### Actions

Examples:

- emit BUY signal
- emit SELL signal
- add/grid position
- lot progression
- TP / SL
- virtual SL
- trailing
- basket trailing
- close
- time exit

### Composition

At minimum:

- AND
- OR
- explicit groups

Add NOT only where a reference or useful research case requires it.

## Dedicated panel

Do not overload the existing LOGIC / FILTER / PRESET workspace with Builder editing controls.

Target dedicated workspace:

```text
LOGIC BUILDER

Definition : [ Builder_A10_Entry_01 ]
Role       : [ ENTRY ]

GROUP A
  01 [ RSI        ] [ parameters... ]
     [ AND ]
  02 [ MA         ] [ parameters... ]

  [ OR ]

GROUP B
  03 [ ATR        ] [ parameters... ]
     [ AND ]
  04 [ BREAKOUT   ] [ parameters... ]

[VALIDATE] [SAVE] [LOAD] [REGISTER]
```

Slots must be typed. The UI is an editor for a structured definition; it must not be the only place where the logic exists.

## Data model first

Builder logic must be represented as data independent of screen objects.

Conceptual model:

```text
BuilderDefinition
  id
  name
  version
  role
  groups[]
    operator
    slots[]
      part_id
      part_version
      parameters
      enabled
  output/action
  compatibility/schema version
```

The runtime evaluates this definition. Panel controls edit it. SAVE/LOAD serializes it. Strategy Tester and forward/demo execution consume the same definition/runtime path.

Do not use hidden/off-screen chart objects as the source of truth for Builder state.

## Module registration

Verified/saved Builder definitions should eventually appear in the same selection architecture as code-defined modules.

Example:

```text
ENTRY
  O01
  A10
  ...
  BUILDER_E01

MANAGE
  O01
  A10
  ...
  BUILDER_M01

EXIT
  O01
  A10
  ...
  BUILDER_X01
```

No silent fallback is allowed. Missing part, incompatible version, invalid parameter, or invalid role must produce NOT REGISTERED / INVALID with a reason.

## Parity standard

For reference reproduction, compare all relevant observable decisions/state, including:

- signal direction
- entry time
- entry/reference/executable price as applicable
- lot
- additional/grid entries
- position/cycle count
- management transitions
- trailing transitions
- exit time
- exit reason
- final open/flat state
- P/L and DD where meaningful

Similar profit is not sufficient.

## First milestone

Do not begin with a universal Builder.

Milestone LB-01 is specifically **O01 Builder completion**:

1. Builder definition/schema v1
2. Part Registry v1
3. dedicated Builder panel shell
4. ordered empty slots
5. RSI part
6. MA part
7. ATR part
8. first required position/cycle-state part
9. role output/action part
10. AND/OR grouping
11. validation
12. named SAVE/LOAD
13. Module Registry bridge
14. O01 path reconstructed with Builder parts
15. O01 Reference vs Builder parity test
16. O01 Builder definition registered through the existing module architecture
17. O01 Builder demo-account operation
18. O01 Reference vs Builder forward/demo evidence recorded
19. verified O01 Builder definition frozen

Only after LB-01 completes through the O01 demo/forward gate should the central track proceed to A10. Continue thereafter in the fixed order A10 -> A11 -> A12 -> A13 -> A14 -> A15, adding generic reusable parts only as each next reference requires them.

## After reproduction

When the Builder can reproduce the reference set reliably, it becomes the primary research interface for new combinations.

Examples:

```text
Builder A10-like Entry
+ Builder custom Manage
+ Builder trailing Exit
```

or mixed verified modules:

```text
Builder Entry
+ A12 Manage
+ Builder Exit
```

These are new research identities and are not O01/A10-A15 parity implementations unless explicitly proven.

## Non-negotiable rules

1. GitHub is the durable source of truth.
2. Preserve frozen reference implementations.
3. Preserve FULL and SPLIT verification paths.
4. Builder research/parity remains NO_ORDERS unless a separate execution host is explicitly approved.
5. Never change a reference strategy merely to obtain Builder parity.
6. Never claim compile/parity PASS without actual evidence.
7. Use the same Builder runtime path for backtest and forward/demo validation.
8. UI changes must not alter trading decisions.
9. Invalid Builder definitions fail safely.
10. Every saved Builder definition has identity/version/schema information.
11. New parts should be generic and reusable where practical.
12. The central objective remains: **reproduce O01/A10-A15 with the Logic Builder, prove parity, then use the Builder for new Alpha research.**

## Decision rule

When choosing what to develop next, ask:

> Does this directly help reproduce, validate, register, test, or safely operate Builder-defined ENTRY / MANAGE / EXIT logic?

If yes, it belongs on the central roadmap.

If not, treat it as supporting or future work unless an explicit policy decision changes the roadmap.


## Right-side Builder workspace UI decision (2026-10-02)

The right-side workspace shall use the same tab concept and visual language as the left-side LOGIC / FILTER / PRESET selector.

Fixed top-level right workspace tabs:

```text
SLOT | EA LOGIC | EA PARTS
```

Responsibilities:

- **SLOT** — preserves the existing slot selection/enable workflow and existing route/runtime context.
- **EA LOGIC** — edits the Builder logic structure: role (ENTRY/MANAGE/EXIT), ordered slots, groups, AND/OR composition, validation, definition identity, SAVE/LOAD/REGISTER.
- **EA PARTS** — selects and edits one reusable Part Registry component used by EA LOGIC. It is not an independent strategy editor.

EA PARTS is therefore required, but it must be coupled to EA LOGIC through the same BuilderDefinition / Part Registry data model. Selecting a logic slot in EA LOGIC selects the corresponding part in EA PARTS; edits in EA PARTS update that selected Builder slot only after validation/apply. EA LOGIC must immediately reflect the resulting part identity/status.

The UI is not the source of truth. EA LOGIC and EA PARTS are two views/editors over the same structured Builder data.

Initial implementation is UI-only and non-invasive: preserve the verified v2.20 runtime, create a new versioned host, add the three right-side tabs and Builder workspace shells, and keep trading/runtime behavior unchanged. Do not connect Builder definitions to execution until the schema/Part Registry and O01 reproduction path are implemented and separately validated.


## Fixed UI concept — Free-slot Logic Builder (2026-10-02)

The Logic Builder must be designed as a **general-purpose empty-slot construction board**.

The primary UI concept is:

1. The Builder first presents an empty foundation containing ordered slots.
2. The user freely inserts reusable parts into those slots.
3. Indicator/condition parts such as RSI, MA, ATR, time, position state, etc. are parts.
4. Logical connectors such as **AND / OR are also user-placeable composition parts/controls**.
5. The user builds ENTRY / MANAGE / EXIT logic by arranging these parts rather than editing an O01-specific fixed form.
6. Selecting a placed part opens its parameters in EA PARTS for inspection/editing.
7. The structured BuilderDefinition remains the source of truth; the visible slot board is its editor/view.

Conceptual UI:

```text
EA LOGIC BUILDER

ENTRY
  [ SLOT 01 : RSI ]
  [ SLOT 02 : AND ]
  [ SLOT 03 : MA ]
  [ SLOT 04 : AND ]
  [ SLOT 05 : TIME ]
  [ SLOT 06 : BUY ]

MANAGE
  [ SLOT 01 : ... ]
  [ SLOT 02 : ... ]

EXIT
  [ SLOT 01 : ... ]
  [ SLOT 02 : ... ]
```

A different definition may freely use another composition, for example:

```text
[ RSI ] -> [ AND ] -> [ ATR ] -> [ OR ] -> [ BREAKOUT ] -> [ SELL ]
```

### Critical distinction

**The goal is not to create an O01-specific fixed Builder screen.**

O01 is the first reference strategy used to prove that the general-purpose slot Builder can reproduce an existing verified strategy.

Therefore the development order is:

```text
GENERAL EMPTY-SLOT FOUNDATION
        |
REUSABLE PARTS + AND/OR COMPOSITION
        |
RECONSTRUCT O01 USING ONLY THOSE PARTS
        |
O01 REFERENCE vs BUILDER PARITY
        |
FREEZE THE VERIFIED BUILDER FOUNDATION
        |
A10 -> A11 -> A12 -> A13 -> A14 -> A15
```

The current O01 Builder display is an intermediate verification view, not the final interaction model. Future UI work must move toward the free-slot construction board while preserving the data-model-first architecture, NO_ORDERS safety during research/parity, and the frozen reference implementations.
