# Multi Alpha v3.45 — Track B O01 L/F/G/H Classification v1.00

**Established:** 2026-10-07  
**Gate:** B-P0-1  
**Status:** CLASSIFICATION BASELINE — implementation must follow this ownership model  
**Baseline EA:** `Parity_Tests/MultiAlpha/MA_LD2A_O01BuilderBridge_v3_45.mq5`  
**Governing architecture:** `Docs/MultiAlpha_v3_45_Logic_Filter_GlobalSafety_Responsibility_v1_00.md`

## 1. Classification codes

- **L — Logic Part:** strategy construction item stored in ENTRY / GRID / MANAGE / EXIT LOGIC SLOT.
- **F — Filter reference Part:** strategy Part that reads a Filter Panel result. Filter numeric/configuration values remain owned by FILTER Panel.
- **G — Global Safety / Expert Property:** mandatory EA/account-wide safety or policy; not removable by Logic Builder.
- **H — Host / Execution infrastructure:** broker/platform/runtime mechanics; not a strategy Part.

Rule: only **L** and **F** are normal EA PARTS picker candidates.

## 2. ENTRY classification

| O01 behavior | Class | Builder representation | Ownership / reason |
|---|---|---|---|
| New-cycle / flat eligibility | L | `CYCLE_NEW` | strategy state condition |
| Emergency unlocked | G | Global Safety state, not user Part | emergency protection must not be removable |
| Session/time allowed | F | `FILTER_TIME_OK` | time configuration belongs to FILTER Panel |
| News clear | F | `FILTER_NEWS_OK` | news configuration belongs to FILTER Panel |
| Spread acceptable | F | `FILTER_SPREAD_OK` | spread limit/config belongs to FILTER Panel |
| ATR #1 range | L | `ATR_RANGE` | strategy indicator condition |
| ATR #2 range | L | `ATR_RANGE` | strategy indicator condition |
| BUY side count zero | L | `SIDE_COUNT` | strategy position-state condition |
| SELL side count zero | L | `SIDE_COUNT` | strategy position-state condition |
| RSI period/value/BUY < 30 | L | `RSI_THRESHOLD` | strategy signal |
| RSI period/value/SELL > 70 | L | `RSI_THRESHOLD` | strategy signal |
| BUY action | L | `BUY` | branch action |
| SELL action | L | `SELL` | branch action |
| AND / OR branch grammar | L | `AND` / `OR` | composition grammar |
| Initial lot policy | L/G boundary | strategy sizing Part or EA-wide sizing policy | O01-specific lot belongs to strategy only if slot-specific; global money-management policy belongs outside |
| One order per bar | L/H boundary | strategy guard backed by host bar state | user strategy may request it, host supplies reliable bar/order state |
| Symbol/Magic ownership | H | runtime ownership context | infrastructure |
| broker lot normalization | H | Execution Adapter | broker boundary |
| order send / retcode handling | H | Execution Adapter | infrastructure |

### ENTRY conclusion

Do **not** add `EMERGENCY_UNLOCKED` as a user-removable Part. Replace historical monolithic TIME/NEWS/SPREAD gates with F-reference Parts. Preserve ATR/RSI/side/action mechanics as L Parts.

## 3. GRID classification

