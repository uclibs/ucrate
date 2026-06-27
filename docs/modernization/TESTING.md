# Testing tiers

Scholar@UC's full RSpec suite is slow and needs **Fedora**, **Solr**, and **Chrome** for integration and feature specs. CircleCI runs that full suite on every push. For day-to-day work on `scholar-modernization`, use the **fast tier** locally and rely on CI for the rest.

## Quick reference

| When | Command | Needs Fedora/Solr? | Typical time |
|------|---------|-------------------|--------------|
| **Local "done" for a slice** | `bin/rspec-fast` | **No** | ~10–15 seconds |
| **RuboCop** | `bundle exec rubocop` | No | Seconds–minutes |
| **Full suite (local)** | See [README](../../README.md#running-tests-all-platforms) | Yes | 20–30+ min |
| **Full suite (CI)** | Push to GitHub → CircleCI | Yes (CI sidecars) | ~same, but unattended |

Optional: pass paths or RSpec flags through the fast runner:

```bash
bin/rspec-fast spec/views/hyrax/collections/
bin/rspec-fast --only-failures
```

## What `bin/rspec-fast` runs

It executes `bundle exec rspec --tag '~slow'`:

- **Excludes** all `type: :feature` specs (Capybara / browser).
- **Excludes** examples tagged `:clean_repo` or `clean_repo: true` (Fedora persistence).
- **Excludes** examples tagged `js: true` (Selenium).
- **Excludes** a curated set of files and directories that touch Fedora or Solr (see `SLOW_SPEC_FILE_PATTERNS` in `spec/support/slow_spec_metadata.rb`).

**Includes** ~340 unit-style examples plus **~18 throwaway slop checks** in `spec/throwaway/` (mocked smoke tests for the slow tier).

Coverage is **off** for fast runs (`NO_COVERAGE=1`) to keep feedback quick. CircleCI still reports coverage on the full ~1,200+ example suite.

### Throwaway slop checks (`spec/throwaway/`)

Marked `throwaway: true` — **not run in CI**. Uses mocks for deposit forms, Solr, jobs, etc. that the fast tier skips.

- A green slop check is a weak signal only; a red one means “investigate or update the throwaway file.”
- See [spec/throwaway/README.md](../../spec/throwaway/README.md).

## Definition of done (modernization branch)

Before ending a work session on `scholar-modernization`:

1. **`bundle exec rubocop`** — no new offenses in changed files.
2. **`bin/rspec-fast`** — passes (or run targeted paths if your slice only touches certain specs).
3. **Push** when ready — CircleCI runs the **full** suite including `:slow` examples.

If you changed legacy Hyrax integration behavior (deposit, search, collections API, etc.), run the relevant slow specs locally or wait for CI and fix before merging.

## Adding new specs

| Spec type | Tag / location | Local runner |
|-----------|----------------|--------------|
| New `Scholar::` unit/service code | `spec/lib/scholar/` — no `:slow` | `bin/rspec-fast` |
| View/presenter with stubbed SolrDocument | No `:slow` | `bin/rspec-fast` |
| Feature / deposit / catalog flow | `type: :feature` or `:clean_repo` | CI (or full local stack) |
| Saves to Fedora in a non-feature file | Add a pattern to `SLOW_SPEC_FILE_PATTERNS` in `slow_spec_metadata.rb` | CI |

When in doubt, run `bin/rspec-fast path/to/your_spec.rb` locally. If it needs Fedora or Solr, add a pattern to `SLOW_SPEC_FILE_PATTERNS` so the default fast suite stays green without services.

## Legacy spec hygiene

Delete empty Hyrax generator placeholders (`skip "Add your tests here"`, `pending "add some examples..."`) rather than leaving them for later—coverage for those types lives in feature specs and shared controller/actor specs. Do not expand this into broad legacy spec refactors.

## Full suite locally (optional)

Use when debugging a CI failure or before a risky legacy change. Start Fedora and Solr per [README](../../README.md#running-tests-all-platforms), then:

```bash
RAILS_ENV=test bundle exec rake db:migrate
bundle exec rspec
```

Redis is not required for tests (`SCHOLAR_JOB_QUEUE_ADAPTER=:inline` in `.env.test`).

## CircleCI

The `.circleci/config.yml` job runs **parallel_rspec** with Fedora and Solr Docker sidecars—no `:slow` filter. A green CI build means the full suite passed.
