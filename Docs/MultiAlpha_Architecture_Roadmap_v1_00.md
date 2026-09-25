# Multi Alpha Research Lab — Architecture & Development Roadmap v1.00

## 1. Final goal

Build one MT5 EA that can run **multiple symbols and multiple strategies simultaneously** in order to increase the number of independent trading opportunities.

The final system must not treat the panel as a switch that stops one strategy and starts another. All enabled strategy instances continue running in the background. The panel is a **monitoring and configuration console** that selects which instance/module is currently displayed and edited.

A Strategy Instance is identified by at least:

- Strategy Instance ID
- Symbol
- Entry module
- Manage module
- Exit module
- Magic / position ownership identifier
- Enabled state
- Independent runtime state

Example:

```text
Instance #1  XAUUSD  Entry=O01  Manage=O01  Exit=O01  ON
Instance #2  XAUUSD  Entry=A14  Manage=A14  Exit=O01  ON
Instance #3  GBPUSD  Entry=A15  Manage=A15  Exit=A15  ON
```

All enabled instances may run simultaneously.

---

## 2. Fundamental module architecture

Every strategy should ultimately support four logical layers.

### FULL

A frozen reproduction of the original EA behavior. FULL is the reference implementation used for parity testing. It must not be silently rewritten as a composition of split modules.

### ENTRY

Responsible only for deciding when a new trading cycle / initial position should be opened.

ENTRY has its own independent settings.

### MANAGE

Responsible for position/cycle management after entry, including strategy-specific behavior such as:

- grid/additional positions
- grid distance
- lot progression
- max orders
- position-count state
- basket state
- other management behavior that is neither pure initial entry nor final exit

MANAGE has its own independent settings.

### EXIT

Responsible for closing positions/cycles, including strategy-specific:

- TP / SL
- virtual SL
- single-position trailing
- basket trailing
- time exit
- other exit rules

EXIT has its own independent settings.

The target design is therefore:

```text
ENTRY -> MANAGE -> EXIT
           |
        SAFETY
```

SAFETY is controlled at a higher Core level where appropriate.

---

## 3. Full mode and Modular mode

The system must support two distinct operating modes.

### FULL mode

```text
Mode = FULL
Full Module = O01
```

Runs the frozen original/reproduction module.

Purpose:

- original-EA reproduction
- reference behavior
- parity validation
- safe demo validation before modular experiments

### MODULAR mode

```text
Mode   = MODULAR
Entry  = O01 Entry
Manage = O01 Manage
Exit   = O01 Exit
```

The three modules are independently selectable.

After same-strategy parity is proven, research combinations may include:

```text
Entry=A14 + Manage=O01 + Exit=O01
Entry=O01 + Manage=O01 + Exit=A14
```

Cross-strategy combinations are research configurations and must not be assumed equivalent to any original EA.

---

## 4. Mandatory parity rule

Do not modify a parity-passed trading implementation merely to support the new architecture.

Use adapters, routers, interfaces, or wrappers outside the frozen logic.

For each strategy, development order is:

1. Preserve FULL reference.
2. Create ENTRY / MANAGE / EXIT modules.
3. Run FULL and split version under identical conditions.
4. Compare event-level behavior.
5. Require parity before declaring the split implementation complete.
6. Only after parity, permit cross-module research combinations.

For O01, the already established parity baseline must remain protected. Existing parity-passed O01 logic is the reference and should not be altered by panel work.

---

## 5. Strategy Instance isolation

Every simultaneously running instance must own its state independently.

At minimum isolate:

- symbol
- Magic / Strategy ID
- cycle state
- entry state
- grid/manage state
- exit/trailing state
- open position count
- lots
- average price
- last close reason
- timestamps
- module settings
- runtime statistics

One instance's EXIT must never accidentally close another instance's positions.

Symbol alone is not sufficient for ownership because multiple strategies may trade the same symbol.

---

## 6. Multi-symbol operation

The Core must not depend only on the chart symbol or chart tick stream.

