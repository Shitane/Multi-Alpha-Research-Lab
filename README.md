# Multi-Alpha-Research-Lab

MT5 Multi Alpha Research Lab — original-EA reproduction, parity verification, modular EA research, and future MQL5 product development.

## Numbering policy

- **A10-A15**: Original/Reproduction series. Preserve source/original logic first; verify parity before optimization.
- **A16+**: Research/New Alpha series for new public strategies and experiments.
- **O01+**: Original Logic series for proprietary/original strategies. Keep this numbering separate from A16+ research logic.
  - O01: Gold Session Guard v4 Experimental 03 RSI30 logic reproduction/parity project.

## Safety rule

Research, Core, and parity code is **NoOrders** unless a separate execution/demo version is explicitly created. Never add `OrderSend`, `OrderCheck`, `CTrade` execution, or other real broker orders to NoOrders code without explicit approval.

Execution/demo hosts must be clearly separated from NoOrders research hosts.

## Reproduction / completion pipeline

For reproduction-series logic, use this order:

**Original reproduction -> monolithic parity PASS -> Entry/Exit split -> split parity PASS -> Core integration -> regression PASS**

Do not optimize a reproduction module before parity is established. Verified modules become frozen references; optimization and experiments should use new versions/variants.

## Common regression baseline

Unless a test record says otherwise:
- Symbol: XAUUSD_DUKA
- Timeframe: M15
- Period: 2026-08-16 through 2026-08-29
- Tick model: real ticks
- Initial deposit: JPY 100000
- Leverage: 1:100
- Reference tick/bar count: 2,571,204 ticks / 920 bars
- Current integration line: `MultiAlpha_Core_NoOrders_v1_08.mq5`

## Product architecture policy — IMPORTANT

The long-term target is an MQL5 Market product containing many entry/exit strategies without making the user's setup screen unmanageably complex.

### 1. Internal modularity, simple customer package

Development source should remain modular:
- Core/host
- A-series modules
- O-series modules
- common risk/news/session/lifecycle components

However, the final MQL5 customer product should preferably compile these internal `.mqh` modules into the distributed EA so the customer does **not** have to manually install, match, or maintain many module files.

Goal: internally modular, externally simple.

Avoid a product design where users can easily cause errors by:
- forgetting an Include/module file,
- placing a module in the wrong folder,
- mixing incompatible module versions,
- renaming/deleting required files.

### 2. Simple mode and flexible mode must coexist

The product must support both:
- easy operation for users who want verified defaults, and
- detailed customization for advanced users.

Preferred concept: **Preset + Advanced/Custom**.

Example operating modes:
- STANDARD
- CONSERVATIVE
- AGGRESSIVE
- CUSTOM

STANDARD/etc. load validated module parameters. CUSTOM allows detailed changes.

Do not expose every parameter of every strategy as an enormous flat input list if it can be avoided.

### 3. Strategy enable/disable should stay simple

The normal operating surface should make it easy to enable/disable strategies, for example:
- A10 Bollinger ON/OFF
- A11 MA Cross ON/OFF
- A12 Renko ADX ON/OFF
- A13 Renko Dual MA ON/OFF
- O01 GSG RSI30 ON/OFF
- future modules likewise

Detailed strategy parameters belong behind Advanced/Custom behavior or another clean configuration layer.

### 4. Research host and product host share the same strategy modules

Do **not** maintain separate duplicated trading logic for research and product versions.

Preferred architecture:

```
                 Same verified module
                        |
              +---------+---------+
              |                   |
       Research/Test Host     Product Host
       full diagnostics       simple UI/presets
       optimization inputs    advanced/custom access
       parity/regression      demo/live execution
```

This reduces the risk that the tested logic and the sold logic silently diverge.

### 5. Factory defaults and recovery

Each strategy should have validated factory/default parameters. The product should make it easy to return to those known settings.

Preferred concepts:
- Factory Default
- validated presets
- User Preset
- Restore Default
- input validation before trading

