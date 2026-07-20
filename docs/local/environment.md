# Local environment variables

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

Copy the committed template to a **personal** file (gitignored). This does **not** overwrite the Docker `.env`.

```bash
cp .env.local.mac.example .env.local.mac
```

Edit `.env.local.mac` and set `DB_USER` from [install.md](./install.md) Step D (`whoami` / `psql -d postgres -c 'SELECT current_user;'`).

## Template

Also in [`.env.local.mac.example`](../../.env.local.mac.example):

```bash
# .env.local.mac — source this; do not use Docker hostnames
export HYKU_MULTITENANT=false
export DB_ADAPTER=postgresql
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=hyku
export DB_TEST_NAME=hyku_test
export DB_USER=YOUR_MAC_USERNAME_HERE   # from install.md Step D
export DB_PASSWORD=                     # usually empty on Homebrew Postgres
export REDIS_HOST=localhost
export REDIS_PORT=6379
# Leave SOLR_URL / FCREPO_HOST unset so config/*.yml use localhost defaults
# Jobs: omit HYRAX_ACTIVE_JOB_QUEUE to use Sidekiq (default)
export INITIAL_ADMIN_EMAIL=admin@example.com
export INITIAL_ADMIN_PASSWORD=testing123
export SECRET_KEY_BASE=dev-secret-change-me
export DISABLE_REDIS_CLUSTER=true
```

## Load it

In each terminal that runs Rails, Sidekiq, `db:setup`, or specs:

```bash
set -a && source .env.local.mac && set +a
```

> **Multitenancy:** Upstream Hyku often uses `*.localhost.direct` and Stack Car. Stay on `HYKU_MULTITENANT=false` until the single-tenant stack is solid.

**Do not** source the committed `.env` for local no-Docker runs — it uses Docker hostnames (`db`, `solr`, `redis`, `fcrepo`).

## Next

- [Run the app](./run-the-app.md)
- [Run tests](./run-tests.md)
