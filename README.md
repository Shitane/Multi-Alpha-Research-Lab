# Multi-Alpha-Research-Lab

MT5 Multi Alpha Research Lab — original-EA reproduction, parity verification, and modular EA research.

## Numbering policy

- **A10-A15**: Original/Reproduction series. Preserve source/original logic first; verify parity before optimization.
- **A16+**: Research/New Alpha series for new public strategies, original strategies, experiments, and optimization.

## Safety rule

Research, Core, and parity code is **NoOrders** unless a separate execution version is explicitly created. Never add `OrderSend`, `OrderCheck`, `CTrade` execution, or other real broker orders to NoOrders code without explicit approval.

## Common regression baseline

Unless a test record says otherwise:
- Symbol: XAUUSD_DUKA
- Timeframe: M15
- Period: 2026-08-16 through 2026-08-29
- Tick model: real ticks
- Initial deposit: JPY 100000
- Core: `MultiAlpha_Core_NoOrders_v1_02.mq5`

## Current status — 2026-09-24

### A10 — VERIFIED / Core integrated
Original Bollinger 4-mode EA reproduced. NoOrders baseline, module parity, and MultiAlpha Core integration passed.
Core v1.02 baseline: ticks=2571204, entries=6, exits=4, open=2.
Verified A10 code should now be treated as a frozen reference.

### A11 — NOORDERS REPRODUCTION VERIFIED / module extraction next
Original: `Original_EA/A11/A_11_MACross_MT5_v107.mq5`.
Default logic: EMA100/EMA200 on PERIOD_CURRENT; new-bar evaluation; closed bars [1]/[2]; MTF filter OFF; TP=0; SL=0; Fast-MA exit OFF; Magic=889.
Original common-baseline lifecycle:
- 2026-08-17 04:30 BUY 4407.72
- 2026-08-18 20:45 close BUY 4358.38, then SELL 4358.38
- 2026-08-19 18:00 close SELL 4488.41, then BUY 4488.41
- 2026-08-26 20:30 close BUY 4597.53, then SELL 4597.53
- Final SELL remains logically open; tester closes it only at end of test.
NoOrders v1.00 exactly matched timestamps, directions, executable bid/ask prices, and reversal ordering.
Summary: ticks=2571204, newbars=920, raw=4, entries=4, exits=3, open=1.
Next step: extract A11 module, run standalone-vs-module parity, then integrate A11 into MultiAlpha Core.

### A12 — VERIFIED / Core integrated
Known baseline: ticks=2571204, bricks=80, raw=9, entries=5, exits=4, blocks=4, open=1.
Regression on Core v1.02 passed.

### A13 — ORIGINAL / reproduction pending
Original source is preserved. Source-faithful reproduction/parity work remains.

### A14 — ORIGINAL / reproduction pending
Original source is preserved. Source-faithful reproduction/parity work remains.

### A15 — VERIFIED / Core integrated
Known baseline: ticks=2571204, bricks=100, raw=23, entries=3, exits=3, blocks=0, spread_blocks=0, open=0, cooldown=5.
Regression on Core v1.02 passed. Broker lifecycle was separately observed with the A15 Observer.

### A16 — EMPTY RESEARCH TEMPLATE / Core connection verified
Core v1.02 regression: ticks=2571204, bricks=0, raw=0, entries=0, exits=0, blocks=0, open=0, cooldown=0.
A16 is intentionally empty and reserved for Research/New Alpha work.

## Core v1.02 regression status

A10 PASS -> A12 PASS -> A15 PASS -> A16 PASS.
Do not claim A11 Core integration until its module/parity/integration tests are actually run.

## Repository structure

- `Original_EA/A10-A15/` — untouched/reference original EA source.
- `Modules/A10-A15/` — extracted modules; verified modules are frozen references.
- `MultiAlpha_Core/` — common Core and interface.
- `Parity_Tests/A10-A15/` — NoOrders reproduction/parity tests.
- `Parity_Tests/A15/Observer/` — A15 broker lifecycle observer.
- `Parity_Tests/Common/` — common tests.
- `Research/A16+/` — new Alpha research.
- `Test_Results/A10-A15/` — baseline/parity/completion records.

## Key A11 records

- `Test_Results/A11/A11_Reproduction_Plan_v1_00.md`
- `Parity_Tests/A11/A11_Core_NoOrders_v1_00.mq5`
- `Test_Results/A11/A11_NoOrders_Parity_v1_00.csv`

## Resume instructions for a new ChatGPT chat

Tell ChatGPT:

> Continue development of GitHub repository Shitane/Multi-Alpha-Research-Lab. Read README.md first and inspect the relevant current files and Test_Results before changing code. Preserve the NoOrders safety rule. Continue from the “Next step” documented in README and do not assume an untested step has passed.

GitHub is the durable source of truth for development state. MT5 local files may be newer only when a compile/backtest has just been performed and has not yet been committed; reconcile that before editing.