Invalid combinations should fail safely with a clear message rather than silently trade with unintended settings.

### 6. UI direction

Because MQL5 `input` parameters are not ideal for dynamically hiding/showing large groups, the final product may use a chart panel for higher-level configuration.

Normal users should see only the controls needed for operation (strategy ON/OFF, profile/risk, session, news filter, safety settings). Advanced users can open detailed settings.

The panel is a product/UI layer; it must not change the verified strategy logic itself.

### 7. Module independence and lifecycle ownership

Strategy modules should expose decisions/state through stable interfaces. The host/Core should own shared lifecycle and execution responsibilities where practical.

NoOrders modules must remain free of broker execution.

When multiple strategies are combined, define explicitly:
- strategy identity,
- Magic/comment/order ownership,
- position ownership,
- shared vs per-strategy risk controls,
- session/news behavior,
- exit ownership,
- state persistence/versioning.

This is necessary so one strategy does not accidentally manage another strategy's positions.

### 8. Many small-risk alphas, not lot-size maximization

The long-term objective is to combine many strong entry logics at controlled/small risk and seek aggregate performance through diversification and strategy quality, rather than simply increasing lot size.

The architecture should therefore support multiple strategies and, later, multiple exit/recovery treatments for a signal without coupling every strategy into one monolithic block.

### 9. Panel strategy composition, presets, backtest, and optimization

The final product should allow users to compose strategies from **verified modules** through the chart panel without source-code edits.

Target layers:

```
ENTRY: A10 / A11 / A12 / A13 / O01 / ...
  -> MANAGEMENT: Single / Grid / Recovery / Multiple positions / ...
  -> EXIT: Original / Fixed TP-SL / Trailing / Basket / Time / MA / ...
  -> RISK & SAFETY: Lot / DD / News / Session / Emergency / ...
```

The panel should support Entry/Management/Exit selection per strategy slot. Not every combination is valid: modules should expose ID/version/type, required state/data, compatible position modes, and compatibility information. The UI/Core should hide or reject incompatible combinations. Only parity-verified/frozen modules belong in the normal product selection list; experimental modules must remain clearly separated.

The panel should save/load the complete configuration as a named **Strategy Preset**, including module selections, enabled slots, detailed parameters, lot/risk, session/time, news, DD/safety, and relevant product settings. Provide SAVE, SAVE AS, LOAD, User Preset, Factory Default, and Restore Default. Presets should contain format/module version information so obsolete/incompatible settings can be detected after updates.

Edits should not silently change active trading. Prefer an explicit **APPLY** step with validation. Lifecycle-sensitive changes such as Grid/Recovery/Exit settings may be queued for the next cycle instead of modifying an open cycle.

### 10. Exact panel configuration must be backtestable

Target workflow:

```
Panel configuration
   -> SAVE PRESET
   -> Backtest same configuration
   -> Demo Forward same configuration
   -> Live same configuration
```

Do not manually recreate settings at every stage. The tester/research host must use the **same verified Entry/Management/Exit modules** as demo/live; never maintain a separate backtest reimplementation of trading logic.

### 11. PRESET mode and TESTER_INPUTS mode

Backtesting and optimization need different configuration paths:

- **PRESET**: reproduce an exact saved panel strategy for backtest/parity/demo/live.
- **TESTER_INPUTS**: expose selected research parameters to MT5 Strategy Tester for parameter sweeps/optimization.

```
             Strategy Configuration
                      |
          +-----------+-----------+
          |                       |
        PRESET               TESTER_INPUTS
          |                       |
 exact saved strategy       optimization ranges
          |                       |
          +-----------+-----------+
                      |
               Same Modules/Core
```

Do not expose every optimization parameter in the normal customer input screen merely because research needs it. Research flexibility and customer-facing simplicity are separate concerns.

Promising optimization results should be converted into a versioned preset and then validated by normal backtest/parity/forward testing before becoming a Factory/validated preset.

