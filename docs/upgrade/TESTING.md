# Testing (upgrade track)

## Philosophy

- **Prefer fast, reliable unit specs** over slow or flaky feature/system specs.
- Use **`bin/rspec-fast`** for day-to-day work on `scholar-modernization`.
- CircleCI runs the **full** suite (including `:slow` examples) on push.

## Fast local specs

```bash
bin/rspec-fast
bin/rspec-fast spec/models/article_spec.rb
```

`bin/rspec-fast`:

- Sets `SCHOLAR_FAST_SPECS=1`
- Excludes examples tagged `:slow`
- No Fedora, Solr, Redis, or browser required
- Includes `spec/throwaway/` slop checks (tagged `throwaway: true`) when `SCHOLAR_FAST_SPECS=1`
- CircleCI **excludes** `throwaway: true` (see `spec/support/throwaway_spec_metadata.rb`); “No timing found for spec/throwaway/…” in CI logs is expected

## Slow tier (`:slow`)

Examples tagged `:slow` need Fedora and/or Solr and/or Capybara. Run only when needed:

```bash
# Full suite (services must be running — see root README)
bundle exec rspec
```

Metadata is configured in `spec/support/slow_spec_metadata.rb`.

## When to add tests

| Change type | Preferred test |
|-------------|----------------|
| Service / model logic | Unit spec (`spec/models`, `spec/services`) |
| Presenter / indexer | Unit spec with doubles |
| Controller behavior | Request spec or controller spec |
| Deposit UI / multi-step flow | Manual scholar-dev smoke + existing feature specs only if already present |
| New feature spec | **Avoid** unless no unit-level coverage is possible |

## Per-slice minimum

1. `bin/rspec-fast` green (or targeted paths for the slice)
2. `bundle exec rubocop` on changed Ruby files
3. Push for CircleCI full suite before calling a sub-phase done on scholar-dev

## Throwaway specs

`spec/throwaway/` holds lightweight checks for upgrade scaffolding (e.g. metadata YAML shape). Tagged `throwaway: true`; included in `bin/rspec-fast`.

## Phase-specific notes

| Phase | Testing focus |
|-------|----------------|
| A | Remove dead code; keep or add unit specs for retained behavior (DOI, Shibboleth helpers) |
| B | Hyrax upgrade generators; re-run full CI each hop; Wings smoke via INTEGRITY matrix |
| C | Integrity verification scripts; optional rake tasks (unit-tested if added) |
| D | Migration idempotency; count parity |

## CI

CircleCI config unchanged for now. Upgrade branch pushes should stay green before scholar-dev deploy.

See root [README.md](../../README.md) for starting Fedora/Solr locally for slow specs.
