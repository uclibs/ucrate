# Scholar@UC customizations vs Hyku

**These notes are for the `hyku-oob` lineage.** Team index: [docs/local/README.md](./README.md).

This is the **canonical inventory** of what we changed relative to upstream Samvera Hyku. Use it when merging Hyku updates (`git merge hyku/main` or a Hyku tag) so you know what to **keep**, what will **conflict**, and what is safe to **take from upstream**.

Merge how-to: [updating-from-hyku.md](./updating-from-hyku.md).

Path list used by CI: [uc-hyku-customizations.manifest.yml](./uc-hyku-customizations.manifest.yml).

## How to keep this document honest

Full “auto-document every change with a good why” is not reliable in CI. Instead we enforce **registration**:

1. **Every UC path** that matches the watch list in the manifest must appear in that manifest (new file under `app/services/uc/`, new `config/*_compat.rb`, etc. → add a manifest entry **and** a short section here).
2. **CI fails** if the repo has watched files that are missing from the manifest, or if a PR changes a listed customization without also updating **this** markdown file (so the “why” cannot silently rot).
3. When you only edit prose under `docs/local/` that is not this inventory, you do **not** need to touch this file — the whole `docs/local/` tree is already one UC-owned customization.

See [github-actions.md](./github-actions.md) for the CI job name.

---

## Legend

| Merge risk | Meaning |
|------------|---------|
| **Keep** | UC-only (Hyku has no counterpart). Always keep ours. |
| **Conflict likely** | Hyku ships the file; we patched it. Expect a merge conflict — keep our behavior, take upstream improvements carefully. |
| **Safe overwrite** | Prefer Hyku’s version; re-check only if our docs assumed old upstream behavior. |

---

## 1. Local macOS docs and env

| Path | Risk | What / why |
|------|------|------------|
| `docs/local/**` | **Keep** | Scholar@UC source of truth for no-Docker Mac setup (services, DB seed, tests, troubleshooting). Upstream Hyku docs stay under `docs/*.md` and may change on merge — do not treat them as our local guide. |
| `.env.local.mac.example` | **Keep** | Committed template for personal `.env.local.mac` (localhost DB/Solr/Redis, Sidekiq queue, absolute `HYKU_CACHE_ROOT`, admin seed creds). Do **not** replace with Docker `.env`. |
| `.envrc` | **Keep** | direnv loads `.env.local.mac` in this clone only and unloads when you leave (multi-app safe). Setup: [dependencies/direnv.md](./dependencies/direnv.md). |
| `README.md` (top pointer only) | **Conflict likely** | Short Scholar@UC / `hyku-oob` blurb pointing at `docs/local/`. After a Hyku merge, **re-apply** that pointer if upstream wiped it; keep the rest of the Hyku README. |

**Conflicts / issues:** Developers who source Docker `.env` get wrong hosts (`solr`, `db`). `HYKU_CACHE_ROOT` must be an absolute path (see [environment.md](./environment.md)).

---

## 2. Local runtime shims (Solr / Fedora / Sidekiq)

| Path | Risk | What / why |
|------|------|------------|
| `config/sidekiq_redis_compat.rb` | **Keep** | Preload via `RUBYOPT=-r./config/sidekiq_redis_compat`. Strips legacy Redis `thread_safe:` so Sidekiq 7 / redis-client boot. Used for Rails, Sidekiq, `db:setup`, seeds. |
| `config/fcrepo_wrapper_compat.rb` | **Keep** | Preload for `solr_wrapper` / `fcrepo_wrapper`. Ruby 3.3 + rubyzip 3 fixes (e.g. `File.exists?`, zip extract) so wrappers run on modern Ruby. |
| `.solr_wrapper` | **Conflict likely** | Pins Solr **7.4.0**, port **8983**, download/install under `tmp/solr-download` and `tmp/solr-development` (avoids path/space issues and matches local docs). |
| `config/solr_wrapper_test.yml` | **Conflict likely** | Same download strategy for test Solr on **8985** / `tmp/solr-test`. |

**Not UC-patched (take Hyku):** `.fcrepo_wrapper`, `config/fcrepo_wrapper_test.yml` — docs still tell you to use the compat preload.

**Conflicts / issues:** Forgetting `RUBYOPT` → Sidekiq/`db:seed` fail with `unknown keyword: :thread_safe`, or Solr extract errors. Mixing dev ports (8983/8984) with test ports (8985/8986) causes confusing failures.

---

## 3. Security gems and baselines

| Path | Risk | What / why |
|------|------|------------|
| `Gemfile` / `Gemfile.lock` (`brakeman`, `bundler-audit`) | **Conflict likely** | Dev/test gems so CI can run security scans on this fork. |
| `config/brakeman.ignore` | **Keep** | Baselines **known** Hyku OOB findings so CI fails only on **new** Medium/High issues. |
| `.bundler-audit.yml` | **Keep** | Ignores advisories already present in the Hyku lockfile until upstream upgrades; new unignored advisories still fail CI. |

**Conflicts / issues:** Blindly deleting ignore entries will fail CI on legacy Hyku findings. After a Hyku gem bump, re-run scanners and shrink ignores when possible.

---

## 4. GitHub Actions / CI (this fork)

