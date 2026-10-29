# Haven Customization Manifest

This is the durable ledger of Haven-owned features and their integration points
with Sure. It makes future Sure merges auditable.

Update it when a Haven feature or integration point is added, removed or
materially changed. Do not record ordinary Sure-compatible fixes unless they
create lasting downstream divergence.

## Current baseline

- Manifest established: 2026-09-02.
- New downstream features use `Haven::` and `haven/` paths.
- The Rails application module remains `Sure::Application`.
- Formally catalogued Haven features: compact transaction log (below).
- Historical changes predating this manifest are not automatically classified as
  Sure-owned or Haven-owned. Audit them when touched or before the first formal
  Sure synchronization.

This avoids claiming that existing goals, providers, pending behavior or other
repository additions are upstream Sure or Haven customization without evidence.

## Feature entry template

```markdown
## Feature name

- Status: proposed / experimental / active / disabled / retired
- Product purpose:
- Feature gate and default:
- Haven-owned code:
- Haven-owned tables/columns:
- Sure-owned integration points:
- API surface:
- Mobile/desktop dependencies:
- Financial invariants:
- Authorization/privacy rules:
- Provider/sync dependencies:
- Main tests:
- Known upstream conflict hotspots:
- Disable/rollback behavior:
- Last reviewed against Sure commit/tag:
- Notes:
```

Omit genuinely irrelevant fields, but never omit real financial, authorization,
persistence or rollback effects.

## Integration-point record

For every Sure-owned file changed specifically for Haven, record:

- exact file and narrow purpose;
- why Haven-only implementation was insufficient;
- tests protecting Sure baseline and Haven behavior;
- expected upstream conflict risk;
- removal or disable path.

## Historical audit queue

Before the first formal Sure sync, compare Haven with the selected Sure baseline
and classify divergences as:

1. upstream Sure code;
2. Sure-compatible fixes suitable for contribution;
3. Haven-specific features to isolate/catalogue;
4. stale, generated or environment-only differences;
5. unknown changes requiring user or history evidence.

Do not perform this audit opportunistically during unrelated feature work.

## Compact transaction log

- Status: active (2026-09-24).
- Product purpose: time-ordered spending journal with a compact, headerless list;
  desktop search, optional original-currency filtering and stable transfer pagination.
- Haven-owned code: `app/models/haven/transaction_list.rb`,
  `app/models/haven/transaction_search.rb`, `app/assets/stylesheets/haven/transactions.css`,
  `app/javascript/controllers/haven/{currency_filter,transaction_search}_controller.js`,
  `app/views/haven/transactions/_currency_filter.html.erb`,
  `config/locales/haven.transactions.*.yml`.
- Sure-owned integration points (narrow hooks into the existing page, avoiding a copy):
  - `app/controllers/transactions_controller.rb`: accepts optional currency, uses
    the derived search only with that filter, passes authorized search results
    through `Haven::TransactionList` before pagination. Original totals still use
    the uncollapsed scope. The page keeps 30 as its default size while accepting
    Sure's 10 and 100 options. No core model or ledger mutation.
  - `app/views/transactions/index.html.erb`: opts into scoped Haven styling,
    gives desktop search flexible width, positions overview below the toolbar.
  - `app/views/transactions/{_transaction,_split_parent_row}.html.erb` and
    `_status.html.erb`: row class hooks, Haven transaction-log category rendering,
    a scoped status marker, and Sure's clickable-row hook. The global transaction log shows provider-source
    provenance while account activity retains the protection lock. The transaction
    log emits cells in name/status/category/merchant/account/amount DOM order,
    so its sequence does not depend on a compiled CSS reorder. Account activity
    retains Sure's merchant-before-category order and investment-activity badge.
    Scoped grid widths apply inside the global transaction log only. Desktop
    widths and gaps are centralized as CSS custom properties: text tracks shrink
    with available space, status reserves 6rem, amount reserves 10rem, and account
    has an extra 0.5rem inset after the right-aligned merchant. No wide-viewport
    rule restores rigid text minima when sidebars consume the available width.
  - `app/views/entries/_entry_group.html.erb`: date span hook for scoped 600
    weight; count and daily totals retain 500. Haven styling uses Geist for
    dates and daily totals, and Geist Mono for transaction amounts with tighter
    row-amount spacing. Split parent rows show the same amount and currency-code
    format as transaction rows.
    Account activity typography is unchanged.
  - `app/views/transactions/searches/_form.html.erb`: single responsive search
    field, desktop expanded/mobile folded when empty; retains blur submission.
  - `app/views/transactions/searches/filters/_amount_filter.html.erb`: native
    exclusive radio controls and a currency partial.
  - `app/javascript/controllers/transaction_filter_menu_controller.js`: removing
    the selected currency condition also disables its selector.
  - `app/views/layouts/shared/_head.html.erb`: loads the isolated plain CSS
    asset after Tailwind, with digest-based caching and Turbo reload tracking.
    Haven layout rules bypass Tailwind incremental compilation: an existing
    watcher was reproduced overwriting a correct one-off build with output
    missing all Haven rules when a new template utility was introduced.
- Sure-compatible accompanying fix: `app/helpers/transactions_helper.rb` and
  `app/views/transactions/searches/_date_menu.html.erb` use inclusive 7/14/30-day
  ranges beginning 6/13/29 days ago. Button matching and query bounds agree.
- Financial invariants: no writes, conversions, migrations, sync/provider or
  calculation changes. Currency refers to `entries.currency`, not account currency.
  Currency participates in inherited search cache keys. Totals retain Sure's
  existing treatment of both transfer legs and excluded account types; the page
  count reflects displayed rows, not summary ledger-entry count.
- Authorization/privacy: collapse an inflow only when the outflow belongs to the
  same filtered, authorized scope. One-sided account/date/text/currency results
  retain the matching leg. No changes to core access control.
- Tests: `test/models/haven/{transaction_list,transaction_search}_test.rb`,
  `test/controllers/haven/transaction_log_test.rb`,
  `test/system/haven/transaction_log_test.rb`; existing transaction controller
  and search suites cover unchanged Sure behavior.
- Upstream conflict risk: YELLOW at the transaction controller, list partials,
  search form and filter-menu controller. Re-check transfer associations,
  inherited search scope/cache attributes, pagination and Stimulus target names
  at the next Sure merge. Design-system primitives and financial core untouched.
- Rollback: remove the controller/query/style/partial hooks and Haven files;
  no data rollback or migration required. Removing the currency feature should
  also stop accepting its query parameter; saved filters then ignore it.
- Last reviewed against Sure `v0.7.5-alpha.11` (`01bd2542`) on 2026-09-25.
  The synchronization decisions and migration exception are recorded in
  `docs/ai/SURE_SYNC_STATUS.md`.
- Product decisions and deferred work: `docs/ai/TRANSACTION_LOG_UX_BACKLOG.md`.
