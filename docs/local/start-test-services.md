# Start Test Runtime Services

Back to setup index: [docs/local/README.md](./README.md)

Use this page when dependencies are already installed and you want to start local runtime services for running tests on `hyku-oob`.

This page is for the **test** environment (test ports), not the development ports used in [start-services.md](./start-services.md).

| Service | Dev (start-services) | Test (this page) |
|---------|----------------------|------------------|
| Solr | **8983** | **8985** |
| Fedora | **8984** | **8986** |
| Redis | 6379 (shared) | 6379 (shared) |
| Postgres | same server; DB `hyku` | same server; DB `hyku_test` |

You can run the app stack and the test stack at the same time because Solr and Fedora use different ports. Do **not** point tests at the development Solr/Fedora ports.

Need development services instead? Use [start-services.md](./start-services.md).

Before optional Sidekiq (Step 5), confirm env is loaded from the **ucrate clone root** ([direnv](./dependencies/direnv.md)):

```
env | grep '^HYKU_ROOT_HOST='
env | grep '^HYRAX_ACTIVE_JOB_QUEUE='
```

Expected:

```
HYKU_ROOT_HOST=localhost
HYRAX_ACTIVE_JOB_QUEUE=sidekiq
```

- **No output:** finish [direnv](./dependencies/direnv.md), then re-check.
- **Wrong values:** fix `.env.local.mac` in [environment.md](./environment.md), hit Enter so direnv reloads, then re-check.

Most people use `rake ci` on [run-tests.md](./run-tests.md) (it can start test Solr/Fedora for you). Use **this** page when you want test wrappers left running across multiple spec invocations.

Run each service in its own terminal tab/window so logs stay visible and each process keeps running. Run the commands on this page from your **ucrate clone root** (the directory with `Gemfile`) unless noted.

## 1) Start PostgreSQL

PostgreSQL may already be running from earlier setup or from [start-services.md](./start-services.md). Dev and test share the same Postgres server (different database names).

If Postgres is already accepting connections, skip this step:

```
pg_isready -h localhost
```

Otherwise check Homebrew status:

```
brew services list | grep -i postgres
```

If your Postgres service is not `started`, start it:

```
brew services start postgresql@16
```

If your Mac uses a different Postgres formula, start that version instead.

## 2) Start Redis

Dev and test share the same Redis on port **6379**.

If you already started Redis for the development environment ([start-services.md](./start-services.md)), **do not start it again** for test. Skip this step.

If Redis is not running yet:

```
redis-server
```

If Homebrew’s Redis service already owns port 6379 and you prefer a foreground `redis-server` in this terminal, stop the service first:

```
brew services stop redis
```

Then run `redis-server` as above.

## 3) Start Fedora wrapper (test port 8986)

This is a **separate** process from the development Fedora on **8984**. Start it even if dev Fedora is already running.

```
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" && export PATH="$JAVA_HOME/bin:$PATH" && RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec fcrepo_wrapper -c config/fcrepo_wrapper_test.yml
```

Expected outcome: Fedora listens on port **8986** (not **8984**).

## 4) Start Solr wrapper (test port 8985)

This is a **separate** process from the development Solr on **8983**. Start it even if dev Solr is already running.

First start may download Solr if you have not already run the **dev** Solr wrapper (same zip cache in `tmp/solr-download`). The test instance lives under `tmp/solr-test`.

```
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper --config config/solr_wrapper_test.yml
```

This reads `config/solr_wrapper_test.yml` (port **8985**, collection `hydra-test`, config under `solr/conf/`).

You can continue to Step 5 (optional Sidekiq) while Solr is still downloading. Wait for Solr to finish and listen on port **8985** before running specs.

## 5) Optional: start Sidekiq

Most test runs do not require a separate worker process.

If you are running tests that depend on background jobs, start Sidekiq:

```
DISABLE_REDIS_CLUSTER=true RUBYOPT="-r./config/sidekiq_redis_compat" bundle exec sidekiq
```

`RUBYOPT` loads a small local shim that strips a legacy Redis option Hyku still passes (`thread_safe`). Without it, Sidekiq 7 exits with `unknown keyword: :thread_safe`.

If Sidekiq fails with `no implicit conversion of nil into String` from `config/environments/development.rb`, your `.env.local.mac` is missing `HYKU_ROOT_HOST`.

Sidekiq does not use a separate app port here. It uses the same Redis service for both dev and test.

## Next

Keep the terminals from this page running, then go to [run-tests.md](./run-tests.md). That page starts with quick checks for the **test** ports, then how to run specs.

Need the app stack instead? Use [start-services.md](./start-services.md).
