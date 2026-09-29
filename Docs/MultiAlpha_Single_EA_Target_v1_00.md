# Multi Alpha Single-EA Target v1.00

## Fixed product direction

The production target is ONE Multi Alpha EA, not separate FULL and SPLIT products.

One EA instance exposes one route selector:

- Structure = FULL
  - select one registered whole-strategy module.
- Structure = SPLIT
  - select one registered Entry module.
  - select one registered Manage module.
  - select one registered Exit module.

The same compiled EA can be attached to multiple charts on one DEMO account. Each instance receives a unique Magic and route configuration, so the comparison can run concurrently without creating different EA products.

Example three-chart forward test:

| Chart | Same EA binary | Route | Magic |
|---|---|---|---:|
| 1 | Original benchmark remains external reference during migration | Original O01 | 46102030 |
| 2 | Multi Alpha EA | FULL / O01 | 46102031 |
| 3 | Multi Alpha EA | SPLIT / O01 + O01 + O01 | 46102032 |

After migration, FULL and SPLIT are modes of the same Multi Alpha EA. The temporary FULL-only demo host is a diagnostic scaffold only and is NOT the product architecture.

## Two-panel UI contract

Right panel = route/composition selector.
Left panel = settings for the modules selected in the right-panel draft.

FULL draft:
- left panel shows the registered FULL module settings context.

SPLIT draft:
- Entry section shows selected Entry module settings.
- Manage section shows selected Manage module settings.
- Exit section shows selected Exit module settings.
- Safety/DD remains cross-cutting/common unless a later verified contract explicitly changes it.

Changing the right-panel draft may change what the left panel displays, but it MUST NOT change the active trading route. Active route changes only after APPLY passes validation and the flat/idle/transition safety gate.

An unregistered module displays NOT REGISTERED and MUST NEVER fall back to O01 settings or O01 logic as if it were registered.

## Per-module operating filters

Trading time and news handling are configurable characteristics of each selected logic module. They MUST NOT be permanently predetermined for A10-A15, and they MUST NOT be forced into one common schedule/news policy for all Alpha modules.

Each registered ENTRY, MANAGE, or EXIT module may expose user-selectable operating-filter settings when that capability uses them. The settings contract should allow, at minimum:

- Trading Time Filter: ON / OFF
- TimeMode: selectable
- Start Time: user-selectable start time
- End Time: user-selectable end time
- News Filter: ON / OFF
- selectable news impact levels when supported
- configurable stop time before news
- configurable resume time after news

The operating time window MUST be editable by the user for each applicable module. Start Time and End Time are independent selectable settings; they MUST NOT be hard-coded into the module. For example, a user may configure one module for 10:00-14:00 and another for 15:00-18:00, or turn the Trading Time Filter OFF.

These values are settings, not hard-coded identities of A10, A11, A12, A13, A14, or A15. The user must be able to choose them freely for the selected module and preserve different configurations between modules.

In SPLIT mode, filters belong to the selected responsibility independently. Example:

- E=A10 may use its own Entry time/news settings.
- M=A12 may use different Manage time/news settings.
- X=A14 may use different Exit time/news settings, or leave either filter OFF.

Changing E/M/X must load/display that selected module's own configurable settings rather than silently inheriting another module's filter values.

A module may declare a filter unsupported when it is genuinely not applicable, but registration MUST NOT silently substitute O01 or a global default as module-specific behavior.

Cross-cutting account protection such as DD warning, grid-pause safety, and emergency-close safety remains a common Safety layer unless a later verified contract explicitly changes it. Common Safety must not be disabled by a module's time/news filter.


### Special Risk / Event-Day Filter

In addition to the normal News Filter (which can stop operation for a configurable number of minutes before/after an announcement), each applicable logic module may expose a separate user-configurable **Special Risk / Event-Day Filter** for high-risk days.

This filter MUST be optional and configurable; it MUST NOT hard-code one permanent stop policy into A10-A15.

Initial selectable controls should include:

- Special Risk Filter: ON / OFF
- FOMC Day Stop: ON / OFF
  - stop the applicable logic for the entire FOMC trading day
  - optional Before: 0 / 1 day
  - optional After: 0 / 1 day
- Month End Stop: ON / OFF
  - selectable last 1 / 2 / 3 trading days
- Month Start Stop: ON / OFF
  - selectable first 1 / 2 / 3 trading days
- Custom Stop Dates: ON / OFF
  - user-selectable dates