Final architecture must be capable of supervising multiple configured symbols from one EA.

Each Strategy Instance must receive/update the market data needed by its own symbol and timeframe(s).

Do not assume:

```text
_Symbol == strategy symbol
```

throughout shared Core code.

---

## 7. Safety architecture

Separate strategy trading logic from common safety control.

Target hierarchy:

```text
Strategy safety
      ↓
Symbol safety
      ↓
Account safety
```

Current O01 safety baseline includes:

- Warning DD = 8%
- Grid Pause DD = 12%
- Emergency Close DD = 15%

The scope of each safety rule must be explicit. Do not mix account-wide Balance/Equity logic with per-strategy DD without naming the scope.

Emergency behavior must also define what happens after emergency close, e.g. manual stop, next-session resume, or configured continuation.

---

## 8. Panel role

The panel is **not** a single-strategy on/off replacement mechanism.

Changing:

```text
View Symbol = XAUUSD
View Logic  = O01
```

changes what the operator is viewing/editing. It does not automatically stop other enabled strategy instances.

The panel must distinguish clearly between:

- Selected/Viewed instance
- Enabled/Disabled state
- Running state
- Trading/Managing-only state
- Emergency/Safety state

---

## 9. Fixed panel framework

The panel layout framework should be fixed so individual strategy modules cannot freely place controls and create overlaps.

The common Panel Core owns:

- panel dimensions
- margins
- row height
- label column
- value/edit column
- section spacing
- buttons
- page/navigation layout

Strategy-specific pages provide **what settings to show**, not arbitrary screen coordinates.

This is intended to eliminate label/edit-field overlap.

---

## 10. Panel appearance settings

Layout remains fixed, but appearance may be configurable.

Target appearance settings:

- background opacity
- background color
- normal text color
- title color
- section-heading color
- value/status color
- border color
- warning color
- limited font-size selection

Recommended presets:

- DEMO DARK
- DARK
- LIGHT
- CUSTOM

The current demo-EA-like semi-transparent dark appearance should be available as a default/preset.

Do not expose arbitrary X/Y positioning as user settings.

---

## 11. Dynamic module settings in the panel

ENTRY, MANAGE and EXIT are selected and configured independently.

Conceptual panel:

```text
STRATEGY INSTANCE #1
Symbol  : XAUUSD
Enabled : ON

ENTRY
Module  : O01 Entry
[O01 Entry settings]

MANAGE
Module  : O01 Manage
[O01 Manage settings]

EXIT
Module  : O01 Exit
[O01 Exit settings]

SAFETY
[common / scoped safety settings]

STATUS
[runtime state]
```

If Entry changes from O01 to A14, only the ENTRY settings area changes to A14's schema. Manage and Exit selections/settings remain unchanged.

The same principle applies independently to Manage and Exit.

---

## 12. Runtime settings requirements

Settings must be stored per Strategy Instance and per module role.

Changing one instance must not overwrite another instance's settings.

APPLY / SAVE / LOAD must preserve this separation.

If a setting change requires rebuilding technical-indicator handles (for example RSI/ATR period or timeframe), APPLY/LOAD must safely release and recreate the affected handles.

Unshown settings must be stored in settings/state structures. Do not create hidden OBJ_EDIT controls off-screen merely to preserve values.

---

## 13. Panel status target

Common status should eventually support items such as:

- selected Strategy Instance
- Symbol
- Entry / Manage / Exit module IDs
- Server GMT
- trade window
- state
- cycle
- position/order count
- lots
- floating P/L
- today P/L
- total P/L
- DD
- last close reason
- news stop / next stop time
- safety state

Research NoOrders hosts must clearly label virtual state and must not imply that virtual positions are real broker positions.

---

## 14. O01 immediate development path

Do not block the near-term O01 demo test while the complete multi-strategy architecture is being built.

Use two development lines.

### Stable/demo line

Use the verified O01 FULL/reference behavior as the basis for the demo-order version.

The research/core/parity NoOrders versions remain NO ORDERS.

