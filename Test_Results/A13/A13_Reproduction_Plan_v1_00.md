# A13 Reproduction Plan v1.00

Source: `Original_EA/A13/A_13_GDS_Renko_Dual_MA_Demo.mq5` (Golden Delta v1.10)

## Goal
Reproduce A13 decisions and virtual lifecycle in NoOrders form before module extraction or optimization.

## Original defaults
- Brick size: 6.0 price units
- Fast SMA: 9 completed Renko closes
- Slow SMA: 152 completed Renko closes
- Minimum MA separation: 4.15 bricks
- Entry run: 2 completed same-direction bricks
- Virtual TP: 55.0 bricks
- Virtual SL: 32.0 bricks
- Max hold: 1440 minutes
- Cooldown: 16 completed bricks after exit
- Max spread: 0.35 * effective brick size
- Lots: 0.01
- Magic: 26091051

## Renko rules
- Input price is BID tick.
- Price is converted to integer tick-size units with MathRound.
- First valid BID anchors the builder and creates no brick.
- Fixed-size classic Renko with two-brick reversal.
- Continuation requires one brick.
- Reversal requires a two-brick move; first reversal brick opens one brick beyond previous close, then closes another brick in the reversal direction.
- Multiple bricks can be emitted from one tick.
- Maximum 4096 bricks per tick; larger gap/failure permanently pauses new Renko processing/entries while price exits remain active.
- Run count resets to 1 when direction changes.

## Dual SMA / signal rules
- Only completed Renko closes enter the MA buffers.
- No MA decision until 152 completed closes exist.
- Fast SMA uses the most recent 9 of the 152 stored closes.
- Alignment BUY when fast > slow + 4.15 * effective brick size (with 1e-9 epsilon).
- Alignment SELL when fast < slow - 4.15 * effective brick size (with epsilon).
- Entry signal additionally requires completed brick direction == alignment and brick.run >= 2.
- When multiple bricks are generated on one BID tick, only the final brick's signal/alignment survives for the trade decision.

## Existing-position exit rules
Tick-level virtual exits use executable close price:
- BUY: BID
- SELL: ASK
- TP first, then SL, then TIME.
- TP distance = 55 * effective brick.
- SL distance = 32 * effective brick.
- TIME at held_seconds >= 1440 * 60.
Completed-brick MA alignment can request MA_FLIP when nonzero alignment is opposite the held position.

Original exit priority in OnTick:
1. retry pending exit
2. price TP/SL/TIME check
3. retry exit
4. BID Renko update / possible MA_FLIP
5. retry exit

## Entry executable price and gates
- BUY entry uses ASK; SELL entry uses BID.
- Spread must be <= effective brick * 0.35.
- No entry if any position already exists on the symbol, even another magic.
- No entry if any active order exists on the symbol.
- Direction must be allowed by symbol trade mode.
- Market orders must be supported.
- Requested volume is normalized to min/max/step.
- Original broker execution includes OrderCheck/OrderSend retry and uncertainty handling. NoOrders reproduction must NOT send orders.

## Cooldown/lifecycle details
- Cooldown begins only after exit completion and is set to 16 bricks.
- On a tick producing n completed bricks, cooldown is decremented by n after all n bricks update the MA state.
- If cooldown reaches zero on that batch, entry may be considered from that batch's final signal, unless an exit occurred on the same tick.
- g_closed_this_tick prevents same-tick re-entry after an exit.
- g_exit_pending also blocks entry.
- Original broker position/open price/open time are authoritative; NoOrders reproduction must virtualize these while preserving executable price and timing.

## Baseline to establish
Use the common baseline unless source behavior forces otherwise:
- XAUUSD_DUKA
- M15
- 2026-08-16 through 2026-08-29
- real ticks
- JPY 100000
- original default A13 inputs

First run the original EA and record exact broker lifecycle. Then run A13 NoOrders reproduction and compare:
- brick count and final Renko state
- raw signals
- entries/exits/open state
- timestamps/time_msc
- directions
- executable prices
- exit reasons
- cooldown behavior

## Safety
All reproduction/parity code remains NO_ORDERS=1 / VIRTUAL_NOT_FILL=1. Do not call OrderCheck, OrderSend, or CTrade from the NoOrders implementation.
