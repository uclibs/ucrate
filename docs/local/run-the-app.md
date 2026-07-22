# Run the app (one-time DB setup)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

This page is database setup, optional sample works, and first sign-in.

Start Postgres, Redis, Fedora, Solr, and Sidekiq first — [start-services.md](./start-services.md) — and leave those terminals running. For tests, see [run-tests.md](./run-tests.md).

## Quick checks

Do not run `db:setup` while Solr is still downloading (watch the Solr terminal from [start-services.md](./start-services.md)).

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

### Solr (port 8983)

```bash
lsof -i :8983 | grep LISTEN
```

Expected: a line with `8983` and `LISTEN`. If empty, wait for Solr to finish starting, then check again.

### Fedora (port 8984)

```bash
lsof -i :8984 | grep LISTEN
```

Expected: a line with `8984` and `LISTEN`.

If any check fails, fix it on [start-services.md](./start-services.md), then return here.

## One-time database setup

Use `db:setup` on PostgreSQL (not the old MySQL flow from Scholar@UC `develop`).

From the **repo root** (`HYKU_CACHE_ROOT` uses `$PWD`):

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails db:setup
```

`db:setup` creates the database, loads the schema, and runs Hyku’s seed. Solr and Fedora must already be listening. `RUBYOPT` loads the local Redis shim (without it, seed can fail with `unknown keyword: :thread_safe`).

Expected: the command finishes without errors.

Hyku seed creates:

- Single-tenant account, default admin set, collection types, and Sipity workflows
- Enabled work types (Generic Work, and so on)
- Admin user from `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD`

It does **not** create repository works. An empty catalog after seed is normal. Sign in with `INITIAL_ADMIN_*` to deposit, or use the optional step below.

### Optional: UC sample works

After `db:setup`, this loads Scholar@UC-style sample users and public works onto Hyku’s existing models (`GenericWork`, `Image`, `Etd`):

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rake uc:seed:samples
```

Expected: a `RESULT: OK` banner at the end (ignore Hyrax/Blacklight boot warnings above it).

- First successful run prints the sample-account password and creates public works plus a **Complete Works** collection.
- Re-run after success: `RESULT: OK — ... already present (skipped)` — nothing changes.
- Wipe and recreate: `UC_SEED_FORCE=true`. Fewer bulk works: `UC_SEED_WORKS_PER_USER=3` (default `10`).

Develop-only types/fields (`Article`, `college`, …) are stored on Hyku models via `resource_type` and description text — not as separate UC work classes.

## Start or restart Rails (if needed)

Rails may already be up from [start-services.md](./start-services.md) Step 6. Restart it if you changed `.env.local.mac` after it started.

```bash
lsof -i :3000 | grep LISTEN
```

- No output → start Rails with the command below.
- Has `LISTEN` and env is already correct → go to [Open the app](#open-the-app).
- Has `LISTEN` but you just changed `.env.local.mac` → Ctrl+C in the Rails terminal, then start again:

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails server -b 0.0.0.0 -p 3000
```

Expected: Rails stays running in that terminal.

Optional check:

```bash
env | grep '^HYKU_CACHE_ROOT='
env | grep '^SOLR_HOST='
```

Expected: a path under `tmp/hyku_file_cache`, and `SOLR_HOST=localhost`.

## Open the app

Open **http://localhost:3000** and sign in with `INITIAL_ADMIN_*` from `.env.local.mac`.

| If you see… | Then… |
|-------------|--------|
| Pending migrations | Finish [database setup](#one-time-database-setup), reload |
| `Errno::EROFS` / mkdir `/app` | Set `HYKU_CACHE_ROOT` ([environment.md](./environment.md)), [restart Rails](#start-or-restart-rails-if-needed) |
| Page will not load | Check service terminals: Fedora → Solr → Redis → Sidekiq → Rails ([start-services.md](./start-services.md)) |

## Later days

You usually do not need `db:setup` again. Everyday restarts: [start-services.md](./start-services.md) only.

## Related

- [Start services](./start-services.md)
- [Run tests](./run-tests.md)
- [Troubleshooting](./troubleshooting.md)
- [Environment](./environment.md)
- [Versions and ports](./versions-and-ports.md)
