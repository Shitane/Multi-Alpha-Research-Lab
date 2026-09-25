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
