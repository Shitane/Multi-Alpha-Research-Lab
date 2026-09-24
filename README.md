# Multi-Alpha-Research-Lab

MT5 Multi Alpha Research Lab — original-EA reproduction, parity verification, and modular EA research.

## Numbering policy

- **A10-A15**: Original/Reproduction series. Preserve the source/original logic first; verify parity before optimization.
- **A16+**: Research/New Alpha series for new public strategies, original strategies, experiments, and optimization.

## Repository structure

- `Original_EA/A10-A15/` — untouched/reference original EA source code when added.
- `Modules/A10-A15/` — extracted Multi Alpha modules. Verified modules should be treated as frozen references.
- `MultiAlpha_Core/` — common Core and interface.
- `Parity_Tests/A10-A15/` — NoOrders parity/reproduction tests.
- `Parity_Tests/A15/Observer/` — A15 broker lifecycle observation/audit tools.
- `Parity_Tests/Common/` — common interface/compile tests.
- `Research/A16+/` — new Alpha research. A16 currently starts from the empty reusable template.
- `Test_Results/A10-A15/` — completion criteria, parity gates, and other verification records.

## Safety rule

Research and parity code is **NoOrders** unless a separate execution version is explicitly created. Do not add `OrderSend`, `OrderCheck`, or real broker execution to NoOrders research code.

## Current verified baseline

- A12: Multi Alpha adapter parity verified on the defined XAUUSD_DUKA baseline.
- A15: decision/lifecycle reproduction verified for the defined baseline; broker lifecycle was separately observed with the A15 Observer.
- A16: empty template connection to Multi Alpha Core verified; it intentionally produces no entries or exits.

A10, A11, A13, and A14 remain Original/Reproduction work items and should be completed from their original EA code before being treated as verified Alpha modules.
