# Ruby version manager + Ruby 3.3.x

Back to setup index: [docs/local/README.md](../README.md)

Team target for this branch: Ruby 3.3.x.

Important:

- Do not mix Ruby managers in one shell.
- Preferred manager for this guide: rbenv.
- If your team setup is already RVM, you can use the RVM path below.

## Step 1: check active Ruby version

```
ruby -v
```

If Ruby shows `3.3.x`, you are done with this step.

If Ruby is not `3.3.x` (example: `3.4.7`), continue to Step 2.


## Step 2: check which Ruby manager you have

Run:

```
command -v rbenv || command -v rvm
```

Decision:

- If output shows an `rbenv` path, follow Step 3B.
- If output shows an `rvm` path, follow Step 3A.
- If there is no output, follow Step 3B (install rbenv first).
- If both managers are installed, use only one in this shell. For this guide, use the rbenv path.


## Step 3A: RVM path (if RVM is installed)

Use RVM only. Do not initialize rbenv in the same shell.

Install Ruby 3.3.6 if needed:

```
rvm install 3.3.6
```

Switch to Ruby 3.3.6 for this project:

From your **ucrate clone root**:

```
rvm use 3.3.6
```

Verify:

```
ruby -v
```

Expected: `ruby 3.3.x ...`


## Step 3B: rbenv path (preferred)

1. Check whether `rbenv` is available:

```
command -v rbenv
```

If this prints nothing, install rbenv + ruby-build:

```
brew install rbenv ruby-build
```

2. Enable rbenv in zsh only if needed:

If Step 2 already found `rbenv`, skip this step.

If `rbenv` was missing and you just installed it, run:

```
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc
```

3. Install and set Ruby 3.3.6 for this repo:

From your **ucrate clone root**:

```
rbenv install -s 3.3.6
rbenv local 3.3.6
ruby -v
```

Expected: `ruby 3.3.x ...`

If rbenv says `3.3.6` is unavailable (or definition missing), update ruby-build and retry:

```
brew upgrade ruby-build
rbenv install -s 3.3.6
```

If you already have another 3.3.x installed, use that version with `rbenv local`.

## Next

Go to [Bundler](./bundler.md).