| O01 behavior | Class | Builder representation | Ownership / reason |
|---|---|---|---|
| side/position count | L | `SIDE_COUNT` / `POSITION_COUNT` | strategy state |
| maximum grid orders | L | `MAX_ORDERS` | strategy mechanics |
| DD 12% Grid Pause | G | Global Safety `grid_pause_active` | mandatory safety, not removable |
| trailing pause policy | L | `TRAILING_PAUSE` | strategy interaction rule |
| allow grid outside entry session | L/F boundary | role placement/policy around `FILTER_TIME_OK` | shared time config is F; whether GRID requires it is strategy logic |
| news block for GRID | F | `FILTER_NEWS_OK` when required | shared news config |
| spread acceptable for add | F | `FILTER_SPREAD_OK` when required | shared spread config |
| one order per bar | L/H boundary | `ONE_ORDER_PER_BAR` + host state | strategy guard / host state |
| newest/last entry price | L/H data boundary | `LAST_PRICE` | strategy consumes runtime state |
| fixed grid distance | L | `FIXED_DISTANCE` | strategy mechanics |
| dynamic distance | L | `DYNAMIC_DISTANCE` | strategy mechanics |
| distance reached | L | `DISTANCE_REACHED` | strategy comparison/action gate |
| lot multiplier | L | `LOT_MULTIPLIER` | strategy sizing |
| max single lot | L/G boundary | `MAX_LOT` if strategy cap; Global Risk if universal cap | avoid duplicate owners |
| max total side lot | L/G boundary | `MAX_TOTAL_LOT` if strategy cap; Global Risk if universal cap | avoid duplicate owners |
| ADD BUY | L | `ADD_BUY` | action |
| ADD SELL | L | `ADD_SELL` | action |
| lot step/min/max broker normalization | H | Execution Adapter | broker boundary |
| order send / transition pending | H | Execution Adapter/runtime | infrastructure |

### GRID conclusion

Historical `DD_BELOW 12%` must **not** be required in a user-built GRID definition. Global Safety gates GRID execution independently. Time/News/Spread become Filter references only where the GRID strategy requires them.

## 4. MANAGE classification

| O01 behavior | Class | Builder representation | Ownership / reason |
|---|---|---|---|
| position count | L | `POSITION_COUNT` | strategy state |
| average price | L/H data boundary | `AVG_PRICE` | runtime supplies data; strategy consumes it |
| last price | L/H data boundary | `LAST_PRICE` | runtime supplies data |
| move points | L/H data boundary | `MOVE_POINTS` | derived runtime state |
| overlap / interaction state | L | `OVERLAP` | strategy-specific phase/interaction semantics |
| trailing state memory | L/H state boundary | typed Manage state | strategy semantics; host persists runtime state |
| reset on count change | L/H state boundary | Manage state rule | strategy semantics + host state lifecycle |

### MANAGE conclusion

MANAGE should contain strategy management semantics, not shared filters or Global Safety unless a strategy explicitly references a Filter result. Runtime provides position/price/state snapshots.

## 5. EXIT classification

| O01 behavior | Class | Builder representation | Ownership / reason |
|---|---|---|---|
| position count | L | `POSITION_COUNT` | exit condition state |
| average price | L/H data boundary | `AVG_PRICE` | runtime state consumed by logic |
| move points | L/H data boundary | `MOVE_POINTS` | derived runtime state |
| Virtual SL | L | `VIRTUAL_SL` | strategy exit mechanic |
| Single Fixed TP | L | `FIXED_TP` with explicit scope or dedicated semantic | strategy exit |
| Basket Fixed TP | L | `BASKET_FIXED_TP` | strategy exit |
| Single Money TP | L | `SINGLE_MONEY_TP` | strategy exit |
| Single Trailing | L | `SINGLE_TRAILING` | strategy exit |
| Basket Trailing | L | `BASKET_TRAILING` | strategy exit |
| Close opposite | L | `CLOSE_OPPOSITE` | strategy exit/action |
| Close side action | L/H boundary | logical `CLOSE_SIDE` -> Execution Adapter | logic requests, adapter executes |
| 15% Emergency Close | G | Global Safety forced close | never dependent on EXIT SLOT |
| emergency lock/post-emergency | G/H | Global Safety persistent state | safety/host persistence |
| broker close loop/retcodes | H | Execution Adapter | infrastructure |

### EXIT conclusion

Normal strategy exits remain editable L Parts. The 15% emergency close is **not an EXIT Part** and is allowed to override normal EXIT logic.

## 6. FILTER Panel ownership

FILTER Panel owns configuration/state production for shared reusable filters. Initial required interfaces:

