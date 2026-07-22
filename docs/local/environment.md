# Local environment variables

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

## What this file is for

Hyku ships a Docker-oriented `.env`. For **local macOS without Docker**, we use a separate personal file instead:

| File | In git? | Purpose |
|------|---------|---------|
| `.env.local.mac.example` ([open in repo](../../.env.local.mac.example)) | Yes (committed template) | Shared starting point for the team |
| `.env.local.mac` | No (gitignored) | **Your** copy — edit this on your machine |

You create `.env.local.mac` once, then `source` it in every terminal that runs Rails, Sidekiq, database setup, or specs.

## Create your personal env file

Copy the committed template to a **personal** file. This does **not** overwrite the Docker `.env`.

```bash
cp .env.local.mac.example .env.local.mac
```

Edit `.env.local.mac` and leave `DB_USER=YOUR_MAC_USERNAME_HERE` in place for now. We set the real value later in [dependencies/02-postgresql.md](./dependencies/02-postgresql.md) (`whoami` / `psql -d postgres -c 'SELECT current_user;'`).

## Required for Sidekiq and Rails (already in the template)

The template already includes these two lines. Keep them in your `.env.local.mac` — Sidekiq and Rails need them on this branch:

```bash
export HYKU_ROOT_HOST=localhost
export HYRAX_ACTIVE_JOB_QUEUE=sidekiq
```

- `HYKU_ROOT_HOST=localhost` — required so the app knows its host in single-tenant local mode.
- `HYRAX_ACTIVE_JOB_QUEUE=sidekiq` — use Sidekiq for background jobs (not Docker’s Good Job setup).

If you copied an older template and these lines are missing, add them now (or re-copy from `.env.local.mac.example` and re-apply your `DB_USER`).

## Template

Also in `.env.local.mac.example` ([open in repo](../../.env.local.mac.example)):

```bash
# .env.local.mac — source this; do not use Docker hostnames
export HYKU_MULTITENANT=false
export HYKU_ROOT_HOST=localhost
export DB_ADAPTER=postgresql
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=hyku
export DB_TEST_NAME=hyku_test
export DB_USER=YOUR_MAC_USERNAME_HERE   # from dependencies/02-postgresql.md
export DB_PASSWORD=                     # usually empty on Homebrew Postgres
export REDIS_HOST=localhost
export REDIS_PORT=6379
# Leave SOLR_URL / FCREPO_HOST unset so config/*.yml use localhost defaults
# Jobs: use Sidekiq for local no-Docker setup
export HYRAX_ACTIVE_JOB_QUEUE=sidekiq
# Used by `rails db:setup` / `rails db:seed` to create the first admin user:
export INITIAL_ADMIN_EMAIL=admin@example.com
export INITIAL_ADMIN_PASSWORD=testing123
export SECRET_KEY_BASE=dev-secret-change-me
export DISABLE_REDIS_CLUSTER=true
```

You will source `.env.local.mac` later in the runtime docs, in the terminals that run Rails, Sidekiq, `db:setup`, or specs.

> **Multitenancy:** Upstream Hyku often uses `*.localhost.direct` and Stack Car. Stay on `HYKU_MULTITENANT=false` until the single-tenant stack is solid.

**Do not** source the committed `.env` for local no-Docker runs — it uses Docker hostnames (`db`, `solr`, `redis`, `fcrepo`).

## Next

- [Run the app](./run-the-app.md)
- [Run tests](./run-tests.md)
