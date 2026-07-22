# Run the app locally (no Docker)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

Prerequisites:

- Dependency setup complete (see [docs/local/dependencies](./dependencies))
- [Environment variables](./environment.md)
- Port reference: [versions-and-ports.md](./versions-and-ports.md) (dev: Solr **8983**, Fedora **8984**)

For tests, see [run-tests.md](./run-tests.md) (different ports).

Stay in the project directory. Use **foreground** processes (do not append `&`) so logs are visible. Solr paths must not contain spaces.

## Before you start terminals

1. Open 5 terminal tabs/windows and keep them open while developing.
2. In every terminal, run `cd /path/to/ucrate` first.
3. In terminals that run Rails, Sidekiq, or database tasks, load env vars:

	```bash
	set -a && source .env.local.mac && set +a
	```

4. If a command fails, stop and check [troubleshooting.md](./troubleshooting.md) before moving on.

## Supporting services

### Terminal A — Fedora (port 8984)

```bash
cd /path/to/ucrate
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec fcrepo_wrapper   # reads .fcrepo_wrapper → port 8984
```

First run downloads Fedora **4.7.3**. Wait until it is listening.

Expected outcome: terminal logs indicate Fedora started and is listening on port 8984.

### Terminal B — Solr (port 8983)

```bash
cd /path/to/ucrate
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper
```

Reads `.solr_wrapper` (Solr **7.4.0**, collection `hydra-development`, config under `solr/conf/`). First run on a machine downloads into `tmp/solr-download` and may take several minutes; later runs reuse `tmp/solr-development`. [Open the Solr wrapper config](../../.solr_wrapper).

Expected outcome: Solr starts with development config and stays running in the terminal.

### Terminal C — Redis (port 6379)

```bash
redis-server
```

If Redis is already running from `brew services`, stop it first:

```bash
brew services stop redis
```

Then this terminal can own port 6379.

Expected outcome: `PONG`

### Postgres

Use whatever Postgres you already run from [dependencies/02-postgresql.md](./dependencies/02-postgresql.md). Confirm before Rails setup:

```bash
pg_isready -h localhost
psql -d hyku -c 'SELECT current_user;'
```

Do not start a second Postgres if something is already accepting connections on port 5432.

Expected outcomes:

- `pg_isready` reports accepting connections
- `SELECT current_user;` returns a username

## One-time app setup

This section is the seed/admin setup point for `hyku-oob`.

If you are used to `develop`: do not run the old MySQL-era setup sequence.
On this branch, use `db:setup` (or `db:migrate` + `db:seed`) against PostgreSQL.

With Fedora, Solr, Redis, and Postgres up:

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

bundle exec rails db:setup
# db:setup = create + schema + seed (needs Solr + Fedora running for seeds)
```

Expected outcome: command completes without errors and seeds create initial records.

If the DB already exists:

```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

With `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD` set, seed creates a superadmin.

You do not need a separate Rails console step to create the first admin user.

Expected outcome: no migration or seed errors.

## Start the app and worker

Before starting the worker and Rails, confirm `.env.local.mac` was created from the template ([environment.md](./environment.md)) and that these are loaded:

```bash
set -a && source .env.local.mac && set +a
env | grep '^HYKU_ROOT_HOST='
env | grep '^HYRAX_ACTIVE_JOB_QUEUE='
```

Expected:

```bash
HYKU_ROOT_HOST=localhost
HYRAX_ACTIVE_JOB_QUEUE=sidekiq
```

If either line is missing, fix `.env.local.mac` using [environment.md](./environment.md), then source again.

### Terminal D — Sidekiq

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
```

Expected outcome: Sidekiq boots and waits for jobs.

### Terminal E — Rails

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0 -p 3000
```

Expected outcome: Rails boots and listens on port 3000.

Open **http://localhost:3000**

Sign in with the `INITIAL_ADMIN_*` values from `.env.local.mac`.

If the page does not load, check logs in Terminal A through E in this order: Fedora, Solr, Redis, Sidekiq, Rails.

## Fast restart (after first setup)

For normal day-to-day work, you usually do not need `db:setup` again.

Use [start-services.md](./start-services.md) for the exact runtime startup commands and order.

## Everyday restart order

Single source for runtime startup commands:

- [start-services.md](./start-services.md)

Stop with Ctrl+C in each terminal. Safe to leave brew-managed Postgres/Redis running.

## Related

- [Run tests](./run-tests.md)
- [Troubleshooting](./troubleshooting.md)
