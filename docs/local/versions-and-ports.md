# Versions and ports (hyku-oob, no Docker)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

## How to use this page

This page is a reference, not an action step.

- You are not expected to memorize these values.
- You do not install anything from this page.
- You use this table while working through [docs/local/dependencies](./dependencies) in order.
- If your machine differs, fix only what is missing using the matching dependency page.

## Service versions

| Service | Target for local (no Docker) | Where that comes from |
|---|---|---|
| **Ruby** | 3.3.x (3.3+ OK; Rails 7.2) | [getting-started.md](../getting-started.md); Hyrax base image uses Ruby 3.3 |
| **Bundler** | 2.6.x | `BUNDLED WITH` at the bottom of `Gemfile.lock` |
| **PostgreSQL** | 14+ (11+ OK) | Hyku uses the `pg` gem / Apartment; Docker pin is `postgres:11.1` |
| **Redis** | 6.2+ (7.x fine) | Sidekiq 7 needs Redis ≥ 6.2 (`Gemfile` comment) |
| **Solr (dev)** | **7.4.0** via `solr_wrapper` on port **8983** | `.solr_wrapper` (download once to `tmp/solr-download`, install under `tmp/solr-development`) |
| **Solr (test)** | **7.4.0** on port **8985** | `config/solr_wrapper_test.yml` (`tmp/solr-test`; same download cache) |
| **Fedora (dev)** | **4.7.3** via `fcrepo_wrapper` on port **8984** | `.fcrepo_wrapper`; Docker uses `fcrepo4:4.7.5` |
| **Fedora (test)** | **4.7.3** on port **8986** | `config/fcrepo_wrapper_test.yml` (not develop’s old test port **8080**) |
| **Java** | **8** (Temurin 8) for Fedora wrapper | Same constraint as older Hyrax/Fedora 4 stacks |
| **Node / Yarn** | Node 20.x LTS and Yarn 1.x (Classic) required for this branch | Universal Viewer / `yarn install` (`package.json`); lockfile is v1 |
| **ImageMagick, LibreOffice** | Current Homebrew | Derivatives / office conversion |

**Do not trust Homebrew’s `solr` formula for this app.** Use `RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper` so the app gets Solr **7.4.0** and config under `solr/conf/`. The wrapper stores the zip under `tmp/solr-download` so later starts do not re-download.

**Do not source the committed `.env` as-is for local runs.** That file is aimed at Docker Compose (`DB_HOST=db`, `SOLR_HOST=solr`, etc.). Rails does **not** auto-load `.env` outside Docker. See [environment.md](./environment.md).

## Dev vs test ports (do not mix)

| | Development (run the app) | Test (run specs) |
|---|---|---|
| Solr | **8983** / `hydra-development` | **8985** / `hydra-test` |
| Fedora | **8984** | **8986** |
| Redis | 6379 | 6379 |
| Postgres DB | `hyku` | `hyku_test` |

You can run the app stack and the test stack at the same time because the ports differ. Do **not** point the test suite at the development Solr/Fedora ports.

## Next

- [Start dependency setup](./dependencies/homebrew.md)