The design should be extensible so additional event-day categories such as CPI, employment reports, ECB, BOJ, or other strategy-relevant events can be registered later without changing the basic module contract.

Month-end/month-start logic should be based on **trading days**, not merely calendar day numbers, so weekends/non-trading days do not produce an unintended schedule.

For grid / averaging / recovery-style logic, an event-day stop must distinguish actions instead of blindly disabling all management. The configurable policy should support:

- block new cycle / initial entry
- block new grid or averaging additions
- continue management of already-open positions where the selected module requires it
- keep Exit processing available
- keep SL / trailing processing available
- keep Emergency / common Safety protection active

A Special Risk filter is a module setting, just like Trading Time and the normal News Filter. Different selected E/M/X modules may therefore use different Special Risk settings, including OFF. The common Safety layer remains independent and cannot be disabled by these filters.

## Multi-logic / multi-symbol target

The long-term production architecture MUST support up to **50 independently configurable Logic Slots** inside the same Multi Alpha EA. This is a fixed product direction so later development must not drift back to a single-symbol or one-logic-per-EA design.

A Logic Slot is an independent runtime identity, for example:

- #01 = selected logic/route + XAUUSD
- #02 = selected logic/route + EURUSD
- #03 = selected logic/route + USDJPY
- ...
- #50 = selected logic/route + user-selected symbol

The symbol is a setting of the slot, not a hard-coded property of A10-A15 or any future Alpha. Multiple slots may use the same logical symbol with different routes/settings, and the same logic may be used on different symbols when its module contract permits it.

Each slot must keep its own runtime identity and settings, including at least:

