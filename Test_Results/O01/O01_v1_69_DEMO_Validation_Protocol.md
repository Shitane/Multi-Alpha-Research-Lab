# O01 v1.69 DEMO Validation Protocol

## Purpose

Collect broker evidence for the current v1.69 checkpoint without changing the frozen O01 decision logic.

This protocol does **not** authorize optimization or live-money trading. It is for a DEMO + HEDGING account only.

## Three-way comparison

| Chart | EA / route | Instance | Magic |
|---|---|---:|---:|
| 1 | Original O01 reference | reference | 46102030 |
| 2 | Multi Alpha v1.69 — FULL / O01 | 2 | 46102031 |
| 3 | Multi Alpha v1.69 — SPLIT / O01 + O01 + O01 | 3 | 46102032 |

Use the same symbol/timeframe and equivalent O01 trading parameters. Do not intentionally change the frozen entry/manage/exit settings during the comparison.

## Execution prerequisites

Before counting any broker event as evidence:

1. account is DEMO,
2. account margin mode is HEDGING,
3. Algo Trading is enabled,
4. the symbol is tradeable,
5. market is open,
6. the O01 new-cycle session is active,
7. FULL and SPLIT instances have distinct positive Instance IDs and Magic numbers,
8. startup logs show the expected Instance/Symbol/Magic identity,
9. v1.69 state audit reports PASS for each Multi Alpha instance.

A run outside the valid market/session may be useful as startup evidence but is not entry/grid/exit parity evidence.

## Evidence to retain

Keep the Experts/Journal log covering startup through the completed cycle. For Multi Alpha v1.69, retain lines containing:

- `[MA_RUNTIME169_START]`
- `[MA_EXEC169_INIT]`
- `[MA_EXEC169_STATE_AUDIT]`
- `[MA_EXEC169_LIFECYCLE]`
- `[MA_EXEC169_OPEN_DELTA]`
- `[MA_EXEC169_RESULT]`
- `[MA_EXEC169_OWNERSHIP]`
- `[O01_RUNTIME140_OPEN]`
- `[O01_RUNTIME140_EXIT]`
- `[O01_RUNTIME153_ROUTE_PANEL]`
- `[O01_RUNTIME140_SUMMARY]`

For each broker OPEN/CLOSE event, record:

- timestamp,
- Instance ID,
- Symbol,
- Magic,
- action,
- side,
- requested lot,
- order ticket,
- deal ticket,
- position ticket,
- retcode/description,
- owned-position count,
- lifecycle phase REQUEST / CONFIRMED / REJECTED.

## Gate A — startup / identity

PASS requires:

- FULL instance starts as Instance 2 / Magic 46102031,
- SPLIT instance starts as Instance 3 / Magic 46102032,
- both report DEMO + HEDGING,
- both state audits pass,
- no unexpected ownership is reported.

## Gate B — initial entry ownership

For the first actual Multi Alpha initial entry:

PASS requires:

- REQUEST is followed by CONFIRMED,
- broker retcode is accepted by the adapter,
- the confirmed position is selectable,
- confirmed position Symbol + Magic match the requesting instance,
- side matches the signal,
- owned position count/lots increase,
- the other Multi Alpha instance does not claim/manage that ticket.

A rejected broker request is evidence to diagnose, not a parity PASS.

## Gate C — same-symbol / different-Magic isolation

When FULL and SPLIT have broker positions on the same symbol:

PASS requires each instance's state audit and managed-position queries to include only its own Magic.

Any close/manage action against the other instance's Magic is an immediate FAIL for the isolation gate.

## Gate D — grid lifecycle

When a grid addition occurs:

PASS requires:

- the grid request is attributable to the correct instance,
- requested lot follows the frozen O01 lot progression/settings,
- owned count and owned side lots increase after confirmation,
- position ownership remains Symbol + correct Magic,
- the other instance's positions remain untouched.

## Gate E — exit lifecycle

For single-trailing or basket-trailing close:

PASS requires:

- exit decision is logged,
- only owned Symbol + Magic tickets are submitted for close,
- REQUEST is followed by CONFIRMED for each successfully closed ticket,
- synchronous confirmation no longer finds the closed position ticket,
- unrelated Magic positions remain present/unmodified.

Virtual-SL/emergency evidence is recorded separately when naturally reached; do not force an unsafe market condition merely to trigger it.

## Gate F — route-change protection with real positions

While an instance owns a real broker position/cycle, attempt a route APPLY only as a controlled safety test.

PASS requires:

- route change is rejected,
- active route remains unchanged,
- owned broker position is not modified/closed by the rejected route change.

Do not repeatedly manipulate the route during an active trade.

## Gate G — restart/state observation

Restart/state behavior is a separate evidence gate.

If a controlled restart is performed while an owned DEMO position exists:

- record the broker position before restart,
- record v1.69 startup identity and state audit after restart,
- verify the same Symbol + Magic position is recognized as owned,
- verify no foreign Magic is adopted.

Do not mark this gate PASS without an actual restart-with-position observation.

## Event-level parity comparison

Compare Original O01, FULL/O01, and SPLIT/O01+O01+O01 for:

- initial entry time,
- direction,
- lot,
- grid timing/price/lot,
- exit decision type,
- exit timing,
- completed cycle count.

Broker fills may differ slightly in price/time from execution latency. Record such differences rather than silently treating them as decision-logic differences.

FULL and SPLIT must not be declared broker-parity PASS merely because aggregate trade counts are similar; lifecycle evidence and ownership isolation are required.

## Known DD constraint

Frozen O01 DD uses account-level Balance/Equity behavior. Concurrent strategies on one DEMO account can influence the observed DD state even with correct Magic isolation.

Do not change frozen O01 DD logic for this test. Record DD-related discrepancies separately.

## PASS declaration rule

The overall v1.69 DEMO gate remains **PENDING** until actual open-market/session evidence covers the required lifecycle.

Compile PASS and NO_ORDERS regression PASS are already separate checkpoints and must not be used as substitutes for broker evidence.
