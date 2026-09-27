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
