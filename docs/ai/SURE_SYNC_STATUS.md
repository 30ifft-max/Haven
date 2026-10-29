# Sure upstream synchronization status

## 2026-09-25: v0.7.5-alpha.11

- Haven starting commit: `c1be0807` on `R-0.7.5.a3_transaction-improvements`.
- Sure target: `v0.7.5-alpha.11` (`01bd2542d70b74fdd89f08bff7e2602ce811ede1`).
- Actual merge base: `55cec279e50c6a119e14ad82b6faca0284cc9e5a`, the version bump after Sure alpha.2. The Haven branch name does not establish an alpha.3 tag baseline.
- Integration branch: `codex/sync-sure-0.7.5-alpha11`. The starting Haven branch and commit are the source rollback point; do not reset a working tree with local changes.
- Merge method: `git merge --no-commit --no-ff v0.7.5-alpha.11`, followed by semantic conflict resolution. No database migrations were run.

## Decisions at overlapping paths

- Kept the Haven transaction log and account-activity layout, scoped styling, authorized transfer collapse, sort time, split order, group-only categories, and transfer classification. Brought in Sure's transaction idempotency, split import/notes preservation, category parent preloading, split grouping on account activity, and row click behavior through their existing hooks.
- The global transaction and account activity pages retain a default page size of 30, and now accept Sure's 10 and 100 choices as well. Pagination tests exercise the supported sizes.
- The categorization-provider label retains localization while adopting Sure's new provider terminology.
- Kept the Haven `20260920000001_add_split_order_to_entries.rb` migration identifier to avoid reapplying an existing Haven migration. The incoming Sure `AddRequestedConsentValidUntilToEnableBankingItems` migration was assigned the free identifier `20260919235959`, before its dependent Sure index migrations. This is an intentional upstream filename divergence to review on the next sync.
- Combined disjoint Sure and Haven table and foreign-key sections in the generated schema conflict, then checked syntax and the presence of both sides' columns. Schema equivalence to a fresh migration run remains to be verified in a disposable database before deployment.
- Kept `AGENTS.md` as Haven's local engineering contract. Sure's other guidance remains available under `docs/llm-guides/`.

## Deployment and follow-up

- Install locked Ruby dependencies. Review new provider and FinanceKit configuration and secrets before enabling those integrations.
- Review migration order and apply migrations through the normal deployment procedure after a backup and database-specific review. Do not deploy code that expects new columns before migrations complete.
- Recheck `Transfer::Creator`, `Entry#split!`, transaction search/caching, account visibility, authorization, provider sync, and API contracts when taking the next Sure release.

## Verification

- Before sync: 12 Haven transaction-list tests, 58 assertions, passed.
- After sync: 9,684 Rails tests, 40,911 assertions, 0 failures, 0 errors, 33 skips, with two image-variant tests excluded because this machine has no `libvips` library and Rails initialized `ActiveStorage.variant_transformer` as `nil`. An initial unfiltered full run had those two errors and three assertions that were subsequently fixed and retested.
- Haven transaction-log system tests: 4 runs, 78 assertions, passed.
- Focused ERB lint (five affected partials), RuboCop (seven affected Ruby files), and `npm run lint` passed.
- `db/schema.rb` parses, with 163 unique table names; 440 migration versions have no duplicates. The merged schema was exercised by the Rails test suite, but the migration chain was not run against a fresh database.
- `git diff --cached --check` reports only whitespace already present in the fetched Sure tag (localized files and `docs/hosting/docker.md`); no conflict marker remains.

The next required verification before deployment is to run the two excluded image tests on a host with `libvips`, then test the migration chain on a disposable copy of the deployment database. Review new provider configuration and data migration effects for the actual installation.
