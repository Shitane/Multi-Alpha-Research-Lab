# Multi Alpha Research Lab — Development Policy v1.00

## 1. Foundation completion standard for A10-A15

A10, A11, A12, A13, A14, and A15 are the foundation/reference set.

Each Alpha is considered foundation-complete only after this sequence is completed and verified:

1. Original EA preservation and source-faithful NoOrders reproduction
2. Combined Entry+Exit module extraction
3. Combined-module parity PASS
4. Entry Module / Exit Module separation
5. Recombined Entry+Exit parity PASS against the verified combined module/original baseline
6. MultiAlpha Core integration
7. Core regression PASS

Existing verified files are frozen references. Do not rewrite a verified combined module merely to create the separated form; add new versioned Entry/Exit modules and parity tests.

Parity must preserve strategy decisions and lifecycle behavior, including signal direction, timing, executable bid/ask where applicable, entry/exit price, exit reason, state transitions, cooldown/hold behavior, and relevant counters.

## 2. Safety

Research, Core, reproduction, and parity code remains NoOrders.

Do not add OrderSend, OrderCheck, CTrade execution, or real broker orders to NoOrders code unless a separate execution version is explicitly approved.

## 3. Two parallel development tracks after/during foundation work

### Track A — Public EA intake

Continue searching for useful public EAs without imposing a fixed count limit.

Candidates are not restricted to XAUUSD. Other FX pairs and instruments may be evaluated, with suitable historical/tick data prepared when required.

Prefer candidates whose source code is available and whose logic can be inspected and reproduced. Intake should preserve the original first, establish NoOrders parity, then modularize before optimization.

A public EA can contribute more than a whole strategy: its Entry, Exit, position-management, recovery, trailing, or risk logic may become independently testable research components.

### Track B — Original strategy research

Develop original logic in parallel with public-EA intake.

The architecture should support composition of:

- Entry Signal Module
- Position Manager
- Exit Module / Exit Manager
- Risk Manager

Research examples include grid/averaging, recovery, trailing, basket TP/SL, lot control, and other management logic.

The framework should also support one initial signal creating multiple virtual positions, with different exit logic assigned to each position. Example: five simultaneous initial positions with fixed TP/SL, trailing, signal exit, time exit, and runner exit.

These are new research strategies and must not overwrite or be mislabeled as the original A10-A15 strategies.

## 4. Composition research

After components are verified independently, combinations may be tested, for example:

- A12 Entry + A15 Exit
- A13 Entry + original trailing
- Public-EA Entry + original Recovery
- One Entry + multiple independent Exit modules

Every new composition gets its own identity/version and regression record. A successful combination does not change the frozen parity status of its source modules.

## 5. Immediate order of work

Complete the A10-A15 foundation in this order:

A10 -> A11 -> A12 -> A13 -> A14 -> A15

For each, fill only the missing stages in the foundation completion standard and preserve already-verified reference code.

A14 still requires source-faithful reproduction before later stages.

Only actual compile/backtest/parity evidence may be recorded as PASS.
