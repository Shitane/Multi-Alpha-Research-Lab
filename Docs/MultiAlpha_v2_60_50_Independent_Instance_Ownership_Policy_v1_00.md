# Multi Alpha Research Lab — v2_60 50 Independent Instance / Ownership Policy v1.00

**Established:** 2026-10-03  
**Status:** GOVERNING ARCHITECTURE DECISION  
**Implementation baseline:** MultiAlpha_Runtime_Panel_A10FullPanel_NoOrders_v2_60

## 1. Fixed decision

The v2_60 development line shall operate #01 through #50 as **50 independent strategy/EA instances inside one Multi Alpha host**.

The 50 SLOT buttons are not merely storage slots. Each SLOT represents an independently configured and independently owned runtime instance. This does not require attaching 50 EA programs to 50 MT5 charts; one host may schedule them, but each instance must behave as an independent EA with respect to strategy, ownership and mutable state.

## 2. Magic Number is instance-local

There shall be **no single global Magic Number shared by #01-#50**.

    #01 -> Magic #01
    #02 -> Magic #02
    #03 -> Magic #03
    ...
    #50 -> Magic #50

Magic Number is persistent Instance/SLOT configuration. The selected SLOT must display/configure its own Magic Number. Duplicate active ownership that could make two instances indistinguishable must fail validation. Position/order ownership must never be determined by symbol alone.

A Magic Base may exist only as an optional convenience for generating initial unique values. It is not the runtime identity by itself and must not override each instance's stored Magic.

## 3. Each instance owns its complete strategy context

Each #01-#50 instance independently owns at least:

- Instance ID and ENABLE state
- Logical Symbol and resolved Broker Symbol
- Magic Number
- saved ENTRY Builder module selection
- saved MANAGE Builder module selection
- saved EXIT Builder module selection
- SLOT-local FILTER settings
- route/version and validation status
- position/order ownership state
- cycle and BUY/SELL side state
- position count, average/last entry price and lot state where required
- grid level/state and one-order-per-bar state
- trailing state
- ENTRY/MANAGE/EXIT runtime state
- instance-local P/L/diagnostics required by runtime

State from one instance must never leak into another. #01 trailing activation, last-bar state, cycle state or grid level must not alter #02 even when both trade the same broker symbol.

## 4. Same symbol is allowed

Multiple instances may intentionally trade the same symbol:

    #01  XAUUSD -> XAUUSD-m  Magic 46102031  ENTRY-A / MANAGE-A / EXIT-A
    #02  XAUUSD -> XAUUSD-m  Magic 46102032  ENTRY-B / MANAGE-B / EXIT-B
    #03  XAUUSD -> XAUUSD-m  Magic 46102033  ENTRY-A / MANAGE-C / EXIT-D

They remain independent through validated instance identity/Magic and instance-local state.

## 5. Builder definitions may be shared; runtime state may not

Saved Builder definitions are reusable. Multiple instances may select the same ENTRY/MANAGE/EXIT definition. Mutable runtime state produced while executing that definition is always instance-local.

    Saved Builder Definition
             |
        +----+----+
        |         |
      #01       #02
    state#01   state#02

## 6. FILTER is SLOT-local

The existing v2_60 left panel already states VIEWING SLOT #xx / SLOT-LOCAL SETTINGS. Preserve this model.

TIME, FOMC, NEWS, NFP, CPI, MONTH END/START, QTR END, YEAR END, ROLLOVER, FRIDAY, SPREAD, VOLATILITY and compatible future filters are stored per instance unless a later explicit architecture decision reclassifies them.

Selecting #01 edits #01 FILTER settings. Selecting #02 edits #02 FILTER settings. Builder parts may query the current instance's filter state through a generic context boundary.

## 7. Global Safety remains outside strategy instances

The DD safety ladder is **EA-global safety**, not Builder logic:

    Warning DD           8%
    Grid Pause DD       12%
    Emergency Close DD  15%

These settings belong in Expert Properties / Global Safety and surround all independent instances:

    #01 ... #50 independent strategy decisions
                     |
                     v
              EA GLOBAL SAFETY
              8% -> 12% -> 15%
                     |
                     v
             Execution boundary

Normal EXIT Builder decisions are strategy decisions. Emergency Close is a higher-priority EA-wide safety action and must not be hidden in O01 or another strategy-specific EXIT definition.

## 8. Expert Properties responsibility

Expert Properties contain host/environment and genuinely EA-global safety only, including Execution Mode, broker/environment configuration, Symbol Resolver mode/mapping controls as appropriate, and Global Safety 8/12/15.

The following must not be one global property shared by all instances:

- Magic Number
- instance Symbol
- instance FILTER settings
- instance ENTRY/MANAGE/EXIT route
- RSI/MA/ATR strategy parameters
- grid distance / lot progression
- TP/SL/trailing strategy parameters

## 9. v2_60 panel responsibility

Preserve the existing #01-#50 SLOT selector. Selecting a SLOT changes the complete instance editing/view context.

Target detail:

    INSTANCE #01
    ENABLE         ON
    LOGICAL SYMBOL XAUUSD
    BROKER SYMBOL  XAUUSD-m
    MAGIC          46102031
    ENTRY          saved ENTRY module
    MANAGE         saved MANAGE module
    EXIT           saved EXIT module
    FILTER         SLOT-LOCAL
    STATE          READY / INVALID reason

EA LOGIC remains the ENTRY/MANAGE/EXIT Builder editor. EA PARTS remains the generic part/parameter editor.

## 10. Symbol Resolver relationship

Symbol Resolver is shared infrastructure but its result is consumed per instance. A shared broker symbol does not merge ownership or state.

    #01 logical XAUUSD -> Resolver -> XAUUSD-m -> #01 context
    #02 logical XAUUSD -> Resolver -> XAUUSD-m -> #02 context
    #03 logical GBPUSD -> Resolver -> GBPUSD-m -> #03 context

## 11. Runtime implementation requirement

The runtime model must provide an explicit 50-instance container, conceptually StrategyInstance[50]. Any currently global mutable strategy variable in v2_60 must be audited before multi-instance execution and moved to instance-local state when it represents strategy state.

Shared read-only services may remain shared, such as symbol metadata caches, calendar/news services or Builder definition libraries, provided returned context is correctly scoped.

## 12. Fail-closed validation

An enabled instance is not READY unless its ID and Magic are ownership-safe, symbol resolves unambiguously, broker context is available, ENTRY/MANAGE/EXIT definitions validate, SLOT-local FILTER validates, no active ownership conflict exists, and required runtime state/context is available.

Invalid instances do not trade and do not silently fall back.

## 13. O01 Builder milestone

O01 remains the first Builder proof. The first demo may use #01 only, but #01 must already use the same instance-local ownership model intended for #01-#50: own Magic, Symbol, FILTER, ENTRY/MANAGE/EXIT definitions and runtime state, under the common Global Safety layer.

Scaling later to multiple simultaneous instances must not require changing O01 Builder semantics or introducing shared strategy state.

## 14. Non-negotiable checks

Before accepting a v2_60-line integration change, verify that it does not:

- reintroduce one global Magic for all instances
- make Symbol the sole ownership key
- share mutable cycle/grid/trailing state across instances
- move 8/12/15 Global Safety into Builder definitions
- hard-code O01 as a permanent runtime strategy
- turn #01-#50 back into mere storage without independent runtime identity

GitHub is the durable source of truth. Actual MetaEditor/MT5 compile/runtime evidence remains required for PASS.
