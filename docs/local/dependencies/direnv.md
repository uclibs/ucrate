# direnv

Back to setup index: [docs/local/README.md](../README.md)

direnv loads `.env.local.mac` when you enter the ucrate clone and unloads it when you leave, so other apps on your machine are not affected. This is how local env is loaded for this branch.

You should already have created `.env.local.mac` ([environment.md](../environment.md)) and have Homebrew ([Homebrew](./homebrew.md)).

## Install

```
brew install direnv
```

## Allow this repo (once per clone)

From your **ucrate clone root** (the directory with `Gemfile` and `.envrc`):

```
direnv allow
```

This approves the committed `.envrc` for this clone ([open .envrc](../../../.envrc)). That file only loads your personal `.env.local.mac` if it exists; it does not commit secrets.

Do this **before** enabling the zsh hook, so the next step does not print a “blocked” error.

## Hook into zsh (once per Mac)

```
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Expected: something like `direnv: loading …` / `direnv: export …` (exact text varies by version).

If you use bash instead of zsh, see https://direnv.net/docs/hook.html.

## Confirm

Still in the clone root:

```
env | grep '^HYKU_ROOT_HOST='
env | grep '^HYKU_CACHE_ROOT='
```

Expected: `HYKU_ROOT_HOST=localhost` and your absolute `HYKU_CACHE_ROOT` path.

Then leave the directory and check that the vars are gone:

```
cd ..
env | grep '^HYKU_ROOT_HOST=' || echo 'HYKU_ROOT_HOST unset (good)'
cd -
```

## After you change env files

| You changed… | What to do |
|--------------|------------|
| `.env.local.mac` | Hit Enter in a shell that is already in the clone (or open a new terminal there). **Restart** Rails / Sidekiq if they were already running so they pick up the new values. |
| `.envrc` (rare) | Run `direnv allow` again in the clone root. |

You do **not** need `direnv allow` for normal edits to `.env.local.mac`.

## Next

Go to [PostgreSQL](./postgresql.md).
