# 8) Java 8 (Temurin)

Back to setup index: [docs/local/README.md](../README.md)

Fedora 4 wrapper on this stack needs Java 8.

## Step 1: check for Java 8

Run this command:

```bash
/usr/libexec/java_home -v 1.8
```

If this prints a path, Java 8 is installed.

If this prints an error about no matching Java version, go to Step 2.

## Step 2: install Java 8 (only if missing)

Run this command:

```bash
brew install --cask temurin@8
```

Then run this command again:

```bash
/usr/libexec/java_home -v 1.8
```

If you still run into Java issues, use [Java 8 quick fix](../troubleshooting.md#java-8-quick-fix).


## Next

Go to [9) ImageMagick + LibreOffice](./09-imagemagick-libreoffice.md).
