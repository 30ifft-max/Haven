# Haven Financial Invariants

Read before changing financial data, calculations or reporting. Current code and
tests are the source of truth for exact conventions.

## Canonical truth

- Do not create a second Haven ledger.
- Reuse canonical Sure `Entry`, `Transaction`, `Trade`, `Valuation`, `Holding`,
  `Balance`, security-price and exchange-rate records as appropriate.
- Haven may own notes, plans, classifications, reviews and rebuildable
  projections, but must not silently duplicate authoritative amounts,
  quantities, prices or provider identity.
- Real financial writes use a defined canonical path and one transaction
  boundary.

## Amounts and precision

- Use project Money and Decimal/BigDecimal mechanisms; do not use binary `Float`
  for core financial truth.
- Confirm database precision, scale and rounding at persistence boundaries.
- Round at defined output/persistence boundaries, not during intermediate math.
- Preserve original value and currency when reporting conversion is derived.
- Never present a missing value as zero unless zero is financially correct.

## Sign conventions

Verify from code and tests how the affected model represents inflows, outflows,
assets, liabilities, buys, sells, fees, taxes, income, transfers and long/short
quantities. Translate signs once at a named boundary; avoid scattered negations.

## Currency and FX

- Never add amounts across currencies without an explicit conversion policy.
- Distinguish original, account, family/reporting and display currencies.
- Historical reports use rates appropriate to event or valuation dates.
- Never silently substitute current FX for missing historical FX.
- Never fall back to 1:1 except for identical currencies.
- Preserve requested and actual rate dates when nearby observations are allowed.
- Missing, stale, future, invalid or mismatched FX must be explicit as
  unavailable/degraded according to the metric contract.

## Trades, holdings and cost basis

- Define which record is authoritative for each quantity, price, cost and date.
- Do not add a holding snapshot to a trade-derived position as separate assets.
- Reconcile sources before choosing what to project.
- Cost-basis method must be explicit and covered by fixed samples.
- Define partial/full closure, reversal, fees, income and missing-history cases.
- Do not infer short positions, tax lots or acquisition history from ambiguity.
- Missing cost basis remains unavailable, never zero cost.

## Performance and risk

Each metric must define its numerator, denominator, included flows/fees/taxes,
valuation date, price source, currency, FX date, open/closed treatment, date
filter and missing/zero-denominator behavior.

Use deterministic regression samples. Do not fabricate precise-looking advanced
metrics without complete inputs and reviewed formulas. Forecasts, plans, targets
and journal theses must remain visibly distinct from actual ledger results.

## Pending and provider data

- Preserve provider metadata under its existing `extra` namespace.
- Verify pending/posted behavior for the specific provider.
- Do not count a pending record and posted replacement twice.
- Preserve user-locked or user-edited fields during sync.
- Missing provider pending information is unknown/not supplied, not universally
  equivalent to false.

## Authorization is a financial invariant

- Scope all inputs to the authorized Family and accessible accounts before
  aggregation.
- Respect private/shared visibility and report-inclusion settings.
- Writes use writable scope, not merely readable scope.
- Test cross-family IDs and partial account access.
- Do not leak hidden-account values through totals, charts, counts or errors.

## Investment journals

- Journal narratives and reviews do not change ledger truth by themselves.
- Linked accounts, securities and trades are authorized on every read/write.
- Define audit/revision policy before historical journal edits become important.
- Journal classification must not overwrite provider evidence without a
  separately reviewed write or migration contract.

## Minimum review record

For each affected metric or write path, establish:

1. source of truth;
2. sign convention;
3. precision and rounding;
4. currency and FX date;
5. authorization scope;
6. pending and missing-data behavior;
7. fixed regression example;
8. rollback or rebuild behavior.