### 12. One verified logic path and reproducibility

The architecture must prevent divergence between what was backtested, optimized, demo-forward-tested, and run live. A saved/tested configuration should identify both the selected module combination and exact parameter/module versions so results can be reproduced later.

Before APPLY/load/test/live execution, validate module registration/version compatibility, Entry/Exit/Management compatibility, parameter ranges, position ownership/Magic mapping, and required symbol/timeframe/data conditions where applicable. On validation failure, fail safely: show a clear reason, do not silently substitute another strategy, and keep the invalid configuration from trading.

## Current development status — 2026-09-25

### A10
Entry/Exit split and Core integration completed. Frozen verified reference.

### A11
Entry/Exit split and Core integration completed. Frozen verified reference.

### A12
Entry/Exit split completed and Core integration regression passed on the current line.

### A13
Original reproduction, monolithic parity, Entry/Exit split, split parity, and Core v1.08 integration parity have passed.

Known common-baseline Core summary:
`selected_alpha=13 ticks=2571204 bricks=554 raw=4 entries=4 exits=3 blocks=10 spread_blocks=0 open=1 cooldown=0 failed=0 reason=1 NO_ORDERS=1 VIRTUAL_NOT_FILL=1`

### A14
Original source preserved. Full reproduction pipeline remains the next A-series development work.

### A15
Existing reproduction/integration baseline is available. Continue/confirm under the agreed completion pipeline after A14 as planned.

### A16
Empty Research/New Alpha template. Keep separate from the O-series proprietary/original logic.

### O01 — GSG RSI30
A separate **Original Logic** line has been started for the logic of `Gold_Session_Guard_v4_Experimental_03_RSI30`.

Current immediate objective: reproduce the original behavior as a monolithic O01 module and compare it against the original EA in demo operation before later splitting/refactoring.

A demo parity host has been compiled successfully:
- `O01_GSG_RSI30_Parity_Demo_v1_00`
- monolithic module: `O01_GSG_RSI30_Monolithic_Module_v1_00.mqh`

On 2026-09-25, original EA and O01 were prepared for simultaneous demo operation on the same account with different Magic numbers:
- original: 46102030
- O01: 46102031

All other compared settings are intended to remain equal. Same-account comparison has one known limitation: account-level Balance/Equity DD measurements can be influenced by both EAs, even when position ownership is separated by Magic. Therefore DD 8%/12%/15% behavior needs special care when interpreting same-account parity.

## Planned sequence

Immediate:
1. Continue O01 live/demo parity observation while the market is open.
2. Record discrepancies, if any, in entry timing/direction/lot, grid additions, trailing/exit behavior, session state, and news filter behavior.
3. Do not optimize O01 until reproduction parity is established.

After this temporary Friday demo test:
4. Resume the planned A-series work: **A14 -> A15**.
5. Preserve the product architecture policy in this README while modules are added.

## Repository structure direction

- `Original_EA/A10-A15/` — original/reference EA source.
- `Modules/A10-A15/` — extracted verified modules.
- `MultiAlpha_Core/` — common NoOrders research Core/interface.
- `Parity_Tests/A10-A15/` — reproduction/parity tests.
- `Research/A16+/` — Research/New Alpha series.
- `Original_Logic/O01+/` or equivalent dedicated O-series area — proprietary/original logic. Keep separate from A16+.
- `Test_Results/` — baseline/parity/regression/completion records.

## Resume instructions for a new ChatGPT chat

Tell ChatGPT:

> Continue development of GitHub repository Shitane/Multi-Alpha-Research-Lab. Read README.md first and inspect the relevant current files and Test_Results before changing code. Preserve the NoOrders safety rule, the A-series/O-series separation, the reproduction pipeline, and the Product Architecture Policy. Do not assume an untested step has passed.

GitHub is the durable source of truth for development state. MT5 local files may be newer only when a compile/backtest/demo test has just been performed and has not yet been committed; reconcile that before editing.
