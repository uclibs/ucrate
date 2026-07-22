# Start Runtime Services (everyday use)

Back to setup index: [docs/local/README.md](./README.md)

Use this page when dependencies are already installed and you want to start local runtime services for `hyku-oob`.

This page is for the development environment (dev ports), not test ports.

Need test services instead? Use [docs/local/start-test-services.md](./start-test-services.md).

Run each service in its own terminal tab/window so logs stay visible and each process keeps running.

Before Sidekiq (Step 5) and Rails (Step 6), you must have already created `.env.local.mac` from `.env.local.mac.example` — see [environment.md](./environment.md). That template includes `HYKU_ROOT_HOST=localhost` and `HYRAX_ACTIVE_JOB_QUEUE=sidekiq`.

Quick check in the terminal where you will run the worker or Rails:

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

If either line is missing, fix `.env.local.mac` using [environment.md](./environment.md) before continuing.

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

First start on a machine may take several minutes (downloads Solr **7.4.0** into `tmp/solr-download` and installs it under `tmp/solr-development`). Later starts reuse that install and should be much faster.

```bash
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper
```

This reads `.solr_wrapper` (port **8983**, collection `hydra-development`, config under `solr/conf/`).

You can continue to Step 5 (Sidekiq) while Solr is still downloading. Sidekiq only needs Redis and your env file to start. Wait for Solr to finish and listen on port **8983** before database seeding on the next page.

## 5) Start Sidekiq

```bash
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec sidekiq
```

`RUBYOPT` loads a small local shim that strips a legacy Redis option Hyku still passes (`thread_safe`). Without it, Sidekiq 7 exits with `unknown keyword: :thread_safe`.

If Sidekiq fails with `no implicit conversion of nil into String` from `config/environments/development.rb`, your `.env.local.mac` is missing `HYKU_ROOT_HOST`.

Sidekiq does not use a separate app port here.

It connects to Redis (`REDIS_HOST`/`REDIS_PORT`), and this branch uses the same Redis service for dev and test.

## 6) Start Rails server (port 3000)

```bash
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails server -b 0.0.0.0 -p 3000
```

Expected outcome: Rails boots and stays running in this terminal.

`RUBYOPT` is the same Redis shim as Sidekiq. Rails enqueues jobs through Sidekiq’s Redis client, so it needs the shim too.

## Next

Keep the terminals from this page running.

- **First time on this branch:** go to [run-the-app.md](./run-the-app.md) for quick checks and one-time DB setup/seeding. Do not open the browser yet — http://localhost:3000 usually shows a pending-migrations error until seeding finishes.
- **Already set up this branch locally:** open http://localhost:3000.
