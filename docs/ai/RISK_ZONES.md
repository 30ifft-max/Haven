# Haven Risk Zones

Classify the touched surface before implementation. Risk depends on possible
impact, not line count.

## GREEN — isolated and reversible

Examples:

- new code entirely under `Haven::`;
- Haven tests, locales and documentation;
- read-only calculators over already-authorized inputs;
- isolated Haven components with no shared behavior change.

Expected controls: focused tests, no unrelated upstream edits, and a manifest
update for new features or integration points.

GREEN becomes YELLOW or RED if it writes canonical financial data, changes
authorization or relies on a risky shared hook.

## YELLOW — shared integration surface

Examples:

- routes, navigation, layouts and shared dashboards;
- shared settings and reports;
- associations or delegation on core models;
- initializers and environment configuration;
- API response fields;
- shared component call sites and feature gates;
- mobile or desktop consumer changes;
- isolated new database tables.

Expected controls: a minimal integration point, baseline behavior test, Haven
boundary test, caller review, and manifest entry when Haven-specific.

## RED — correctness, security or merge-critical core

Examples:

- `Entry`, `Transaction`, `Trade`, `Holding`, `Balance`, security prices and
  central reports;
- money, FX, cost basis, returns and performance formulas;
- imports, sync, reconciliation and provider processors;
- authentication, sessions, SSO, MFA, API keys and authorization foundations;
- family/account ownership, sharing and visibility;
- API authentication/base infrastructure;
- existing migrations and destructive data changes;
- Sure design-system primitives and token foundations.

Required before editing:

1. Explain why isolated Haven code cannot meet the requirement.
2. Trace the affected financial/data/authorization flow.
3. Verify existing invariants from code and tests.
4. Define failure, missing-data and rollback behavior.
5. Plan direct regression and integration-boundary tests.

Required before completion:

1. Run focused tests and broader relevant regression checks.
2. Inspect the diff for unintended core changes.
3. Update the manifest for Haven-specific integration.
4. Report the exact Sure merge hotspot.
5. State the largest remaining financial, security or data uncertainty.

## Escalation examples

- A Haven journal component is GREEN; letting it edit `Trade` is RED.
- A read-only Haven return calculator is RED because formula errors change
  financial meaning.
- A Haven navigation item is YELLOW.
- A Haven association on `Account` is YELLOW; changing account visibility is
  RED.
- An isolated table is normally YELLOW; rewriting ledger tables is RED.
- A provider display label may be YELLOW; reconciliation or pending replacement
  logic is RED.

