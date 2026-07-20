# GitHub Actions / CI notes (hyku-oob)

Team index: [docs/local/README.md](./README.md).

## Scholar@UC CI (`CI` workflow)

PRs and pushes to **`hyku-oob`** run [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml). This is the CircleCI-style path for feature work — not Hyku’s Docker image-publish pipeline.

| Job | What it does |
|-----|----------------|
| **RuboCop** | `bundle exec rubocop` (no Solr/Fedora) |
| **Brakeman and bundler-audit** | Security scans (no Solr/Fedora). Known Hyku OOB findings are baselined in [`config/brakeman.ignore`](../../config/brakeman.ignore); **new** Medium/High warnings still fail CI. |
| **RSpec (shards 0–5)** | Six parallel jobs; each starts Postgres, Redis, Solr, Fedora (and Chrome) via [`docker-compose.ci.yml`](../../docker-compose.ci.yml), then runs ~1/6 of the spec files |

Required checks for PRs into `hyku-oob` should be those jobs (lint, security, and all six RSpec shards). No release labels are required for these checks.

CI uses Actions + Docker **only on the runner**. Local macOS setup under `docs/local/` stays no-Docker.

Caching (to keep runs shorter): Bundler (`ruby/setup-ruby` bundler-cache), Yarn, RuboCop result cache, ruby-advisory-db for bundler-audit, apt wait-tools, and Docker service images from `docker-compose.ci.yml` (saved by shard 0, restored by all shards).

Making the full suite green is a follow-up; the workflow is wired first so failures are visible.

## PR label checker (`Verify` / “PR has required labels”)

Upstream Hyku requires release labels (`patch-ver`, `minor-ver`, `major-ver`, `ignore-for-release`, or `dependencies`) on PRs.

For Scholar@UC work we **do not** use that process on feature branches. `.github/workflows/verify_labels.yml` is limited to PRs whose **base branch is `main`**.

PRs into `hyku-oob` (or other non-`main` bases) should **not** need those labels.

If a Hyku merge resets that workflow to `branches: ['**']`, restore the `main`-only filter (see the comments in the workflow file).

## Hyku `build-test-lint` (do not use on this fork)

[`.github/workflows/build-test-lint.yaml`](../../.github/workflows/build-test-lint.yaml) builds and pushes multi-arch images to `ghcr.io/samvera/hyku`. On this fork every job is gated with `if: github.repository == 'samvera/hyku'`, so ordinary `hyku-oob` feature PRs do **not** run it.

After merging from Hyku, re-check that guard (and `verify_labels` triggers) if upstream restores broader behavior.
