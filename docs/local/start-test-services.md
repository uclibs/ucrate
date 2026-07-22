# Start Test Runtime Services

Back to setup index: [docs/local/README.md](./README.md)

Use this page when dependencies are already installed and you want to start local runtime services for running tests on `hyku-oob`.

This page is for the test environment (test ports), not dev ports.

Test services use different ports from development so you can run the app stack and test stack at the same time.

Need development services instead? Use [docs/local/start-services.md](./start-services.md).

Run each service in its own terminal tab/window so logs stay visible and each process keeps running.

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

If Redis is already running from `brew services`, stop it first:

```bash
brew services stop redis
```

Then this terminal can own port 6379.

Use the same Redis terminal process for both dev and test on this branch.

## 3) Start Fedora wrapper (test port 8986)

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)" && export PATH="$JAVA_HOME/bin:$PATH" && RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec fcrepo_wrapper -c config/fcrepo_wrapper_test.yml
```

## 4) Start Solr wrapper (test port 8985)

First start may download Solr if you have not already run the **dev** Solr wrapper (same zip cache in `tmp/solr-download`). The test instance lives under `tmp/solr-test`.

```bash
RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper --config config/solr_wrapper_test.yml
```

## 5) Optional: start Sidekiq

Most test runs do not require a separate worker process.

If you are running tests that depend on background jobs, start Sidekiq:

```bash
set -a && source .env.local.mac && set +a && DISABLE_REDIS_CLUSTER=true bundle exec sidekiq
```

## Quick checks

```bash
pg_isready -h localhost
redis-cli ping
lsof -i :8985 | grep LISTEN
lsof -i :8986 | grep LISTEN
```

Expected:

- Postgres check reports accepting connections.
- Redis check reports `PONG`.
- Solr test wrapper is listening on `8985`.
- Fedora test wrapper is listening on `8986`.

## Next

- Run tests: [docs/local/run-tests.md](./run-tests.md)
- Need to run the app instead: [docs/local/start-services.md](./start-services.md)