# PostgreSQL

Back to setup index: [docs/local/README.md](../README.md)

`hyku-oob` uses PostgreSQL.

For local setup on this branch, PostgreSQL **14 or newer** is acceptable.

- If you already have 14/15/16/17, keep it.
- You do not need to force-upgrade to 16.

## Step-by-step check and install

### Step 1: check for `psql`

```
which psql
```

If output includes a path (example: `/opt/homebrew/bin/psql`): go to **Step 3**.

If output is empty or says `psql not found`: go to **Step 2**.


### Step 2: check whether Postgres is installed but not on PATH

```
brew list --versions | egrep '^postgresql(@| )' || true
```

If this command prints any `postgresql@...` line, Postgres is already installed.

- Do not install a second copy.
- First, try `which psql` again in a new terminal window.
- If `psql` is still not found, add a permanent PATH entry in `~/.zshrc`.


Example permanent PATH entry for `postgresql@16`:

```
echo 'export PATH="$(brew --prefix postgresql@16)/bin:$PATH"' >> ~/.zshrc
```

Then run:

```
source ~/.zshrc
```

Now re-check:

```
which psql
psql --version
```

If `psql` now works, go to **Step 3**.

If brew list is empty (nothing printed), Postgres is missing. Install it in **Step 2A**.


#### Step 2A: install Postgres (only if missing)

```
brew install postgresql@16
```

```
psql --version
```

If `psql --version` says `command not found`, add permanent PATH in `~/.zshrc`:

```
echo 'export PATH="$(brew --prefix postgresql@16)/bin:$PATH"' >> ~/.zshrc
```

Then run:

```
source ~/.zshrc
psql --version
```

Then go to **Step 4**.


### Step 3: read installed version (informational)

```
psql --version
```

If major version is 14 or newer, continue.

If major version is 13 or older, install 16 from **Step 2A**.

Safety note for users upgrading from 12/13:

- Installing `postgresql@16` usually does not remove your older Postgres install.
- Problems usually come from PATH/service confusion, not from having both versions installed.
- After installing, verify what is active:

```
which psql
psql --version
brew services list | grep -i postgres
pg_isready -h localhost
```

Then go to **Step 4**.


### Step 4: start Postgres service

Start the version you actually have installed.

```
brew services start postgresql@16
```

If your formula has a different name (for example `postgresql@15` or plain `postgresql`), start that one instead.


### Step 5: verify Postgres is running

```
pg_isready -h localhost
```

Expected: `localhost:5432 - accepting connections`.

Ignore any following `direnv: loading …` / `direnv: export …` lines — those come from direnv, not Postgres.

### Step 6: find the `DB_USER` value (required)

Who should do this: everyone setting up local env on this branch.

Run this command:

```
psql -d postgres -c 'SELECT current_user;'
```

Then choose the matching case:

- Case A: command succeeds and prints one username (example: `huyckjl`).
	Action: use that exact username as `DB_USER` in Step 7.
- Case B: command fails with role/login errors.
	Action: run the fallback command below.

Fallback command (force the DB login user to `postgres`):

```
psql -U postgres -d postgres -c 'SELECT current_user;'
```

If fallback succeeds, use `postgres` as `DB_USER` in Step 7.

If both commands fail, stop here and use [docs/local/troubleshooting.md](../troubleshooting.md) before continuing.

### Step 7: set `DB_USER` in `.env.local.mac` (required)

Open `.env.local.mac` and set:

```
DB_USER=<value from SELECT current_user;>
```

If `.env.local.mac` does not exist yet, use the creation instructions in [docs/local/environment.md](../environment.md), then come back here.

### Step 8: create Hyku databases

Important: these are PostgreSQL databases for `hyku-oob`.

They are separate from older `develop` MySQL databases.

These commands are safe to re-run.

Creates the `hyku` database only if needed:

```
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku'" | grep -q 1 || createdb hyku
```

Creates the `hyku_test` database only if needed:

```
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku_test'" | grep -q 1 || createdb hyku_test
```

Checks that both Hyku databases exist:

```
psql -d postgres -c '\l' | grep hyku
```

Expected: both `hyku` and `hyku_test` exist.

## Next

Go to [Ruby + rbenv](./ruby-rbenv.md).
