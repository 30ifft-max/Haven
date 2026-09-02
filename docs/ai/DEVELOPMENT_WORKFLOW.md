# Haven Development Workflow

Use the smallest verification set that gives confidence, then broaden according
to risk. Inspect a subproject before assuming its tooling.

## Before editing

1. Run `git status --short` and protect user-owned changes.
2. Classify Sure-compatible versus Haven-specific work.
3. Classify GREEN, YELLOW or RED risk.
4. Read only triggered `docs/ai/` documents.
5. Trace relevant routes, controllers, domain code, views and tests.
6. Inspect schema/migrations and external consumers when relevant.

## During implementation

- Keep the diff focused and follow existing patterns.
- Add tests alongside behavior changes.
- Keep Haven behavior in `Haven::*` and minimize Sure-owned hooks.
- Do not automatically run migrations or manually edit generated artifacts.
- Do not weaken tests or hide failures.

## Test ownership

- Minitest under `test/` is the behavior suite.
- Prefer fixtures over introducing FactoryBot.
- Use existing VCR/WebMock patterns for external HTTP.
- RSpec/rswag under `spec/requests/api/v1/` documents OpenAPI only.
- Reserve system tests for critical browser workflows.

## Common commands

```sh
bin/rails test path/to/relevant_test.rb
bin/rails test path/to/relevant_test.rb:LINE
bin/rails test
DISABLE_PARALLELIZATION=true bin/rails test:system
bin/rubocop
bundle exec erb_lint ./app/**/*.erb
npm run lint
npm run format:check
npm run tokens:check
bin/brakeman --no-pager
RAILS_ENV=test bundle exec rake rswag:specs:swaggerize
ruby test/support/verify_api_endpoint_consistency.rb --compliance
```

Confirm a command or script exists before relying on it.

## Verification matrix

### Model, query or calculator

- focused model/PORO and affected caller tests;
- fixed financial samples when applicable;
- RuboCop for touched Ruby.

### Controller, authorization or route

- controller/integration tests;
- authenticated, unauthorized and cross-family cases;
- disabled-feature direct access;
- route/helper tests where relevant.

### ERB, ViewComponent, CSS or Stimulus

- component/view/controller tests;
- ERB lint and relevant JavaScript checks;
- semantic tokens, `DS::*`, `icon` and i18n review;
- focused system test for critical interaction changes.

### Database

- review migration structure without automatically running it;
- test constraints/associations;
- analyze existing rows, rollback, deployment order and backfill;
- update schema only through an explicitly authorized migration run.

### Provider, sync or import

- processor/client/job tests;
- duplicate execution, retry, partial/malformed/paginated response cases;
- timeout, rate-limit, pending replacement and user-edit preservation;
- VCR/WebMock and DebugLog behavior where applicable.

### API

- Minitest behavior coverage;
- docs-only rswag update with no behavior assertions;
- OpenAPI regeneration and consistency verifier;
- inspect `mobile/` and other clients before breaking fields.

### Mobile or desktop

- read the subproject README/configuration;
- run relevant format, analysis, unit or build checks;
- inspect actual contract consumption before claiming no impact.

## Risk-based breadth

- GREEN: focused tests and touched-file checks.
- YELLOW: focused tests, integration boundary and relevant broader checks.
- RED: direct regression, authorization/data boundaries, relevant subsystem
  suite, security/static checks and explicit human-review notes.

Full-suite execution does not replace focused regression coverage.

## Before completion

1. Inspect `git diff` and `git status`.
2. Confirm unrelated user changes are untouched.
3. Confirm required generated artifacts are current.
4. Update the manifest for Haven integration changes.
5. Report each check actually run and its result.
6. Report relevant checks not run and why.
7. State remaining risk and Sure upstream impact.

