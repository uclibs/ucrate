# 4) Bundler

Back to setup index: [docs/local/README.md](../README.md)

This project lockfile is pinned to Bundler 2.6.9.

## Check

```bash
bundler -v
```

Expected: Bundler 2.6.9 (or install that exact version).

## If missing or wrong version

```bash
gem install bundler -v 2.6.9
bundler -v
```

If you see a RubyGems message like:

`A new release of RubyGems is available ... Run gem update --system ...`

Do not run `gem update --system` during first-time setup.

For this project, only Bundler version needs to match now. Team-wide RubyGems upgrades should be planned separately.

## Install gems

Before installing gems, confirm you are in this repo and on the `hyku-oob` branch.

```bash
cd /path/to/ucrate
git branch --show-current
```

If branch output is not `hyku-oob`, switch first:

```bash
git checkout hyku-oob
```

Then install gems:

```bash
bundle install
```

If you see a Bundler version mismatch error, retry with:

```bash
bundle _2.6.9_ install
```

Expected: install completes with no dependency errors.

## Next

Go to [5) Rails](./05-rails.md).
