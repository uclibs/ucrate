# Node + Yarn

Back to setup index: [docs/local/README.md](../README.md)

Node and Yarn are needed for frontend assets (Universal Viewer setup).

## Step 1: check Node and Yarn

```
node -v
yarn -v
```

Expected:

- Node: `20.x` LTS.
- Yarn: `1.x` (Classic) is required for this branch.

Why: this repo uses a `yarn.lock` v1 file, and Yarn 4 causes install/build failures on this branch.

What to do next:

- If Node is `20.x` and Yarn is `1.x`, continue to Step 4.
- If Node is not `20.x` (older or newer, for example `24.x`), continue to Step 2.
- If Node is `20.x` but Yarn is not `1.x`, continue to Step 3.


## Step 2: switch Node to 20 LTS with NVM (if Node is not 20.x)

Check NVM:

```
command -v nvm
```

If NVM is missing, install it with Homebrew:

```
brew install nvm
mkdir -p ~/.nvm
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"' >> ~/.zshrc
source ~/.zshrc
```

Install/use Node 20 LTS:

```
nvm install 20
nvm use 20
node -v
```

Expected: `v20...`.

Why this matters: non-20 Node versions can fail on this branch when building native packages (for example `canvas`).


## Step 3: ensure Yarn is available

If Yarn is missing or not `1.x`, set Yarn to 1 Classic:

First check Corepack:

```
command -v corepack
```

If `corepack` is missing, install it:

```
npm install -g corepack
```

Then (whether Corepack was already present or just installed), set Yarn to 1 Classic:

```
corepack prepare yarn@1.22.22 --activate
yarn -v
```

Expected: `1.22.x`


## Step 4: install JS dependencies

From your **ucrate clone root**:

```
yarn install
```

Expected:

- Command completes without errors.
- A folder named `public/uv` is created/updated.

What is `public/uv`?

- It contains Universal Viewer front-end files copied from Node packages.
- The app uses these files to render/view digital content in the browser.

Quick check:

```
ls public/uv
```

If `yarn install` fails with errors like `command not found: if`, `command not found: fi`, or `No matches found: "../config/uv/*"`, confirm `yarn -v` is `1.22.x`, then run `yarn install` again.

## Next

Go to [Redis](./redis.md).
