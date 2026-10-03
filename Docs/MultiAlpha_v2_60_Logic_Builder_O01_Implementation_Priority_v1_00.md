# Multi Alpha Research Lab — v2_60 Logic Builder / O01 Implementation Priority v1.00

**Established:** 2026-10-03  
**Status:** CURRENT HIGHEST-PRIORITY DEVELOPMENT DIRECTIVE  
**Baseline host:** `MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_60`

## 1. Development center

From this point, the center of development is the **LOGIC BUILDER**.

The immediate objective is not to create another permanent strategy-specific EA. The objective is to complete the general-purpose Builder so that a strategy is created only by independently building and combining:

```text
ENTRY MODULE  — built only with LOGIC BUILDER / generic EA PARTS
MANAGE MODULE — built only with LOGIC BUILDER / generic EA PARTS
EXIT MODULE   — built only with LOGIC BUILDER / generic EA PARTS
                         |
                         v
                  ONE BUILDER LOGIC
                         |
                         v
                       SLOT
                         |
                         v
                  COMMON RUNTIME
```

ENTRY, MANAGE and EXIT must remain independently buildable, saveable, loadable and replaceable.

## 2. v2_60 is the implementation baseline

The current `v2_60` panel/runtime generation is the practical baseline for continuing development.

Preserve its current user-facing concept:

```text
v2_60
  SLOT
  EA LOGIC / LOGIC BUILDER
    ENTRY
    MANAGE
    EXIT
  EA PARTS
  SAVE/LOAD 24
  SAVE/LOAD 72
```

Do not abandon v2_60 in favor of a separate small EA as the final product. New small gates/test EAs are allowed only as controlled verification tools for components that will be integrated into the v2_60 line.

The verified v2_60 file itself should remain preserved. Integration work proceeds in new versioned descendants (v2_61+ as appropriate) so the baseline can always be compared/regressed.

## 3. Current highest-priority proof case: O01

O01 is the first end-to-end Builder implementation target.

Required path:

```text
O01 ENTRY reference
      |
      v
generic ENTRY EA PARTS
      |
      v
ENTRY LOGIC BUILDER definition

O01 MANAGE reference
      |
      v
generic MANAGE EA PARTS
      |
      v
MANAGE LOGIC BUILDER definition

O01 EXIT reference
      |
      v
generic EXIT EA PARTS
      |
      v
EXIT LOGIC BUILDER definition

ENTRY + MANAGE + EXIT
          |
          v
    O01 Builder Route
          |
          v
     v2_60-line SLOT
          |
          v
 common Builder runtime
          |
          v
   DEMO account operation
```

O01-specific hard-coded runtime modules are not the final implementation. O01 is a reference/migration oracle used to prove that generic Builder parts can reconstruct the behavior.

## 4. Meaning of all current component tests

All current component tests are performed **for eventual integration into the v2_60 development line**.

This includes, but is not limited to:

- Symbol Resolver / broker-symbol specification tests
- persisted SAVE24 ENTRY evaluator/parity tests
- persisted SAVE24 MANAGE evaluator/parity tests
- persisted SAVE24 EXIT evaluator/parity tests
- persisted ENTRY -> MANAGE -> EXIT route tests
- Builder Definition / serialization tests
- Interpreter tests
- EA PARTS / parameter tests
- Context Provider / live-market read-only tests
- Safety gates
- Execution Adapter tests

A PASS on a standalone gate means:

> the component is verified enough for the tested scope to become a candidate for integration into the v2_60-line Builder runtime.

It does **not** mean that the standalone gate becomes a separate final EA or separate permanent architecture.

## 5. Already established O01 evidence and how it is used

Existing O01 parity work remains valid migration evidence. In particular, persisted generic Builder definitions have already been exercised for ENTRY, MANAGE and EXIT, and the persisted saved route has been tested as:

```text
persisted ENTRY SAVE24
        +
persisted MANAGE SAVE24
        +
persisted EXIT SAVE24
        |
        v
persisted generic Builder route
```

These tests prove pieces of Builder semantics. The next central work is to make the **actual v2_60 LOGIC BUILDER / EA PARTS / SLOT path** create, load, validate and execute those same generic concepts.

Do not substitute more test-only parity EAs for this integration milestone unless a specific integration risk requires an isolated gate.

## 6. O01 Builder integration order in v2_60 line

### Step 1 — ENTRY Builder integration
Implement the generic parts required to construct O01 ENTRY in the actual v2_60 EA PARTS UI.

The user must be able to:
1. select ENTRY,
2. choose generic parts,
3. edit their parameters,
4. APPLY them to slots,
5. validate,
6. SAVE24,
7. LOAD24,
8. obtain the same Builder definition semantics used by runtime.

