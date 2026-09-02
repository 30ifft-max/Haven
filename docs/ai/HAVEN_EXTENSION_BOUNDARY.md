# Haven Extension Boundary

This document keeps Haven-specific work separable from Sure so future upstream
merges remain practical.

## Naming and ownership

- Sure-owned code is existing upstream-compatible application behavior.
- Haven-owned code is downstream behavior such as investment analysis and
  investment journals.
- New Haven Ruby code uses `Haven::...` and `haven/` paths.
- Keep `Sure::Application`; do not rename upstream infrastructure.

Preferred locations are `app/models/haven/`, `app/controllers/haven/`,
`app/components/haven/`, `app/views/haven/`,
`app/javascript/controllers/haven/`, `config/locales/haven.*.yml` and equivalent
test paths.

## Classify before implementation

If a change benefits normal Sure users without Haven-specific assumptions,
follow the existing Sure architecture and keep it suitable for upstream
contribution. Otherwise place it behind the Haven boundary.

Do not force generic bug fixes into `Haven::`, and do not disguise Haven product
policy as a generic Sure model concern.

## Integration rules

For each Haven feature:

1. Prefer an isolated Haven model/PORO, controller, component or adapter.
2. Reuse canonical Sure data rather than copying a second source of truth.
3. Keep required Sure-owned edits narrow, explicit and tested.
4. Prefer registries, adapters, small route blocks, component composition and
   feature gates over broad conditionals.
5. Record Sure integration points in `CUSTOMIZATION_MANIFEST.md`.

Avoid whole-page copies, large Haven branches in upstream views, monkey patches,
class reopening, `prepend` overrides, and Haven orchestration inside central
`Account`, `Family`, `Entry`, `Transaction`, `Trade` or `Holding` models.

## Persistence

- Haven-owned tables should use clear `haven_` prefixes where appropriate.
- Explicitly document any Haven model using an existing Sure table.
- Never allow namespacing to silently change an existing model's table.
- Prefer foreign keys to canonical Sure records over copied financial facts.
- Store Haven notes, plans, classifications and review metadata separately from
  canonical ledger truth.
- Derived analytics should normally be rebuildable unless a documented cache
  contract defines invalidation.

## Investment analysis

- Consume authorized canonical Sure facts without rewriting ledger history.
- Put calculations in `Haven::*` calculators, queries or projections.
- Define formulas, date scope and missing-data behavior explicitly.
- Reuse one canonical calculation per metric across UI paths.
- Persisted caches require invalidation for trades, holdings, prices, FX and
  visibility changes.

## Investment journals

- Haven may own narratives, theses, plans, reviews, tags and attachments.
- Links to trades, accounts and securities must be authorization-scoped.
- Journal edits do not mutate canonical financial records by default.
- Financial writes must use an existing canonical Sure path or a separately
  approved transactional boundary.
- Decide audit/revision behavior before users depend on mutable journal history.

## Feature gates and exceptions

Use a feature gate for large, experimental, high-coupling or independently
reversible features. Disabled behavior must block direct access and writes, not
only hide navigation, while retaining data.

Edit a Sure-owned RED surface only when the extension layer is insufficient.
Document why, the exact hook, baseline and Haven tests, merge risk, and
disable/rollback behavior. Update the manifest in the same task.

