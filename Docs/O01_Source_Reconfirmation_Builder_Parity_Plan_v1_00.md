# O01 Source Reconfirmation and Builder Parity Plan v1.00

## Status
This is the active implementation plan after the new-panel basic design agreement.

Development baseline:
`Parity_Tests/MultiAlpha/MA_LD2A_SlotBasicInfoFix_v3_11.mq5`

Frozen O01 whole-path reference:
`O01_GSG_RSI30_Monolithic_Module_v1_00.mqh`

Rule: do not treat the current Builder O01 seed as equivalent merely because names/default values look similar. Every behavior must be checked against the frozen O01 source.

## Gate O01-R1 — Source inventory and behavior matrix
Reconfirm the frozen O01 source item by item:
- ENTRY
- GRID
- MANAGE
- EXIT
- RSI / ATR conditions
- grid-add conditions
- TP / basket / trailing
- time/session conditions
- DD safety interaction
- position and lot management
- O01-specific exception behavior

Produce a source-to-role/Part matrix before changing Builder behavior.

Initial source facts already visible in the frozen reference include:
- RSI period 8; BUY below 30; SELL above 70.
- ATR1 period 15 on current timeframe and ATR2 period 15 with configurable timeframe; both use min/max point ranges.
- Initial lot 0.01; lot multiplier 1.50; max lot 5.00; max 10 orders per side; max total lots per side 1.20.
- Fixed grid distance 200 points; dynamic distance begins at order 3 from 300 points with multiplier 1.20.
- One order per bar.
- Single TP default 110 points (or money mode 15.0); basket TP 100 points.
- Virtual SL 1500 points.
- Single trailing defaults 110/60/50/10; basket trailing 100/50/50/10.
- Grid may be paused while trailing.
- Default time mode AUTO_GMT, 07:00-11:00 GMT; SERVER_TIME reference 10:00-14:00.
- DD Warning 8%, Grid Pause 12%, Emergency Close 15%; default post-emergency behavior STOP_UNTIL_NEXT_SESSION.
- Existing positions are managed outside the new-cycle session.
- Emergency close is evaluated before normal side management.
- News modes can block new cycles and, in MANAGE_ONLY mode, block grid while protection remains active.
- Overlap logic exists and must not be lost: default enabled, order threshold 8, overlap percent 3.0.
- Optional close-opposite-after-TP/SL/trailing behavior exists and must be classified.
- Hedging-account requirement, demo lock and XAUUSD restriction belong to execution/host safety and must not be confused with reusable strategy Parts.

## Gate O01-R2 — 40 Parts reproduction
For each canonical role in order:
1. ENTRY
2. GRID
3. MANAGE
4. EXIT

Map frozen O01 behavior to the 40-Part Builder definition.

Verify:
- exact Part identity
- exact parameter values
- Part order
- AND/OR semantics and precedence
- evaluation order
- side-specific BUY/SELL behavior
- stateful behavior that cannot be represented as a simple stateless Part
- cross-role dependencies

Do not force a source behavior into an incorrect existing Part. If a required semantic is missing, add a generic reusable Part at this gate.

The current generic O01 seed is only a candidate representation and must be audited. In particular, the audit must cover source behaviors not obviously represented by the seed, including ATR ranges, time/session gating, news/spread gates, overlap, TP mode distinctions, opposite-side close option, DD interaction, and stateful trailing.

## Gate O01-R3 — NO_ORDERS whole-path parity
Keep:
- NO_ORDERS=1
- VIRTUAL_NOT_FILL=1

Run the Builder O01 through the real generic path:
`Parts -> Module -> Strategy -> Dispatcher`

Compare its decisions/events with the frozen O01 reference on the same market data.

Do not proceed to broker orders while meaningful decision/event mismatches remain.

Parity evidence should include at minimum:
- initial entry decisions
- grid-add decisions
- exit decisions
- single trailing activation/exit
- basket trailing activation/exit
- virtual SL
- time/news/spread blocks where exercised
- DD warning/grid-pause/emergency behavior where exercised
- resulting virtual position lifecycle

Use the previously frozen O01 regression evidence as a reference where applicable, but rerun/extend tests when the new 4-role Builder path changes semantics.

## Gate O01-R4 — Demo execution opening
Only after O01-R3 parity is accepted, add/enable the minimum real-order route for a demo account.

Open execution incrementally:
1. ENTRY at minimum lot
2. GRID
3. MANAGE
4. EXIT

Validate before continuous operation:
- Magic isolation
- Symbol Resolver output
- demo-account safety lock
- hedging-account requirement where O01 requires it
- restart recovery of open positions/state
- order-send failure handling
- close failure handling
- duplicate-order prevention
- one-order-per-bar state after restart
- lot normalization/broker volume constraints
- position filtering by resolved symbol + Magic
- trailing state reconstruction/recovery
- emergency-lock persistence
- no collision with the frozen/reference O01 instance

## Gate O01-R5 — Continuous demo operation
Run the O01 Builder version continuously on the demo account.

Acceptance requires evidence that the Builder path, not a hidden O01-specific fallback, owns decisions and execution.

Collect runtime evidence for:
- ENTRY -> GRID -> MANAGE -> EXIT lifecycle
- restart/re-attach behavior
- Symbol + Magic isolation
- order failures/retries if encountered
- DD safety behavior
- no duplicate orders
- persistence/recovery

Only after this gate should broad cleanup/refactoring begin.

## After O01 completion
After functional demo validation:
1. inspect and clean/refactor the implementation without changing confirmed behavior
2. retain working EA LOGIC / EA PARTS / Interpreter / Runtime components
3. then implement the new left-side one-panel architecture defined in:
   `Docs/MultiAlpha_New_Panel_Basic_Design_v1_00.md`

Do not redesign working Builder internals merely to satisfy the new panel layout.