| Path | Risk | What / why |
|------|------|------------|
| `.github/workflows/ci.yml` | **Keep** | Scholar@UC CI on **`hyku-oob`**: RuboCop, Brakeman/bundler-audit, six RSpec shards, coverage gate, **UC customizations check**. Not Hyku’s image-publish pipeline. |
| `docker-compose.ci.yml` | **Keep** | Postgres/Redis/Solr/ZooKeeper/Fedora/Chrome for GHA shards only. Local Mac setup stays no-Docker. |
| `scripts/ci/coverage_gate.sh` | **Keep** | Compares merged SimpleCov % to baseline (0.5pt tolerance); PR ratchet can bump baseline. |
| `scripts/ci/merge_coverage.rb` | **Keep** | `SimpleCov.collate` across shard resultsets. |
| `scripts/ci/check_uc_customizations.rb` | **Keep** | Enforces this inventory + manifest (see above). |
| `lib/uc/hyku_customizations_inventory.rb` | **Keep** | Inventory check logic used by the CI script (and specs). |
| `coverage/coverage_baseline.txt` | **Keep** | Committed coverage floor for the gate. |
| `.github/workflows/verify_labels.yml` | **Conflict likely** | Restricted to PRs into **`main`** so feature PRs into `hyku-oob` do not need Hyku release labels. Restore if upstream resets to `branches: ['**']`. |
| `.github/workflows/build-test-lint.yaml` | **Conflict likely** | Jobs gated with `if: github.repository == 'samvera/hyku'` so this fork does not publish to `ghcr.io/samvera/hyku`. Re-apply guards after merge if lost. |

Details: [github-actions.md](./github-actions.md).

---

## 5. Spec / CI reliability patches (Hyku files we changed)

| Path | Risk | What / why |
|------|------|------------|
| `spec/rails_helper.rb` | **Conflict likely** | CI wait / animation / Selenium options / safer Capybara reset for Actions + remote Chrome. |
| `spec/features/appearance_theme_spec.rb` | **Conflict likely** | `xit` flaky theme saves under remote Capybara. |
| `spec/features/show_page_theme_spec.rb` | **Conflict likely** | same |
| `spec/features/community_theme_spec.rb` | **Conflict likely** | same |
| `spec/features/cultural_repository_theme_spec.rb` | **Conflict likely** | same |
| `spec/features/institutional_repository_theme_spec.rb` | **Conflict likely** | same |
| `spec/features/collection_type_spec.rb` | **Conflict likely** | `xit` flaky mid-redirect |
| `spec/models/featured_collection_list_spec.rb` | **Conflict likely** | `xit` flaky sort assumption |
| `yarn.lock` | **Conflict likely** | Lockfile refresh for Yarn 1 / local install; prefer regenerate carefully rather than hand-merging. |

**Conflicts / issues:** Re-enabling `xit` examples without fixing flake will burn CI time. Prefer upstream fixes when Hyku hardens these specs.

---

## 6. UC sample seeds (local demo data)

| Path | Risk | What / why |
|------|------|------------|
| `app/services/uc/sample_seed_service.rb` | **Keep** | Adapts Scholar@UC `develop` sample users/works onto Hyku OOB models (`GenericWork` / `Image` / `Etd`). Idempotent Fedora marker; uses `INITIAL_ADMIN_PASSWORD`; refuses production/staging; AF AdminSet + Sipity workflows. |
| `lib/tasks/uc_sample_seeds.rake` | **Keep** | `rake uc:seed:samples` with clear `RESULT: OK/FAILED` banners. |
| `spec/services/uc/sample_seed_service_spec.rb` | **Keep** | Fast stubbed coverage of UC-owned behavior. |
| `spec/tasks/uc_sample_seeds_rake_spec.rb` | **Keep** | Task output / error handling. |

**Not UC-owned:** `db/seeds/sample/**` (stock Hyku assets the service may use) — **safe overwrite**.

**Conflicts / issues:** Must run stock Hyku `db:setup` / `db:seed` first (tenant + workflows). Does not replace Hyku `db/seeds.rb`.

---

## 7. Cursor / agent rules

| Path | Risk | What / why |
|------|------|------------|
| `.cursor/rules/*.mdc` | **Keep** | Team agent guidance (docs voice, PR base branch `hyku-oob`, no push without ask, review passes, etc.). Hyku does not ship these. |

---

## 8. `.gitignore` UC hunks

| Path | Risk | What / why |
|------|------|------------|
| `.gitignore` | **Conflict likely** | Allows committing `.env.local.mac.example` and `coverage/coverage_baseline.txt`; ignores personal `.env.local.mac`, Yarn noise, `var/`, etc. |

---

## Quick merge checklist

After `git merge hyku/main` (or a Hyku tag):

1. Restore `README.md` Scholar@UC pointer if missing.
2. Confirm `verify_labels.yml` is **main-only** and `build-test-lint.yaml` still has the `samvera/hyku` repository guards.
3. Re-resolve `Gemfile` / lockfile; keep `brakeman` + `bundler-audit`; refresh ignore baselines if upstream fixed findings.
4. Keep `config/*_compat.rb`, `.envrc`, `.env.local.mac.example`, `docs/local/**`, `.github/workflows/ci.yml`, `docker-compose.ci.yml`, `scripts/ci/**`, `app/services/uc/**`.
5. Re-check `.solr_wrapper` / `config/solr_wrapper_test.yml` pins vs upstream.
6. Run `ruby scripts/ci/check_uc_customizations.rb` (and update this doc + manifest if you added or dropped customizations).
7. Skim upstream `docs/*.md` for new Hyku guidance; leave our procedures in `docs/local/` only.

---

## Related

- [Updating from Hyku](./updating-from-hyku.md)
- [GitHub Actions](./github-actions.md)
- [Environment / direnv](./environment.md)
- [Start services](./start-services.md)