- Slot ID (#01-#50)
- selected FULL route or SPLIT E/M/X composition
- logical/base symbol
- broker-resolved symbol
- Magic / ownership identity
- module settings
- Trading Time settings
- normal News Filter settings
- Special Risk / Event-Day Filter settings
- runtime/state data needed to prevent one slot from managing another slot's positions

The host must evolve toward **multi-symbol operation**. A slot must use its assigned symbol explicitly and must not silently depend on the chart symbol (_Symbol) as its trading identity. Attaching the Multi Alpha EA to one chart must not mean all 50 slots are forced to trade that chart's symbol.

### Broker Symbol Mapping

Trading logic MUST use canonical/logical symbol names separately from broker-specific symbol names.

Examples:

- XAUUSD -> XAUUSD-m
- XAUUSD -> GOLD
- XAUUSD -> XAUUSD.a
- EURUSD -> EURUSD-m

Broker-specific suffixes, prefixes, or aliases MUST NOT be hard-coded throughout Alpha logic. They must be resolved through a configurable **Symbol Mapping / Broker Symbol Registry**.

The registry must allow the user to pre-register mappings for a broker/account environment. A canonical symbol such as XAUUSD can therefore remain the research/logic identity while the execution layer resolves the actual broker symbol such as XAUUSD-m.

A mapping must be validated before a slot is armed. If the configured broker symbol does not exist or cannot be selected/used, the slot must show an explicit configuration/error state and MUST NOT silently fall back to _Symbol or another instrument.

Automatic suffix/prefix detection may be added later as an optional convenience, but explicit registered mapping remains the authoritative fail-safe mechanism.

### Isolation rule for 50-slot operation

Every broker position/order action must be attributable to the intended slot. Symbol alone is not sufficient because several slots may trade the same instrument. Ownership must therefore include the slot/instance identity and Magic strategy used by the execution contract.

One slot MUST NOT count, add to, close, trail, or otherwise manage another slot's positions merely because both trade XAUUSD or another common symbol.

The existing frozen O01 parity path may remain single-symbol while migration is in progress. This target architecture does not authorize changing frozen O01 logic merely to accelerate the 50-slot migration; migration must be staged and regression-tested.

## Configuration and preset architecture

To prevent Expert Properties / Inputs from becoming unmanageably large as the registry grows toward 50 Logic Slots and many Alpha modules, Multi Alpha MUST use a **minimal Expert Inputs + panel-first configuration** architecture.

### Minimal Expert Inputs

Expert Properties must contain only settings required to bootstrap the EA and configuration system. Module-specific strategy parameters MUST NOT be added to Expert Inputs merely because a new Alpha is registered.

Bootstrap inputs may include, where required:

- Instance identity / base Magic configuration
- configuration/preset storage root
- startup preset / startup load behavior
- essential host/demo/safety bootstrap controls

Detailed FULL, ENTRY, MANAGE, EXIT, Trading Time, News Filter, Special Risk Filter, symbol, and slot configuration belongs in the Multi Alpha panel and its configuration files.

Adding A10, A11, ... or future modules should therefore not cause Expert Properties to grow by dozens of module-specific inputs.

### Panel-first detailed configuration

The panel is the primary editor for detailed runtime configuration.

For each Logic Slot (#01-#50), the panel must be able to edit and display the settings applicable to that slot, including its route/modules, symbol mapping, module parameters, operating time, normal news filters, Special Risk filters, and other registered module settings.

The existing Draft -> APPLY safety concept remains applicable: editing/viewing settings in the panel must not silently bypass route/execution safety gates.

### Preset scopes

The configuration system must support at least two independent save/load scopes:

1. **EA / Portfolio preset**
   - saves the complete Multi Alpha configuration as one recoverable portfolio
   - includes enabled slots and the configuration needed to restore #01-#50
   - includes slot routes, symbols/mappings references, module settings and filters as applicable

2. **Individual Slot preset**
   - #01, #02, ... #50 can each be saved and loaded independently
   - loading one slot must not overwrite unrelated slots
   - a slot preset should be reusable for copying/testing a strategy configuration independently

The default common-file layout should be compatible with:

`%APPDATA%\MetaQuotes\Terminal\Common\Files\MultiAlpha\O01\Presets`

A logical default layout may separate whole-EA and per-slot presets, for example:

```
MultiAlpha\O01\Presets\
  EA\
  Slots\
    #01\
    #02\
    ...
    #50\
```

The exact file format/versioning can evolve, but the EA-wide and per-slot save/load capabilities are part of the target architecture.

### User-selectable storage root

The preset storage location must not be permanently hard-coded to `MultiAlpha\O01\Presets`.

The user must be able to select/configure a storage root, with the standard location offered as the default. Because MQL5 file access is sandboxed, the first implementation should treat the MT5 Common Files area (`FILE_COMMON`) as the safe base and allow a user-selected subpath beneath it, for example:

- `MultiAlpha\O01\Presets`
- `MultiAlpha\MyPresets`
- `MultiAlpha\ForwardTest`
- `MultiAlpha\TitanFX_Micro`

If a later implementation supports an additional MT5-permitted storage mechanism, it must preserve the same configurable-root contract and fail safely when a requested location is unavailable.

The panel should provide clear controls for storage root, SAVE ALL / LOAD ALL, and SAVE / LOAD for the currently selected slot. Invalid/missing preset paths or incompatible preset versions must produce an explicit error and MUST NOT silently load defaults over an existing configuration.

### Preset data vs program code

Preset files store configuration/state required for restoration; they do not store Alpha program code. Alpha/module code remains in the registered EA/module implementation.

Preset data should carry a schema/version identifier so future module or configuration changes can be validated or migrated deliberately instead of being interpreted silently with the wrong structure.

## Strategy Tester / backtest architecture

The panel-first configuration and preset architecture MUST remain fully compatible with MT5 Strategy Tester. Detailed module settings do not need to be exposed as hundreds of Expert Inputs merely to make backtesting possible.

At tester startup, the host must be able to load the same versioned configuration/preset model used by normal operation. Backtest configuration should therefore be reproducible from saved presets rather than depending on manual panel state from a previous terminal session.

### Backtest modes

The target architecture must support three scopes:

1. **SINGLE SLOT**
   - run one selected Logic Slot, such as #01
   - intended for module development, parity tests, parameter studies, and fast regression
   - the slot may load its saved Slot preset

2. **SELECTED SLOTS**
   - run an explicitly selected subset such as #01, #03, #07, #12
   - intended for interaction tests and small portfolio comparisons without running all registered slots

3. **PORTFOLIO**
   - run the saved EA/Portfolio preset, potentially #01-#50
   - intended for final multi-logic / multi-symbol portfolio validation

The selected backtest scope must be explicit and reproducible; disabled/unselected slots must not trade or alter results.

### Multi-symbol backtest contract

Portfolio and Selected-Slots tests must use each slot's assigned logical symbol and resolved tester/broker symbol. The architecture must not assume that the chart/tester's primary symbol is the trading symbol for every slot.

Example research mapping:

- canonical XAUUSD -> tester XAUUSD_DUKA
- canonical EURUSD -> tester EURUSD_DUKA
- canonical USDJPY -> tester USDJPY_DUKA

Example broker mapping:

- canonical XAUUSD -> XAUUSD-m

The same Alpha configuration should be portable between research data and broker environments by changing the Symbol Mapping / Broker Symbol Registry, not by rewriting the Alpha logic.

Before a multi-symbol test is accepted, every enabled slot's required symbol/data mapping must be validated. Missing/unavailable symbol data must produce an explicit failure/status and MUST NOT silently substitute the primary tester symbol.

### Presets in Strategy Tester

Both EA/Portfolio presets and individual Slot presets are valid sources of Strategy Tester configuration.

The tester startup contract should allow a minimal bootstrap selection such as:

- Backtest Mode: SINGLE / SELECTED / PORTFOLIO
- preset storage root
- preset name/path or selected slot set
- required test identity/safety controls

All detailed Alpha parameters remain in the versioned preset/configuration model.

A test report/log should record enough configuration identity to reproduce the run, including preset/schema version, enabled slot IDs, canonical/resolved symbols, routes/modules, and relevant configuration identity/hash when implemented.

### Optimization policy

MT5 optimization must not require exposing every parameter of all 50 slots simultaneously.

The primary optimization scope is:

- SINGLE SLOT for normal Alpha parameter optimization
- SELECTED SLOTS only when a small combination genuinely needs joint study
- PORTFOLIO primarily for combined validation rather than brute-force optimization of every parameter across #01-#50

This prevents combinatorial parameter explosion while preserving the ability to evaluate the final portfolio.

If selected preset fields later need to participate in MT5's native optimization engine, they may be exposed through a deliberately small optimization bridge/input set. This exception must not turn Expert Properties back into a complete duplicate of every module's panel settings.

### Migration and regression rule

Current O01/XAUUSD parity baselines remain valid regression references during migration. The move to slot-assigned symbols and multi-symbol tester operation must be staged; frozen O01 behavior must not be rewritten in one step merely to reach the portfolio target.

Single-slot parity must be preserved first, followed by selected-slot/multi-symbol tests, and only then full portfolio backtest validation.

## Execution boundary

Current verified research/parity hosts remain NO_ORDERS=1 / VIRTUAL_NOT_FILL=1.

Future broker-demo execution is one adapter owned by the single Multi Alpha EA host. Entry/Manage/Exit decision modules never place broker orders directly.

Every demo instance must have:
- hard DEMO-account lock
- HEDGING-account lock
- unique Magic
- Symbol + Magic filtering
- explicit execution-transition state
- checked/logged broker results

## Development order from v1.60

1. Keep v1.60 as the compiled UI/safety baseline.
2. Add a module registry/descriptor contract. Registration is capability-specific: FULL, ENTRY, MANAGE, EXIT.
3. Register O01 in all verified capabilities without changing O01 decision logic.
4. Make both panels query the registry instead of hard-coding O01 registration tests.
5. Add A10 as the first non-O01 ENTRY registration, including its own settings descriptor/panel binding.
6. Re-run NO_ORDERS regression and route fail-safe tests.
7. Only then add the single-EA DEMO execution adapter and unique-Magic instance isolation.
8. Deploy the SAME Multi Alpha EA binary to the remote MT5 for FULL and SPLIT comparison charts.

## Compatibility rule

No change in this architecture document authorizes a change to the frozen O01 parity logic. FULL remains an independent whole-path reproduction; SPLIT remains independently routed Entry/Manage/Exit responsibilities.


## A10 SPLIT integration priority — 2026-09-29

A10 is the first A-series module to be integrated into the single Multi Alpha panel as a complete SPLIT route.

Integration order:
1. expose verified A10 ENTRY / MANAGE / EXIT capabilities;
2. connect the documented A10 split virtual lifecycle to the current NO_ORDERS host;
3. preserve the verified A10 FULL and SPLIT parity logic without optimization;
4. add A10 ENTRY operating-stop controls before expanding to A11+.

For **A10 ENTRY [E]**, the product-direction settings must include:
- normal News Filter;
- the original/special stop filter (Special Risk / Event-Day Filter);
- user-selectable operating time where applicable.

These filters gate **new A10 entry/cycle permission**. They must not silently disable A10 EXIT processing or common Emergency/Safety protection. MANAGE and EXIT keep their own responsibility-specific filter contracts as documented above.

Until a mixed-module position/state ownership contract is connected and regression-tested, O01/O01/O01 and A10/A10/A10 are valid SPLIT ownership sets; mixed O01/A10 E/M/X combinations must fail safely rather than fallback.
