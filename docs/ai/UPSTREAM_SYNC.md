# Sure Upstream Synchronization

Use this procedure when bringing a newer Sure version into Haven. Do not combine
an upstream sync with unrelated feature development.

## Preconditions

1. Use a dedicated branch or worktree.
2. Ensure existing Haven/user work is safely represented and understood.
3. Record current Haven commit and target Sure commit/tag.
4. Read `CUSTOMIZATION_MANIFEST.md` and identify hotspots.
5. Review Haven migrations, API changes and feature gates.
6. Establish a passing or accurately documented pre-sync baseline.

Do not start when unidentified local changes could be overwritten.

## Merge principles

- Preserve Sure improvements unless they conflict with intentional Haven needs.
- Preserve Haven through isolated code and narrow hooks.
- Resolve conflicts semantically after reading both sides and tests.
- Never mechanically choose all `ours` or all `theirs`.
- Evaluate whether old Haven fixes should be dropped, retained or adapted when
  Sure has changed the same area.
- Prefer adapting a small Haven hook over restoring an obsolete upstream file.

## Conflict review order

1. migrations, schema and configuration;
2. authentication, authorization and account visibility;
3. ledger, finance, imports, sync and providers;
4. API contracts and mobile/desktop consumers;
5. manifest-listed Haven integration points;
6. routes, navigation, shared UI and locales;
7. isolated Haven code.

## Database safety

- Never casually edit, renumber or discard an applied migration.
- Detect migration timestamp collisions.
- Compare schema meaning, not only schema-file text.
- Check upstream constraints/defaults against Haven tables and foreign keys.
- Separate destructive/backfill work and obtain explicit authorization.
- Do not automatically run migrations during conflict resolution.

## Verification after sync

Run, in increasing scope:

1. tests for each resolved conflict;
2. Haven feature tests;
3. Sure/Haven integration-boundary tests;
4. affected finance, authorization, API and provider tests;
5. full Rails suite when feasible;
6. relevant lint, security and generated-doc checks;
7. mobile/desktop checks when contracts changed.

Compare failures with the pre-sync baseline. Do not call a failure pre-existing
without evidence.

## Required record

Record the Sure source commit/tag, sync date, significant conflicts and semantic
decisions, changed Haven hooks, migrations/config/manual actions, checks run and
remaining risks. Update the customization manifest whenever ownership or
integration points change.

A dedicated upstream-status file may be introduced with the first formal sync;
do not invent an unverified baseline in advance.

## Rollback

Define how to return to the recorded pre-sync state before high-risk work.
Rollback must not use destructive commands against unidentified working-tree
changes or production data. Database rollback needs a separate data-safe plan.

