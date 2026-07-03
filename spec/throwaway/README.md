# Throwaway specs (`spec/throwaway/`)

**Not real tests.** These files use mocks and shortcuts to smoke-check areas that
`bin/rspec-fast` skips (forms, deposit, Solr, jobs, etc.).

- They run **only** with `bin/rspec-fast` (via `SCHOLAR_FAST_SPECS=1`).
- CircleCI and `bundle exec rspec` **exclude** them (`throwaway: true`).
- A failure here means “something in the slow tier *might* be broken”—confirm in CI.
- When a slop check becomes stale or annoying, **delete or rewrite it** without guilt.

See [TESTING.md](../../docs/upgrade/TESTING.md).
