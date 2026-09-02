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
- Formally catalogued Haven features: none yet.
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

