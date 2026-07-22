# 2) PostgreSQL

Back to setup index: [docs/local/README.md](../README.md)

`hyku-oob` uses PostgreSQL.

For local setup on this branch, PostgreSQL **14 or newer** is acceptable.

- If you already have 14/15/16/17, keep it.
- You do not need to force-upgrade to 16.

## Step-by-step check and install

### Step 1: check for `psql`

```bash
which psql
```

If output includes a path (example: `/opt/homebrew/bin/psql`): go to **Step 3**.

If output is empty or says `psql not found`: go to **Step 2**.


### Step 2: check whether Postgres is installed but not on PATH

```bash
brew list --versions | egrep '^postgresql(@| )' || true
```

If this command prints any `postgresql@...` line, Postgres is already installed.

- Do not install a second copy.
- First, try `which psql` again in a new terminal window.
- If `psql` is still not found, add a permanent PATH entry in `~/.zshrc`.


Example permanent PATH entry for `postgresql@16`:

```bash
echo 'export PATH="$(brew --prefix postgresql@16)/bin:$PATH"' >> ~/.zshrc
```

Then run:

```bash
source ~/.zshrc
```

Now re-check:

```bash
which psql
psql --version
```

If `psql` now works, go to **Step 3**.

If brew list is empty (nothing printed), Postgres is missing. Install it in **Step 2A**.


#### Step 2A: install Postgres (only if missing)

```bash
brew install postgresql@16
```

```bash
psql --version
```

If `psql --version` says `command not found`, add permanent PATH in `~/.zshrc`:

```bash
echo 'export PATH="$(brew --prefix postgresql@16)/bin:$PATH"' >> ~/.zshrc
```

Then run:

```bash
source ~/.zshrc
psql --version
```

Then go to **Step 4**.


### Step 3: read installed version (informational)

```bash
psql --version
```

If major version is 14 or newer, continue.

If major version is 13 or older, install 16 from **Step 2A**.

Safety note for users upgrading from 12/13:

- Installing `postgresql@16` usually does not remove your older Postgres install.
- Problems usually come from PATH/service confusion, not from having both versions installed.
- After installing, verify what is active:

```bash
which psql
psql --version
brew services list | grep -i postgres
pg_isready -h localhost
```

Then go to **Step 4**.


### Step 4: start Postgres service

Start the version you actually have installed.

If you installed `postgresql@16`:

```bash
brew services start postgresql@16
```

If you already had an earlier formula, start that one instead (example):

```bash
brew services start postgresql@15
```

Or:

```bash
brew services start postgresql@14
```

If your formula is just `postgresql`, start it with:

```bash
brew services start postgresql
```


### Step 5: verify Postgres is running

```bash
pg_isready -h localhost
```

Expected: `accepting connections`.

### Step 6: find the `DB_USER` value (required)

Who should do this: everyone setting up local env on this branch.

Run this command:

```bash
psql -d postgres -c 'SELECT current_user;'
```

Then choose the matching case:

- Case A: command succeeds and prints one username (example: `huyckjl`).
	Action: use that exact username as `DB_USER` in Step 7.
- Case B: command fails with role/login errors.
	Action: run the fallback command below.

Fallback command (force the DB login user to `postgres`):

```bash
psql -U postgres -d postgres -c 'SELECT current_user;'
```

If fallback succeeds, use `postgres` as `DB_USER` in Step 7.

If both commands fail, stop here and use [docs/local/troubleshooting.md](../troubleshooting.md) before continuing.

### Step 7: set `DB_USER` in `.env.local.mac` (required)

Open `.env.local.mac` and set:

```bash
DB_USER=<value from SELECT current_user;>
```

If `.env.local.mac` does not exist yet, use the creation instructions in [docs/local/environment.md](../environment.md), then come back here.

### Step 8: create Hyku databases

Important: these are PostgreSQL databases for `hyku-oob`.

They are separate from older `develop` MySQL databases.

These commands are safe to re-run.

Creates the `hyku` database only if needed:

```bash
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku'" | grep -q 1 || createdb hyku
```

Creates the `hyku_test` database only if needed:

```bash
psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='hyku_test'" | grep -q 1 || createdb hyku_test
```

Checks that both Hyku databases exist:

```bash
psql -d postgres -c '\l' | grep hyku
```

Expected: both `hyku` and `hyku_test` exist.

## Next

Go to [3) Ruby + rbenv](./03-ruby-rbenv.md).
