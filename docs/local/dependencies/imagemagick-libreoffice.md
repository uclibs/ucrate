# ImageMagick + LibreOffice

Back to setup index: [docs/local/README.md](../README.md)

These tools are used for derivatives and office document conversion.

## Step 1: check ImageMagick

Run this command:

```
command -v magick
```

If output prints a path, ImageMagick is on PATH — go to **Step 3**.

If output is empty, run this command:

```
command -v convert
```

If `convert` prints a path, ImageMagick is installed (older command name) — go to **Step 3**.

If both `magick` and `convert` are empty, go to **Step 2**.

## Step 2: install ImageMagick if needed

These extra formulae support ImageMagick on this branch. LibreOffice does not use them.

Run this command:

```
brew install imagemagick shared-mime-info
```

Then re-check:

```
command -v magick
```

If `magick` is still empty, run:

```
command -v convert
```

## Step 3: check LibreOffice

Run this command:

```
command -v soffice
```

If output prints a path, LibreOffice is on PATH — you are done with ImageMagick and LibreOffice. Go to **Next**.

If output is empty, go to **Step 4**.

## Step 4: install LibreOffice if needed

LibreOffice only needs its own package here.

Run this command:

```
brew install libreoffice
```

Then re-check:

```
command -v soffice
```

If output prints a path, go to **Next**.

If anything is still missing after Step 4, use [docs/local/troubleshooting.md](../troubleshooting.md) before continuing.

## Next

Continue to [docs/local/start-services.md](../start-services.md) for the dev environment.

If you need the test environment instead, use [docs/local/start-test-services.md](../start-test-services.md).
