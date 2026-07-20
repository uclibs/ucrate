# Run the app locally (no Docker)

**These instructions are for `hyku-oob` only.** See the [main README](../README.md).

Prerequisites:

- [Install dependencies](./install.md)
- [Environment variables](./environment.md)
- Port reference: [versions-and-ports.md](./versions-and-ports.md) (dev: Solr **8983**, Fedora **8984**)

For tests, see [run-tests.md](./run-tests.md) (different ports).

Stay in the project directory. Use **foreground** processes (do not append `&`) so logs are visible. Solr paths must not contain spaces.

## Supporting services

### Terminal A — Fedora (port 8984)

```bash
cd /path/to/ucrate
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper   # reads .fcrepo_wrapper → port 8984
```

First run downloads Fedora **4.7.3**. Wait until it is listening.

### Terminal B — Solr (port 8983)

```bash
cd /path/to/ucrate
# Pin 7.4.0 to match config/solr_wrapper_test.yml (avoids "latest" surprises)
bundle exec solr_wrapper --version 7.4.0
```

Uses `.solr_wrapper` (collection `hydra-development`, config under `solr/conf/`). First run downloads Solr.

### Terminal C — Redis (port 6379)

If not using `brew services`:

```bash
redis-server
```

If using Homebrew services, skip this terminal and confirm with:

```bash
redis-cli ping    # PONG
```

### Postgres

Use whatever Postgres you already run from [install.md](./install.md). Confirm before Rails setup:

```bash
pg_isready -h localhost
psql -d hyku -c 'SELECT current_user;'
```

Do not start a second Postgres if something is already accepting connections on port 5432.

## One-time app setup

With Fedora, Solr, Redis, and Postgres up:

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

bundle exec rails db:setup
# db:setup = create + schema + seed (needs Solr + Fedora running for seeds)
```

If the DB already exists:

```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

With `INITIAL_ADMIN_EMAIL` / `INITIAL_ADMIN_PASSWORD` set, seed creates a superadmin.

## Start the app and worker

### Terminal D — Sidekiq

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
```

### Terminal E — Rails

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a
DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0 -p 3000
```

Open **http://localhost:3000**

Sign in with the `INITIAL_ADMIN_*` values from `.env.local.mac`.

## Everyday restart order

1. Postgres + Redis (`brew services` or terminals)
2. `fcrepo_wrapper` (Java 8) — port **8984**
3. `solr_wrapper --version 7.4.0` — port **8983**
4. `sidekiq`
5. `rails server`

Stop with Ctrl+C in each terminal. Safe to leave brew-managed Postgres/Redis running.

## Related

- [Run tests](./run-tests.md)
- [Troubleshooting](./troubleshooting.md)
