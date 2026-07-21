# 9) ImageMagick + LibreOffice

Back to setup index: [docs/local/README.md](../README.md)

These tools are used for derivatives and office document conversion.

## Step 1: check ImageMagick

Run this command:

```bash
command -v magick
```

If output prints a path, ImageMagick is on PATH.

If output is empty, run this command:

```bash
command -v convert
```

If `convert` prints a path, ImageMagick is installed (older command name).

If both `magick` and `convert` are empty, go to Step 2.

## Step 2: install ImageMagick if needed

These extra formulae support ImageMagick on this branch. LibreOffice does not use them.

Run this command:

```bash
brew install imagemagick shared-mime-info
```

Then re-check:

```bash
command -v magick
```

If `magick` is still empty, run:

```bash
command -v convert
```

## Step 3: check LibreOffice

Run this command:

```bash
command -v soffice
```

If output prints a path, LibreOffice is on PATH.

If output is empty, go to Step 4.

## Step 4: install LibreOffice if needed

LibreOffice only needs its own package here.

Run this command:

```bash
brew install libreoffice
```

Then re-check:

```bash
command -v soffice
```

If anything is still missing after Step 4, use [docs/local/troubleshooting.md](../troubleshooting.md) before continuing.

## Next

Continue to [docs/local/start-services.md](../start-services.md) for the dev environment.

If you need the test environment instead, use [docs/local/start-test-services.md](../start-test-services.md).