| Filter | Panel owns | Logic sees |
|---|---|---|
| TIME | mode/session/day configuration | `FILTER_TIME_OK` |
| NEWS | enable/mode/currency/impact/before/after/fail policy as implemented | `FILTER_NEWS_OK` |
| SPREAD | enable/max spread policy | `FILTER_SPREAD_OK` |
| DAY | weekday permissions if separated from TIME | `FILTER_DAY_OK` |

The exact Filter Panel fields must follow the actual panel/source implementation. Do not invent unsupported settings during implementation.

A Filter-reference Part stores/reference semantics, not duplicate filter values.

## 7. Global Safety / Expert Properties ownership

Mandatory current safety baseline:

| Safety | Owner | Builder behavior |
|---|---|---|
| Warning DD 8% | G | telemetry/state; no removable Part |
| Grid Pause DD 12% | G | forcibly blocks GRID execution |
| Emergency Close DD 15% | G | forcibly closes owned positions with highest priority |
| emergency lock/post-emergency | G/H | blocks new risk according to configured policy |
| demo/live execution permission | H/G policy | execution boundary |
| hedging/account preflight | H | execution boundary |
| Symbol/Magic isolation | H | ownership boundary |

## 8. Corrections to the current canonical 40-Part migration view

The existing O01 canonical arrays are useful parity/migration artifacts, but some historical monolithic gates should no longer be treated as final user-owned Logic Parts.

Migration mapping:

- `EMERGENCY_UNLOCKED` -> **G state**, not final user Part.
- `TIME_ALLOWED` -> **F: FILTER_TIME_OK**.
- `NEWS_CLEAR` / `GRID_NEWS_CLEAR` -> **F: FILTER_NEWS_OK**.
- `SPREAD_OK` -> **F: FILTER_SPREAD_OK**.
- `DD_BELOW 12%` -> **G: Global Grid Pause**, not final user Part.
- `GRID_TIME_ALLOWED` -> express through Filter reference placement/policy rather than duplicate session values.
- indicator/position/distance/lot/trailing/TP/SL mechanics remain L unless separately promoted to a universal risk policy.

This mapping must be handled as a versioned migration; do not silently change the v3.45 reference arrays used for parity evidence.

## 9. B-P0-1 result

**Classification gate: PASS as architecture classification.**

This PASS means ownership has been decided for the current O01 behaviors. It does **not** mean the UI/Picker implementation is complete.

### Next implementation candidates

Highest-priority missing **F** Parts:
1. `FILTER_TIME_OK`
2. `FILTER_NEWS_OK`
3. `FILTER_SPREAD_OK`
4. `FILTER_DAY_OK` only if the existing Filter Panel exposes DAY separately.

Highest-priority missing/incorrect **L** Parts:
1. MANAGE `LAST_PRICE`
2. MANAGE `OVERLAP`
3. EXIT `POSITION_COUNT` correct picker mapping
4. EXIT `BASKET_FIXED_TP`
5. EXIT `SINGLE_MONEY_TP`
6. EXIT `CLOSE_OPPOSITE`
7. GRID `DISTANCE_REACHED` if retained as explicit generic comparison Part.

Do not add:
- user-removable `EMERGENCY_UNLOCKED`
- user-removable `DD_BELOW=12%` as the mandatory safety
- user-removable `EMERGENCY_CLOSE=15%`

## 10. Next gate — B-P0-2

Before changing v3.45 Runtime, inspect the existing FILTER Panel implementation and define the smallest typed Filter Context/API that can provide FILTER_TIME_OK / FILTER_NEWS_OK / FILTER_SPREAD_OK to the generic Interpreter.

Then update Part Schema + Picker + parameter/reference handling in a versioned Track-B component, with **NO change to verified v3.45 DEMO execution behavior**.

Required proof for B-P0-2:
- each F Part selectable from the correct role(s),
- emitted Part ID accepted by schema,
- no duplicate filter numeric configuration stored in the Part,
- deterministic Interpreter context can set true/false and change the branch decision,
- Global Safety remains independent.
