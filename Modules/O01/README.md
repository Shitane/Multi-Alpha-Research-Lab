# O01 — Gold Session Guard v4 Experimental 03 RSI30

O01 follows the A-series discipline but remains in the Original Logic series.

## Frozen source / parity basis
The existing source-faithful monolithic module remains the whole-strategy reference. The thin full-reproduction compatibility module delegates to it without intentionally changing strategy logic.

## Split modules
- O01_GSG_RSI30_Entry_Module_v1_00.mqh — initial-entry decision only; no orders.
- O01_GSG_RSI30_Exit_Module_v1_00.mqh — virtual SL/fixed TP/trailing decision and trail state only; no orders.
- O01_Runtime_Settings_v1_00.mqh — runtime settings transport and FILE_COMMON save/load.
- O01_Settings_Panel_v1_00.mqh — first editable panel prototype (APPLY/SAVE/LOAD).
- O01_GSG_RSI30_Module_Lab_NoOrders_v1_00.mq5 — safe development host; NO_ORDERS=1.

## Safety / parity rule
The A-series-style research/parity path is NoOrders. The previously validated O01 demo-execution parity host is a separate demo-only experiment and must not be merged into the NoOrders lab.

## Development gate
v1.00 establishes the module boundaries and settings transport. It does **not** yet claim split-module parity. Next gate: wire market/session/news/grid context into Entry and Exit modules, emit decision logs, compare against the frozen monolithic reference, then expand the panel to all strategy settings. Runtime panel values must not silently change the frozen monolithic reference during parity testing.

## Split parity baseline — v1.05

The 2026-08-16..2026-08-29 XAUUSD_DUKA M15 real-tick run is frozen as the O01 split regression baseline: 2,571,204 ticks; entries 31; grid additions 5; closes 31; single trailing 27; basket trailing 4; virtual SL 0; no open BUY/SELL at end. The tester completed successfully with NO_ORDERS=1 and VIRTUAL_NOT_FILL=1.

This baseline is the gate for subsequent O01 Core integration. Any Core adapter change must preserve these lifecycle counts and event timing before O01 can be marked Core-complete.

## Core adapter

- O01_GSG_RSI30_Core_Interface_v1_00.mqh — stable decision-only Entry/Exit adapter for Multi Alpha Core; NO ORDERS.

## Core integration parity — v1.00 PASS

The O01 Core Interface v1.00 regression passed against the frozen SPLIT105 baseline on XAUUSD_DUKA M15, 2026-08-16..2026-08-29, real ticks. Result: 2,571,204 ticks; entries 31; grid additions 5; closes 31; single trailing 27; basket trailing 4; virtual SL 0; final BUY/SELL open 0/0. Safety remained NO_ORDERS=1 and VIRTUAL_NOT_FILL=1.

This freezes O01_GSG_RSI30_Core_Interface_v1_00.mqh as the current Core integration baseline. Future O01/Core changes must regress against this result before acceptance.

## Settings panel development — v1.10

Added expanded runtime settings transport and a NoOrders panel lab. The panel now exposes the main RSI, lot/grid, trailing, DD 8/12/15 and session fields with APPLY/SAVE/LOAD/REFRESH. Settings are stored separately as O01_GSG_RSI30_Settings_v1_10.csv in FILE_COMMON. This is a development surface only: it does not modify the frozen Core v1.00 parity baseline and it contains no broker order functions.


## Runtime settings contract — v1.42 / v1.40

The O01 runtime settings flow is fixed as follows so that Expert Properties, the chart panel, and named presets are not confused.

**Expert Properties -> startup snapshot -> panel -> runtime**

- **Expert Properties** are the startup/default source. On OnInit(), the O01 Inp* values are copied into runtime_cfg, and the exact resulting configuration is captured as the startup snapshot used by REFRESH. Runtime panel actions do not rewrite MT5 input variables.
- **APPLY** reads the current panel fields, validates them, and applies them to the current runtime only. RSI/ATR handle-dependent changes are rebuilt by the host when required.
- **SAVE** saves the complete current panel configuration as a **named O01 preset**. This is separate from MT5's standard .set Save/Load buttons in Expert Properties.
- **NEXT** cycles through the saved named O01 presets.
- **LOAD** loads the currently selected named O01 preset into the panel/runtime.
- **DELETE** deletes the currently selected named O01 preset with one click and refreshes the preset list.
- **REFRESH** restores the **startup snapshot captured from Expert Properties**, not a saved named preset. This behavior was verified with Expert Properties RSI Lower/Upper values restored to the panel after runtime edits.
- Named O01 presets are stored under the MT5 shared FILE_COMMON area at Common\Files\MultiAlpha\O01\Presets\<preset-name>.csv, allowing another chart or another MT5 terminal on the same Windows installation to use the same preset files. Moving presets to another PC requires copying these CSV files.

The runtime panel remains a **NO ORDERS / VIRTUAL NOT FILL** research host. These settings/preset/UI changes do not authorize or add broker order execution.

### Confirmed UI/settings behavior

The current panel path has been manually checked for named SAVE, NEXT selection, LOAD, one-click DELETE, numeric field editing, and REFRESH-to-Expert-Properties startup values. The Safety/DD display uses the 8% Warning, 12% Grid Pause, and 15% Emergency fields. Panel/layout work must not change the frozen O01 trading/parity logic.
