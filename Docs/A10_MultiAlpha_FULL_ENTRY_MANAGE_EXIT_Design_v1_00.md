# A10 Multi Alpha Responsibility Design v1.00

## Purpose

Define the source-faithful A10 architecture for the single Multi Alpha EA before changing the current v1.73 runtime host.

Target capability shape:

- FULL / A10
- ENTRY / A10
- MANAGE / A10
- EXIT / A10

FULL is an independent whole-strategy reference path. SPLIT is ENTRY + MANAGE + EXIT. FULL must not merely call the SPLIT dispatcher and be renamed FULL.

## Source of truth

Original reference:
- Original_EA/A10/A_10_GDS_Renko_Bollinger_4Mode_Demo.mq5

Already verified extracted assets:
- Modules/A10/A10_Bollinger_Module_v1_00.mqh
- Modules/A10/A10_Entry_Module_v1_00.mqh
- Modules/A10/A10_Exit_Module_v1_00.mqh

Existing exact-parity evidence:
- Test_Results/A10/A10_Completion_Criteria_v1_00.csv
- Test_Results/A10/A10_Entry_Exit_Parity_v1_00.csv
- Test_Results/A10/A10_MultiAlpha_Core_Parity_v1_01.csv

Frozen common A10 baseline:
- ticks 2,571,204
- entries 6
- exits 4
- open at end 2
- Breakout entries/exits 4/3
- Re-entry entries/exits 0/0
- Midline entries/exits 1/1
- Squeeze entries/exits 1/0
- NO_ORDERS=1
- VIRTUAL_NOT_FILL=1

## Responsibility map

### FULL / A10

FULL is the independent whole A10 reproduction.

It owns the complete original A10 sequencing:
1. resolve prior execution state,
2. pending exit first,
3. price exits,
4. pending exit retry,
5. update all four Renko/Bollinger engines,
6. owner-signal exits,
7. same-tick conflict handling,
8. deterministic entry queue,
9. pending entry processing,
10. final pending-exit / pending-entry processing.

FULL is the parity/reference route for SPLIT A10.

### ENTRY / A10

ENTRY owns signal generation only:

- four independent Renko streams,
- Bollinger state,
- Breakout signal,
- Re-entry signal,
- Midline Cross signal,
- Squeeze Breakout signal,
- entry-run qualification,
- newest completed-brick final signal,
- raw signal / BB midpoint context required by downstream decisions.

ENTRY must not:
- place broker orders,
- close broker positions,
- enforce global max-position allocation,
- own the cross-mode pending-entry queue,
- decide broker execution retry state.

Existing A10_Entry_Module_v1_00.mqh is the starting verified implementation. Its current per-engine cooldown state is retained until the SPLIT parity refactor explicitly moves lifecycle ownership; do not delete or alter it silently.

### MANAGE / A10

MANAGE is a real A10 responsibility, not an invented trading strategy.

It is extracted from original orchestration/lifecycle behavior:

- mode ownership identity (Breakout / Re-entry / Midline / Squeeze),
- maximum simultaneous A10 positions,
- hedging/netting effective position limit behavior,
- same-tick opposite-signal conflict filter,
- deterministic queue priority: Breakout -> Re-entry -> Midline -> Squeeze,
- pending-entry direction/time state,
- pending-entry TTL,
- one trade request per tick sequencing,
- block new entry while an exit is pending,
- per-mode one-position rule,
- cross-mode free-slot allocation,
- spread/trade-mode eligibility coordination before execution,
- cooldown lifecycle start after confirmed exit,
- cooldown eligibility used before accepting a new entry,
- execution-pending / transition state needed to prevent duplicate requests.

MANAGE does not create a new averaging/grid rule. A10 original has no O01-style grid manager, so no grid behavior is to be invented.

### EXIT / A10

EXIT owns exit decisions only:

Price/time:
- TP,
- SL,
- TIME.

Completed-brick/signal:
- Re-entry BB_MID,
- BB_OPPOSITE for the applicable modes.

EXIT produces an exit decision/reason for an owned A10 mode position. Broker closing remains the common Multi Alpha execution adapter responsibility.

Existing A10_Exit_Module_v1_00.mqh is the starting verified implementation.

## State handoff contract

ENTRY -> MANAGE:
- per-mode final signal,
- raw signal,
- completed brick count,
- BB ready/mid context,
- effective brick,
- mode enabled/eligibility context.

MANAGE -> execution adapter:
- accepted entry request with owner mode, direction and requested lot,
- no broker operation from the module itself.

Execution adapter -> MANAGE:
- confirmed/rejected transition,
- owned position snapshot by Symbol + Multi Alpha Magic plus A10 owner-mode metadata.

Position snapshot + ENTRY context -> EXIT:
- owner mode,
- direction,
- entry price/time,
- executable bid/ask,
- completed-brick raw signal and BB context.

EXIT -> MANAGE/execution adapter:
- exit request + reason.

Confirmed exit -> MANAGE:
- clear owned lifecycle,
- start the correct mode cooldown.

## Magic / owner-mode rule

The original A10 uses BaseMagic+1..+4 to identify its four internal modes.

The single Multi Alpha EA uses one instance Magic as its external ownership boundary. Therefore A10 internal mode identity must be represented as module state/metadata inside the A10 route and must not escape the common Symbol+Magic ownership safety boundary by creating four unrelated Multi Alpha instances.

Any implementation that loses the four-mode owner identity is not source-faithful.

## Parity gates before Registry registration

A10 must not be marked FULL/ENTRY/MANAGE/EXIT REGISTERED merely because files exist.

Required order:

1. implement A10 MANAGE contract without broker orders,
2. build independent FULL/A10 adapter from the verified whole-path reproduction,
3. build SPLIT A10 route using ENTRY + MANAGE + EXIT,
4. run frozen XAUUSD_DUKA M15 2026-08-16..2026-08-29 real-tick NO_ORDERS test,
5. require exact aggregate parity with the frozen A10 baseline,
6. require event-level parity for the documented ten entry/exit events,
7. verify queue/conflict/cooldown behavior,
8. negative-test unsupported/mismatched routes for fail-safe rejection,
9. only then register A10 capabilities in the current Multi Alpha registry,
10. DEMO broker execution comes after NO_ORDERS parity and uses the common execution adapter.

## Non-goals

- no A10 optimization,
- no new grid/martingale behavior,
- no silent reuse of O01 MANAGE,
- no change to O01 frozen logic,
- no declaration of compile/parity PASS until MetaEditor/tester evidence exists.

## Reuse for A11-A15

After A10 FULL and SPLIT reach exact parity, use this four-capability boundary as the architectural template for A11-A15, but derive each MANAGE responsibility from that EA's own original lifecycle. Do not assume A10 management rules apply to another Alpha.
