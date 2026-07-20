# Run tests locally (optional)

**These instructions are for `hyku-oob` only.** Team index: [docs/local/README.md](./README.md).

You do **not** need to run the full suite for every change. A complete local run needs Solr + Fedora on **test** ports and can take a **long time** (often on the order of an hour). Prefer CI for routine full runs; use this guide when you specifically want to exercise specs on your Mac.

## Prerequisites

- [Install dependencies](./install.md) (Ruby, gems, Java 8)
- Postgres running with `hyku_test` created ([install.md](./install.md) Step E)
- Redis running
- [`.env.local.mac` sourced](./environment.md) (`DB_TEST_NAME=hyku_test`, etc.)
- Port reference: [versions-and-ports.md](./versions-and-ports.md) (test: Solr **8985**, Fedora **8986**)

Keep **development** wrappers (8983/8984) separate from **test** wrappers (8985/8986). Mixing them causes confusing failures.

## Option A — Recommended: `rake ci` (auto-starts test Solr + Fedora)

This matches the repo’s non-Docker default (`Rakefile` → `with_server 'test'`). It starts Solr/Fedora using the **test** wrapper configs, then runs the specs.

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"

# First time (or after schema changes):
RAILS_ENV=test bundle exec rails db:prepare

bundle exec rake ci
```

What `rake ci` uses:

| Service | Port | Config |
|---------|------|--------|
| Solr | **8985** | `config/solr_wrapper_test.yml` (Solr 7.4.0, `hydra-test`) |
| Fedora | **8986** | `config/fcrepo_wrapper_test.yml` |

`bundle exec rake` (with no args, outside Docker) runs RuboCop then `ci`.

### RuboCop only (no Solr/Fedora; much faster)

```bash
bundle exec rubocop
```

## Option B — Manual test wrappers (like the old `develop` flow)

Use this if you want wrappers left running across multiple spec invocations.

**Ports differ from `develop`:** Fedora test is **8986** here (not develop’s **8080**). Solr test stays **8985**.

### Terminal 1 — Fedora (test, 8986)

```bash
cd /path/to/ucrate
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper -c config/fcrepo_wrapper_test.yml
```

### Terminal 2 — Solr (test, 8985)

```bash
cd /path/to/ucrate
bundle exec solr_wrapper -c config/solr_wrapper_test.yml
```

### Terminal 3 — Redis

Skip if `brew services` already runs it:

```bash
redis-server
```

### Terminal 4 — Specs

```bash
cd /path/to/ucrate
set -a && source .env.local.mac && set +a

RAILS_ENV=test bundle exec rails db:prepare

# Full suite:
bundle exec rspec
# or: bundle exec rake spec

# Targeted (much faster when you only care about one area):
bundle exec rspec spec/path/to/some_spec.rb
```

## Notes

- Do not source the Docker `.env` for local tests (wrong hostnames).
- If ports are busy, stop old wrappers: `lsof -i :8985` / `lsof -i :8986`.
- Upstream CI also runs specs in Docker/GitLab — see `.gitlab-ci.yml` and [getting-started.md](../getting-started.md).

## Related

- [Run the app](./run-the-app.md)
- [Troubleshooting](./troubleshooting.md)
