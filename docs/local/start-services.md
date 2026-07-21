# Start Runtime Services (everyday use)

Back to setup index: [docs/local/README.md](./README.md)

Use this page when dependencies are already installed and you want to start local runtime services for `hyku-oob`.

This page is for the development environment (dev ports), not test ports.

Need test services instead? Use [docs/local/start-test-services.md](./start-test-services.md).

Run each service in its own terminal tab/window so logs stay visible and each process keeps running.

First-time setup: after this page, continue to one-time DB setup/seeding in `run-the-app.md`.

Returning setup: if DB is already set up, you can stop after Step 6 and open the app.

Run these from `/path/to/ucrate` unless noted.

## 1) Start PostgreSQL

PostgreSQL may already be running from earlier setup.

Check status first:

```bash
brew services list | grep -i postgres
```

If your Postgres service is not `started`, start it:

```bash
brew services start postgresql@16
```

If your Mac uses a different Postgres formula, start that version instead.

If it was running but you stopped it, start it again with the same command.

## 2) Start Redis

```bash
redis-server
```
Use the same Redis terminal process for both dev and test on this branch.  If you have already started it for test, you don't need to start it a second time for dev.

## 3) Start Fedora wrapper

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" && export PATH="$JAVA_HOME/bin:$PATH" && RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec fcrepo_wrapper -p 8984
```

## 4) Start Solr wrapper

```bash
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper --version 7.4.0 -p 8983
```

## 5) Start Sidekiq

```bash
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
```

Sidekiq does not use a separate app port here.

It connects to Redis (`REDIS_HOST`/`REDIS_PORT`), and this branch uses the same Redis service for dev and test.

## 6) Start Rails server (port 3000)

```bash
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true bundle exec rails server -b 0.0.0.0 -p 3000
```

Open: http://localhost:3000

## Quick checks

```bash
pg_isready -h localhost
redis-cli ping
lsof -i :8983 | grep LISTEN
lsof -i :8984 | grep LISTEN
```

Expected:

- Postgres check reports accepting connections.
- Redis check reports `PONG`.
- Solr is listening on `8983`.
- Fedora is listening on `8984`.

## Next

- First-time on this branch: continue to [docs/local/run-the-app.md](./run-the-app.md) for one-time DB setup/seeding.
- Returning user: open `http://localhost:3000` after Step 6.