### Step 2 — MANAGE Builder integration
Implement the generic position/cycle/grid/lot/filter/action parts required for O01 MANAGE in the same v2_60 Builder workflow.

### Step 3 — EXIT Builder integration
Implement the generic TP / virtual SL / single trailing / basket trailing / close/state parts required for O01 EXIT in the same workflow.

### Step 4 — Compose one logic
Combine the independently saved ENTRY + MANAGE + EXIT modules as one Builder Route assigned to a SLOT.

### Step 5 — NO_ORDERS integration gate
Run the v2_60-line host with the actual Builder definitions and verify:
- definition loading,
- role boundaries,
- route validation,
- Symbol Resolver,
- Context Provider,
- decisions,
- state ownership,
- no broker actions.

### Step 6 — Strategy Tester / market-context gate
Confirm that the exact definitions created/saved by the v2_60 Builder are the definitions consumed by the common runtime.

### Step 7 — single-instance DEMO
After the above gates pass, connect the validated Builder route through Safety/Risk and the Execution Adapter and run O01 Builder on the demo account.

The first demo milestone does not require completion of all future #01-#50 portfolio functionality.

## 7. Symbol Resolver policy

Symbol Resolver is infrastructure for the v2_60-line Builder runtime.

Its purpose is to keep Builder definitions broker-independent:

```text
Builder logical symbol: XAUUSD
            |
            v
      Symbol Resolver
            |
            v
broker symbol: e.g. XAUUSD-m
```

It must not become a separate product path. The verified resolver is integrated below the SLOT/route layer and above broker/context access.

## 8. Generic-parts rule

When O01 requires a missing capability, implement it as a reusable generic part whenever possible.

Allowed direction:
- RSI with parameters
- TIME/session
- SPREAD
- SIDE/POSITION COUNT
- FIXED DISTANCE
- DYNAMIC DISTANCE
- LOT MULTIPLIER
- MAX LOT / MAX TOTAL LOT
- FIXED TP
- VIRTUAL SL
- SINGLE TRAILING
- BASKET TRAILING
- BUY / SELL / ADD / CLOSE actions
- AND / OR and required composition

Avoid:
- O01_RSI
- O01_GRID
- O01_EXIT_SPECIAL
- hidden calls from Builder definitions into a dedicated O01 runtime engine

The same generic parts must be reusable for later A10-A15 migration and new Alpha research.

## 9. Completion condition for the current milestone

The O01 milestone is complete only when:

1. O01 ENTRY is built in the v2_60-line LOGIC BUILDER using generic EA PARTS.
2. O01 MANAGE is built the same way.
3. O01 EXIT is built the same way.
4. All three are independently SAVE/LOAD capable.
5. They combine into one SLOT/route.
6. Runtime consumes the saved Builder definitions; there is no hidden O01 strategy implementation.
7. broker symbol resolution required by the demo account is integrated and validated.
8. NO_ORDERS and Strategy Tester evidence pass.
9. the route is run on the demo account through the controlled execution boundary.
10. actual forward evidence is recorded.

Only then move the central migration target to A10.

## 10. Development decision rule

Before creating any new test, module or infrastructure component, answer:

> **What exact part of the v2_60-line LOGIC BUILDER / SLOT / common runtime will this be integrated into?**

If that integration purpose is unclear, it is not a current-priority task.

GitHub remains the durable source of truth, and actual MetaEditor/MT5 compile/runtime evidence remains the PASS gate.

---

## 11. Fixed #01-#50 independent-instance ownership rule (2026-10-03)

The governing ownership policy is documented in:

Docs/MultiAlpha_v2_60_50_Independent_Instance_Ownership_Policy_v1_00.md

For all v2_60-line implementation work:

- #01-#50 are 50 independent strategy/EA instances inside the Multi Alpha host, not mere storage slots.
- Magic Number is instance-local. There is no one global Magic shared by all 50 instances.
- Symbol, SLOT-local FILTER, ENTRY/MANAGE/EXIT selection and mutable runtime state are instance-local.
- Multiple instances may trade the same symbol while remaining isolated by validated ownership identity/Magic and state.
- Saved Builder definitions may be reused by multiple instances, but mutable cycle/grid/trailing/position state must never be shared.
- The 8% Warning / 12% Grid Pause / 15% Emergency Close ladder is EA-global safety and remains outside Builder logic in Expert Properties.
- O01 #01 demo may be the first execution milestone, but it must already use the ownership/state model that can scale to #01-#50.

This rule supersedes any earlier wording that implies one global Magic Number for the complete EA or treats the 50 SLOTs as passive save locations.
