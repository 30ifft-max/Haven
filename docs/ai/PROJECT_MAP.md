# Haven Project Map

Use this map to find the correct ownership boundary without loading the whole
repository. The database schema and current code remain the source of truth.

## Identity and instructions

- **Sure** is the upstream application and existing Rails product core.
- **Haven** is the downstream extension maintained in this repository.
- New Haven-specific code uses `Haven::`; Rails remains `Sure::Application`.
- `AGENTS.md` is the mandatory core contract.
- Other files in `docs/ai/` are loaded only for their task triggers.

## Main application

- `app/models/` — domain models, concerns and POROs; central finance is RED.
- `app/controllers/` — web controllers.
- `app/controllers/api/v1/` — external versioned API.
- `app/components/` — ViewComponent UI; `app/components/DS/` is Sure's design
  system.
- `app/views/` — server-rendered ERB.
- `app/javascript/controllers/` — Stimulus behavior.
- `app/jobs/` — sync, import, AI, export and maintenance jobs.
- `app/services/` — limited infrastructure services, not the default domain
  layer.
- `app/assets/tailwind/` — Tailwind and design-system tokens.

## Core financial shape

- `Family` owns users, accounts and most family financial data.
- `Account` is the account aggregate and delegates account-specific fields.
- `Entry` is the dated ledger record and delegates to types including
  `Transaction`, `Trade` and `Valuation`.
- `Transaction` represents categorized cash activity.
- `Trade` represents investment activity.
- `Holding` represents dated account/security/currency snapshots.
- `Balance` represents materialized account balance history.
- `Security` and security prices supply instrument and market data.

Verify relationships against current models and `db/schema.rb` before changing
them.

## Data ingestion and persistence

- Provider models/processors live mainly under `app/models/`.
- Provider configuration lives under `config/initializers/`.
- Imports and syncs commonly continue through `app/jobs/`.
- `config/routes.rb` is shared and YELLOW.
- `db/migrate/` is append-only migration history.
- `db/schema.rb` is generated and must never be hand-edited.
- `.env*.example` documents environment configuration.

## Haven isolation targets

Create only when a real feature needs them:

- `app/models/haven/`
- `app/controllers/haven/`
- `app/components/haven/`
- `app/views/haven/`
- `app/javascript/controllers/haven/`
- `config/locales/haven.*.yml`
- corresponding `test/**/haven/` paths

Record each real Haven feature and Sure integration point in
`CUSTOMIZATION_MANIFEST.md`.

## Tests and API documentation

- `test/models/`, `test/controllers/`, `test/components/`, `test/jobs/`,
  `test/integration/`, `test/system/` — Minitest behavior coverage.
- `test/fixtures/` — fixture data.
- `spec/requests/api/v1/` — docs-only rswag definitions.
- `spec/swagger_helper.rb` — reusable OpenAPI schemas.
- `docs/api/openapi.yaml` — generated API documentation.

## Other clients and deployment

- `mobile/` — Flutter/Dart; inspect actual consumers before API changes.
- `desktop/` — Tauri/Rust and TypeScript desktop shell.
- `charts/sure/` — Helm/Kubernetes deployment.
- `compose.example*.yml`, `Dockerfile`, `docs/hosting/` — self-hosting.

## Common traces

- Web: `route -> controller -> authorization -> domain -> view -> tests`
- Haven: `small Sure hook -> Haven::* boundary -> Haven domain/UI -> tests`
- API: `route -> auth/scope -> domain -> response -> Minitest -> rswag`
- Provider: `config -> client -> processor -> canonical records -> job -> tests`

