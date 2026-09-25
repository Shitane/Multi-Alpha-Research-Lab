# A14 parity baseline

Common test window:
- XAUUSD_DUKA / M15
- 2026-08-16 00:00 through 2026-08-29 00:00
- Real ticks
- Deposit JPY 100000
- Leverage 1:100

## NoOrders reproduction v1.00 result — 2026-09-25

`A14_Core_NoOrders_v1_00.mq5`

Summary:

```
ticks=2571204
bars=920
bricks=554
raw=32
entries=32
exits=31
open=1
tp=3
sl=28
time=0
spread_blocks=0
cooldown_blocks=8
builder_failed=0
NO_ORDERS=1
VIRTUAL_NOT_FILL=1
```

First virtual event:
- SELL 4381.77 at 2026-08-17 15:39:21
- SL at executable ASK 4393.81 at 2026-08-17 16:49:06

The reproduction has executed successfully, but **A14 parity is NOT yet marked PASS**.

Next gate: run the original `A_14_GDS_Renko_Momentum_Demo_EA_v0_12.mq5` over the identical common baseline and compare its actual deal lifecycle against the NoOrders decision timeline.

Expected comparison priority:
1. entry signal/deal direction and time,
2. exit trigger/deal time and reason,
3. sequence/count,
4. executable/fill price differences separately.

Do not treat broker/tester fill price differences alone as a logic mismatch.

Only after original-vs-reproduction parity is established:
**monolithic parity PASS -> Entry/Exit split -> split parity PASS -> Core integration -> regression PASS**.
