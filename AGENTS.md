# Haven Codex Engineering Contract

> Canonical AI engineering contract for this repository.
>
> Haven is a long-lived downstream extension of Sure, not a rewrite. New Haven
> features must remain isolated so future Sure releases can still be merged.
> Detailed rules live in `docs/ai/` and are loaded only when relevant.

## 1. Instruction precedence

When instructions conflict, use this order:

1. Explicit user instructions for the current task.
2. This `AGENTS.md`.
3. Task-relevant documents under `docs/ai/`.
4. Other task-specific repository documentation.
5. Existing tests, code, schema and configuration as evidence.
6. Inherited or legacy guidance such as `CLAUDE.md` and `.cursor/rules/`.

Do not blindly follow stale documentation when code, tests or configuration
disagree. Investigate and report the mismatch.

## 2. Mission

Optimize changes in this order:

1. financial and data correctness;
2. authorization, privacy and security;
3. compatibility with Sure upstream;
4. isolation of Haven-specific behavior;
5. testability and rollback safety;
6. user experience;
7. performance where evidence justifies it;
8. local code elegance.

Do not trade correctness or upstream maintainability for fewer lines of code.
The user is not expected to make technical decisions that the repository can
answer; investigate first and explain material choices in clear Chinese.

## 3. Mandatory task start

Before editing:

1. Inspect `git status`.
2. Treat every existing modified or untracked file as user-owned.
3. Do not overwrite, delete or reset unrelated user changes.
4. Classify the task as either Sure-compatible work or Haven-specific work.
5. Inspect relevant code, callers, tests, schema and analogous implementations.
6. For non-trivial work, form a concise plan before editing.
7. Load only the task-relevant documents listed below.

## 4. On-demand instruction map

Read before acting when the trigger applies:

- Repository navigation or unfamiliar subsystem:
  `docs/ai/PROJECT_MAP.md`
- Any new or changed Haven feature or Sure integration point:
  `docs/ai/HAVEN_EXTENSION_BOUNDARY.md`
- Any YELLOW or RED change:
  `docs/ai/RISK_ZONES.md`
- Balances, entries, transactions, trades, holdings, performance, cost basis,
  prices, FX or other financial calculations:
  `docs/ai/FINANCIAL_INVARIANTS.md`
- Choosing or running verification:
  `docs/ai/DEVELOPMENT_WORKFLOW.md`
- Merging or rebasing from Sure upstream:
  `docs/ai/UPSTREAM_SYNC.md`
- Adding or changing a Haven feature or its Sure integration point:
  read and update `docs/ai/CUSTOMIZATION_MANIFEST.md`

Do not load unrelated specialist documents merely because they exist.

## 5. Scope discipline

Always:

- make the smallest coherent change;
- preserve public behavior unless the task explicitly changes it;
- search for an existing pattern before creating an abstraction;
- add or update tests for behavior changes;
- inspect the final diff and keep it free of unrelated changes.

Never, unless explicitly requested:

- commit, push, open a PR or rewrite Git history;
- delete or reset user changes;
- perform destructive Git, filesystem, database or production operations;
- start a long-running Rails server merely for verification;
- automatically run migrations;
- edit an existing migration or hand-edit `db/schema.rb`;
- add a dependency without a strong reason;
- perform unrelated cleanup, refactoring or bulk formatting.

## 6. Sure and Haven boundary

Sure-compatible changes should follow Sure's existing architecture and be kept
suitable for upstream contribution where practical.

Haven-specific features, including investment analysis and investment journals,
must prefer the `Haven::` Ruby namespace and corresponding `haven/` directories.
The Rails application module remains `Sure::Application`; do not rename upstream
core merely because this downstream repository is called Haven.

Prefer isolated Haven models/POROs, controllers, components, views, Stimulus
controllers, locales and tests. Do not dump Haven domain logic into central Sure
models such as `Account`, `Family`, `Entry`, `Transaction`, `Trade` or `Holding`.

Aim for narrow, explicit, tested integration points in Sure-owned files. Avoid
whole-page copies, monkey patches, class reopening and broad upstream rewrites.
See `docs/ai/HAVEN_EXTENSION_BOUNDARY.md` for paths and exceptions.

## 7. Risk control

- GREEN: isolated Haven code, tests, locales and documentation.
- YELLOW: routes, navigation, shared pages, core associations, configuration,
  API shapes and shared component call sites.
- RED: ledger and financial core, money/FX/cost/performance logic, sync/import,
  providers, authentication/authorization, API foundations, existing migrations
  and Sure design-system core.

For RED changes:

1. establish why the Haven extension layer is insufficient;
2. keep the diff as small as possible;
3. add direct regression tests and integration-boundary tests;
4. report the upstream merge risk explicitly;
5. identify financial, security or data assumptions requiring human review.

## 8. Mandatory engineering rules

- Use `Current.user` and `Current.family`, not `current_user` or
  `current_family`.
- UI hiding is not authorization; scope records by accessible family/account and
  distinguish read from write access.
- Never expose credentials, tokens or sensitive financial/provider payloads in
  logs, errors, exports, notifications or AI context.
- Use Money/Decimal mechanisms for financial values; never silently combine
  currencies or substitute current FX for historical FX.
- Sync/import paths must preserve idempotency, provider identity, namespaced
  metadata, pending semantics and user-edited fields.
- Use `DebugLogEntry.capture(...)` for support-relevant recoverable provider
  diagnostics; never log secrets or full sensitive payloads.
- New migrations inherit from `ActiveRecord::Migration[7.2]` until the repository
  convention explicitly changes.
- API behavior belongs in Minitest; rswag specs are documentation-only and use
  the existing `X-Api-Key` convention.
- Post-commit API consistency: when an API endpoint is committed, follow
  `docs/llm-guides/api-endpoint-consistency.md` for Minitest, rswag and
  `X-Api-Key` checks.
- UI work checks `app/components/DS/` first, uses semantic design tokens, the
  `icon` helper and `t()` for user-visible strings.
- Read `docs/llm-guides/adding-a-securities-provider.md` before adding a
  securities price provider.

## 9. Verification

Run focused checks first, then broaden according to risk. Never delete or weaken
a test merely to make a change pass. If a relevant check cannot run, state why
and do not imply it passed.

Behavior is primarily tested with Minitest and fixtures. External HTTP uses the
existing VCR/WebMock patterns. API documentation uses docs-only RSpec/rswag.
Detailed commands and the verification matrix are in
`docs/ai/DEVELOPMENT_WORKFLOW.md`.

## 10. Completion and reporting

A task is complete only when:

- the requested behavior is implemented;
- the diff is focused and preserves user-owned changes;
- relevant tests pass or failures are reported accurately;
- required generated artifacts and documentation are updated;
- migration, configuration and manual steps are explained;
- financial, authorization, sync and upstream risks are reported honestly.

Report results in clear Chinese. Include only relevant categories, but always
state what changed, tests run and not run, remaining uncertainty, and Sure
upstream impact. For RED changes, also explain why the core edit was necessary
and what the next Sure merge must re-check.
