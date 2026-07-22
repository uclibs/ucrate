# Run the app (one-time DB setup)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

This page is **only** the one-time database setup/seeding step and how to sign in.

Do **not** start Postgres, Redis, Fedora, Solr, Sidekiq, or Rails here. Those commands live on [start-services.md](./start-services.md). Finish that page first (keep those terminals running), then come here.

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

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:setup
```

`db:setup` = create + schema + seed. Seeds need Solr and Fedora already listening. `RUBYOPT` loads the same Redis shim Sidekiq uses (without it, seed can fail with `unknown keyword: :thread_safe`).

Expected outcome: command completes without errors and seeds create initial records.

If the database already exists:

```bash
RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:migrate
RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:seed
```

With `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD` set in `.env.local.mac`, seed creates a superadmin. You do not need a separate Rails console step for the first admin user.

Expected outcome: no migration or seed errors.

## Open the app

Rails and Sidekiq should already be running from [start-services.md](./start-services.md) (Steps 5–6).

Open **http://localhost:3000**

Sign in with the `INITIAL_ADMIN_*` values from `.env.local.mac`.

If the page shows pending migrations, finish the database setup section above, then reload. If Rails was not started yet, start it from [start-services.md](./start-services.md) Step 6.

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
