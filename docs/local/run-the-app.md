# Run the app (one-time DB setup)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

This page is **only** the one-time database setup/seeding step and how to sign in.

Do **not** start Postgres, Redis, Fedora, Solr, or Sidekiq here. Those commands live on [start-services.md](./start-services.md). Finish that page first (keep those terminals running), then come here.

For tests (different Solr/Fedora ports), see [run-tests.md](./run-tests.md).

## Quick checks (do this first)

Seeds talk to Solr and Fedora. Do **not** run `db:setup` / `db:seed` while Solr is still downloading (progress % in the Solr terminal from [start-services.md](./start-services.md)).

Run **one command at a time** in a free terminal. Match each reply to the Expected line under that command.

### Postgres

```bash
pg_isready -h localhost
```

Expected: `localhost:5432 - accepting connections`

### Redis

```bash
redis-cli ping
```

Expected: `PONG`

### Solr (dev port 8983)

```bash
lsof -i :8983 | grep LISTEN
```

Expected: at least one line that includes `8983` and `LISTEN` (for example `TCP *:8983 (LISTEN)`).

If this command prints nothing, Solr is not listening yet. Wait until the Solr terminal finishes downloading and stays running, then run the check again.

### Fedora (dev port 8984)

```bash
lsof -i :8984 | grep LISTEN
```

Expected: at least one line that includes `8984` and `LISTEN` (for example `TCP *:8984 (LISTEN)`).

If any check fails, go back to [start-services.md](./start-services.md). Do not re-copy startup commands onto this page.

## One-time database setup

If you are used to Scholar@UC `develop`: do not run the old MySQL-era setup sequence.
On this branch, use `db:setup` (or `db:migrate` + `db:seed`) against PostgreSQL.

Work from the **repo root** (so `$PWD` in `.env.local.mac` resolves correctly for `HYKU_CACHE_ROOT`):

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:setup
```

`db:setup` = create + schema + seed. Seeds need Solr and Fedora already listening. `RUBYOPT` loads the same Redis shim Sidekiq uses (without it, seed can fail with `unknown keyword: :thread_safe`).

Expected outcome: command completes without errors.

What seed creates (and does **not** create):

- Single-tenant account, default admin set, collection types, and Sipity **workflows** (permission/process definitions — not repository items)
- Work *types* enabled on the site (Generic Work, etc.) so you can deposit later
- Initial admin user from `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD`

It does **not** deposit sample works or files. An empty public homepage after a successful seed is normal. Sign in with the `INITIAL_ADMIN_*` values to deposit content.

If the database already exists:

```bash
RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:migrate
RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:seed
```

You do not need a separate Rails console step for the first admin user.

## Start or restart Rails (if needed)

Rails may already be running from [start-services.md](./start-services.md) Step 6. You still need a **restart** if you changed `.env.local.mac` after Rails started (for example after adding `HYKU_CACHE_ROOT` or `SOLR_*`).

Check whether something is listening on port **3000**:

```bash
lsof -i :3000 | grep LISTEN
```

- **No output:** Rails is not running. Start it (command below).
- **Has `LISTEN`:** If env is already correct, skip to [Open the app](#open-the-app). If you just updated `.env.local.mac`, stop Rails with Ctrl+C in its terminal, then start it again with the command below.

From the repo root:

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails server -b 0.0.0.0 -p 3000
```

Expected outcome: Rails boots and stays running in this terminal.

Confirm env was loaded (optional):

```bash
env | grep '^HYKU_CACHE_ROOT='
env | grep '^SOLR_HOST='
```

Expected: a path under your repo `tmp/hyku_file_cache`, and `SOLR_HOST=localhost`.

## Open the app

Open **http://localhost:3000**

Sign in with the `INITIAL_ADMIN_*` values from `.env.local.mac`.

If the page shows pending migrations, finish the [database setup](#one-time-database-setup) section above, then reload.

If you see `Errno::EROFS` / mkdir `/app`, Rails was started without `HYKU_CACHE_ROOT`. Fix `.env.local.mac` ([environment.md](./environment.md)), then [restart Rails](#start-or-restart-rails-if-needed).

If the page does not load, check the service terminals from [start-services.md](./start-services.md) in this order: Fedora, Solr, Redis, Sidekiq, Rails.

## Later days

You usually do **not** need `db:setup` again.

Everyday restarts: [start-services.md](./start-services.md) only. Stop with Ctrl+C in each terminal. Safe to leave brew-managed Postgres/Redis running.

## Related

- [Start services](./start-services.md)
- [Run tests](./run-tests.md)
- [Troubleshooting](./troubleshooting.md)
- [Environment](./environment.md)
- [Versions and ports](./versions-and-ports.md)
