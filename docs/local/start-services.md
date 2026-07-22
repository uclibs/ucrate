# Start Runtime Services (everyday use)

Back to setup index: [docs/local/README.md](./README.md)

Use this page when dependencies are already installed and you want to start local runtime services for `hyku-oob`.

This page is for the development environment (dev ports), not test ports.

Need test services instead? Use [docs/local/start-test-services.md](./start-test-services.md).

Before starting services, confirm env is loaded in a terminal at your **ucrate clone root** (the directory with `Gemfile`). [direnv](./dependencies/direnv.md) must already be set up.

### Env check (do this first)

```
env | grep '^HYKU_ROOT_HOST='
env | grep '^HYRAX_ACTIVE_JOB_QUEUE='
env | grep '^SOLR_HOST='
env | grep '^SOLR_URL='
env | grep '^HYKU_CACHE_ROOT='
```

Expected:

```
HYKU_ROOT_HOST=localhost
HYRAX_ACTIVE_JOB_QUEUE=sidekiq
SOLR_HOST=localhost
SOLR_URL=http://127.0.0.1:8983/solr/
```

Plus a `HYKU_CACHE_ROOT=` line with the **same full path** you set in [environment.md](./environment.md) (also confirmed under [direnv](./dependencies/direnv.md)). It must start with `/` and end with `/tmp/hyku_file_cache` — not a placeholder and not `$PWD`.

- **No output / vars missing:** direnv is not loading the file — finish [direnv](./dependencies/direnv.md) (`direnv allow`, zsh hook), then hit Enter or open a new terminal in the clone and re-check.
- **Wrong `SOLR_*` or other `HYKU_*` values** (Docker hostname `solr`, etc.): fix `.env.local.mac` in [environment.md](./environment.md), hit Enter so direnv reloads, then re-check.
- **Wrong cache path:** fix `HYKU_CACHE_ROOT` in [environment.md](./environment.md), hit Enter so direnv reloads, then re-check.

Do not continue until this check looks right. You will run each service below from the clone root with env loaded (direnv).

## 1) Start PostgreSQL

PostgreSQL may already be running from earlier setup.

Check status first:

```
brew services list | grep -i postgres
```

If your Postgres service is not `started`:

```
brew services start postgresql@16
```

If your Mac uses a different Postgres formula, start that version instead.

If it was running but you stopped it, start it again with the same command.

## 2) Start Redis

From a new terminal, run:

```
redis-server
```

Use the same Redis terminal process for both dev and test on this branch. If you have already started it for test, you don't need to start it a second time for dev.

## 3) Start Fedora wrapper

From a new terminal, run:

```
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" && export PATH="$JAVA_HOME/bin:$PATH" && RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec fcrepo_wrapper -p 8984
```

## 4) Start Solr wrapper

First start on a machine may take several minutes (downloads Solr **7.4.0** into `tmp/solr-download` and installs it under `tmp/solr-development`). Later starts reuse that install and should be much faster.

From a new terminal, run:

```
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper
```

This reads `.solr_wrapper` (port **8983**, collection `hydra-development`, config under `solr/conf/`).

You can continue to Step 5 (Sidekiq) while Solr is still downloading. Sidekiq only needs Redis and your env file to start. Wait for Solr to finish and listen on port **8983** before database seeding on the next page.

## 5) Start Sidekiq

From a new terminal, run:

```
DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec sidekiq
```

`RUBYOPT` loads a small local shim that strips a legacy Redis option Hyku still passes (`thread_safe`). Without it, Sidekiq 7 exits with `unknown keyword: :thread_safe`.

If Sidekiq fails with `no implicit conversion of nil into String` from `config/environments/development.rb`, your `.env.local.mac` is missing `HYKU_ROOT_HOST`.

Sidekiq does not use a separate app port here.

It connects to Redis (`REDIS_HOST`/`REDIS_PORT`), and this branch uses the same Redis service for dev and test.

## 6) Start Rails server (port 3000)

From a new terminal, run:

```
DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec rails server -b 0.0.0.0 -p 3000
```

Expected outcome: Rails boots and stays running in this terminal.

`RUBYOPT` is the same Redis shim as Sidekiq. Rails enqueues jobs through Sidekiq’s Redis client, so it needs the shim too.

If you change `.env.local.mac` later (Solr URL, cache root, etc.), stop Rails with Ctrl+C and run this Step 6 command again so the new env is loaded.

## Next

Keep the terminals from this page running.

- **First time on this branch:** go to [run-the-app.md](./run-the-app.md) for quick checks and one-time DB setup/seeding. Do not open the browser yet — http://localhost:3000 usually shows a pending-migrations error until seeding finishes.
- **Already set up this branch locally:** open http://localhost:3000.