A real-order demo EA must be a clearly separate file/host and must not silently convert a NoOrders parity host into an order-sending EA.

### Architecture/research line

Develop the future framework in parallel:

1. fixed panel framework
2. Strategy Instance model
3. module interfaces/router
4. O01 ENTRY / MANAGE / EXIT formal split
5. independent settings schemas
6. same-O01 FULL-vs-MODULAR parity
7. multi-instance support
8. multi-symbol support
9. cross-module research combinations

---

## 15. O01 source organization target

Target organization:

```text
Original_EA/O01/
  Gold_Session_Guard_v4_Experimental_03_RSI30.mq5

Modules/O01/
  O01_GSG_RSI30_Monolithic_Module_v1_00.mqh
  O01_Full_Module_...
  O01_Entry_Module_...
  O01_Manage_Module_...
  O01_Exit_Module_...
  O01_Core_Interface_...
  O01_Runtime_Settings_...
  O01_Panel_Page_...

Parity_Tests/O01/
  O01_GSG_RSI30_Parity_Demo_v1_00.mq5
  O01_*_NoOrders_*.mq5

Demo/O01/
  O01_*_Runtime_Demo_*.mq5

Modules/Common/
  MultiAlpha_Strategy_Instance_...
  MultiAlpha_Module_Interfaces_...
  MultiAlpha_Module_Router_...
  MultiAlpha_Panel_Framework_...
  MultiAlpha_Safety_...
```

Before moving existing files, inspect and repair include dependencies. Do not move files merely for cosmetic organization if that breaks a verified build.

---

## 16. Development gates

A feature is not considered complete merely because code was written.

### Compile gate

- 0 errors
- target: 0 warnings

### Parity gate

For reproduction/split work:

- identical test conditions
- event-level comparison
- differences documented
- PASS required before freezing

### Safety gate

For order-sending demo hosts:

- correct Magic/Strategy ownership
- correct symbol ownership
- correct position filtering
- emergency-close scope confirmed
- no cross-instance closing
- restart/state behavior checked

### UI gate

- no text/control overlap
- panel remains readable over chart
- opacity/colors work
- APPLY/SAVE/LOAD work
- selected/viewed instance is distinct from enabled/running state

### Multi-instance gate

Before declaring simultaneous operation ready:

- two instances can run without state contamination
- same-symbol/different-Magic isolation verified
- independent module settings verified

### Multi-symbol gate

Before declaring one-EA multi-symbol operation ready:

- market-data updates are not dependent solely on chart symbol
- each symbol's indicators/data are updated correctly
- symbol-specific trading properties are respected

---

## 17. Non-negotiable safeguards

1. Keep research/core/parity code NoOrders unless a file is explicitly designated as a demo order-sending host.
2. Never silently add broker order execution to an existing NoOrders parity file.
3. Preserve frozen parity baselines.
4. Separate display selection from strategy execution.
5. Separate Entry, Manage and Exit settings.
6. Isolate every Strategy Instance by symbol + strategy/Magic identity.
7. Do not let one module directly manipulate another instance's positions.
8. Do not claim compile, parity, or demo validation until it has actually been run.
9. Prefer adapters/interfaces around proven logic over rewriting proven logic.
10. The final architectural objective remains: **one EA, multiple symbols, multiple simultaneous strategies, increased independent trade opportunities.**

---

## 18. Next implementation milestone

The next architecture milestone is a **v1.40 foundation**, not another sequence of pixel-only panel fixes.

v1.40 should establish:

1. fixed panel layout framework
2. appearance/theme settings separated from layout
3. Strategy Instance identity
4. Viewed Instance vs Enabled/Running separation
5. ENTRY / MANAGE / EXIT module-selection model
6. independent settings containers
7. O01 as the first supported strategy page
8. preserved NoOrders behavior for the research host
9. no change to frozen O01 trading decisions

After that foundation compiles cleanly, O01 FULL demo execution can continue on the separate demo line while the modular architecture is expanded and parity-tested.
