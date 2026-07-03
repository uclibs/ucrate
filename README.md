# Scholar@UC
[![Services Health](https://scholaratuc.montastic.io/badge)](https://scholaratuc.montastic.io)
![Travis (.org) branch](https://img.shields.io/travis/uclibs/ucrate/develop.svg) ![Coveralls coverage](https://img.shields.io/coveralls/github/uclibs/ucrate/develop.svg)
[![CircleCI](https://circleci.com/gh/uclibs/ucrate.svg?style=svg)](https://circleci.com/gh/uclibs/ucrate)
[![Coverage Status](https://coveralls.io/repos/github/uclibs/ucrate/badge.svg?branch=main)](https://coveralls.io/github/uclibs/ucrate?branch=main)

## Repository upgrade

Work on branch `scholar-modernization` follows the **Hyrax 5 + Fedora 7 upgrade plan** in [docs/upgrade/README.md](docs/upgrade/README.md). Update [docs/upgrade/STATUS.md](docs/upgrade/STATUS.md) at the end of each session. Do not merge upgrade work into `develop` until Fedora 7 works on scholar-dev (plan C2).

## System Requirements

### macOS with Apple Silicon (M1–M4) — Recommended

* Ruby 2.7.8 (built with OpenSSL 1.1.1)
* Bundler 2.4.22
* Solr 5.x–6.2.0
* Fedora Commons 4.5.1+
* MySQL 8.0+
* Redis
* ImageMagick
* Java 8 (for Fedora)
* LibreOffice

### macOS with Intel Chip

* Ruby 2.7.8 (build instructions same as above, but runs natively on Intel)
* All other dependencies same as Apple Silicon
* No special compiler flags needed for native extensions

> **Note:** Solr will not run properly if there are spaces in any of the directory names in its path.

---

## Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/uclibs/ucrate.git ./path/to/ucrate
cd ./path/to/ucrate
git checkout develop
```

### Step 2: Install Dependencies

#### macOS with Apple Silicon (M1–M4)

**Install Homebrew packages:**
```bash
brew install sqlite3 mysql-client redis solr@8 imagemagick@6 libreoffice libsodium zstd
```

**Install Java 8 (required for Fedora):**
```bash
brew install --cask temurin@8
```

**Verify Java 8 is available:**
```bash
/usr/libexec/java_home -v 1.8
```

**Build OpenSSL 1.1.1 (required by Ruby 2.7.8):**
```bash
cd /tmp
curl -fL -o openssl-1.1.1w.tar.gz https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar -xzf openssl-1.1.1w.tar.gz && cd openssl-1.1.1w
./Configure darwin64-arm64-cc --prefix=/usr/local/opt/openssl@1.1 no-shared
make -j$(sysctl -n hw.logicalcpu)
sudo make install_sw
```

**Install Ruby 2.7.8 via rbenv:**
```bash
brew install rbenv ruby-build
RUBY_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/opt/openssl@1.1" rbenv install 2.7.8
rbenv local 2.7.8
```

**Install Bundler & gems:**
```bash
gem install bundler -v 2.4.22
cd /path/to/ucrate
export CFLAGS="-Wno-incompatible-function-pointer-types"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib -L$(brew --prefix zstd)/lib"
bundle _2.4.22_ config set build.mysql2 "--with-mysql-config=$(brew --prefix mysql-client)/bin/mysql_config"
bundle _2.4.22_ install
```

#### macOS with Intel Chip

**Install Homebrew packages:**
```bash
brew install sqlite3 mysql-client redis solr@8 imagemagick@6 libreoffice libsodium
```

**Install Java 8:**
```bash
brew install --cask temurin@8
```

**Verify Java 8 is available:**
```bash
/usr/libexec/java_home -v 1.8
```

**Install Ruby 2.7.8 via rbenv:**
```bash
brew install rbenv ruby-build
rbenv install 2.7.8
rbenv local 2.7.8
```

**Install Bundler & gems:**
```bash
gem install bundler -v 2.4.22
cd /path/to/ucrate
bundle install
```

---

## Running the Application (All Platforms)

Start these services in separate terminal tabs (foreground; do not append `&`):

### Terminal 1: Fedora (port 8984)

**All platforms:**
```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper -p 8984
```

### Terminal 2: Solr (port 8983)

**All platforms:**
```bash
bundle exec solr_wrapper -d solr/config/ --collection_name hydra-development
```

### Terminal 3: Redis (port 6379)

**All platforms:**
```bash
redis-server
```

### Terminal 4: Rails Application

**All platforms:**
Make sure this terminal is in your `ucrate` project directory.

```bash
bundle exec rake db:migrate
bundle exec rails hyrax:default_admin_set:create
bundle exec rails hyrax:default_collection_types:create
bundle exec rails hyrax:workflow:load
rails server
```

Visit **http://localhost:3000**

### Create Admin User

In a new terminal:
```bash
bundle exec rails console
```

In the Rails console:
```ruby
admin = Role.find_or_create_by(name: "admin")
admin.users << User.find_by_user_key("your_email@example.com")
admin.save
exit
```

---

## Running Tests (All Platforms)

### Fast local specs (no Fedora/Solr)

For day-to-day development—especially on `scholar-modernization`:

```bash
bin/rspec-fast
```

See [docs/upgrade/TESTING.md](docs/upgrade/TESTING.md). CircleCI runs the **full** suite on push.

### Full suite (Fedora + Solr required)

Start these services in separate terminal tabs (foreground; do not append `&`):

### Terminal 1: Fedora (port 8080)

**All platforms:**
```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
bundle exec fcrepo_wrapper -p 8080
```

### Terminal 2: Solr (port 8985)

**All platforms:**
```bash
bundle exec solr_wrapper -d solr/config/ --collection_name hydra-test -p 8985
```

### Terminal 3: Redis

**All platforms:**
```bash
redis-server
```

### Terminal 4: Run Tests

**All platforms:**
Make sure this terminal is in your `ucrate` project directory.

```bash
RAILS_ENV=test bundle exec rake db:migrate
bundle exec rake spec
```

---

## Security Checks

```bash
bundle exec brakeman -q -w 2
bundle-audit check --update
```

## Troubleshooting

### `zsh: command not found: fcrepo_wrapper`

Cause: `fcrepo_wrapper` is installed as a gem in this app, not as a global system command.

Fix:
```bash
cd /path/to/ucrate
bundle install
bundle exec fcrepo_wrapper -p 8984
```

### `Unable to locate a Java Runtime`

Cause: Java 8 is not installed or not active in the current terminal.

Fix:
```bash
brew install --cask temurin@8
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
export PATH="$JAVA_HOME/bin:$PATH"
java -version
bundle exec fcrepo_wrapper -p 8984
```

### `zsh: command not found: redis-server`

Cause: Redis is not installed yet.

Fix:
```bash
brew install redis
redis-server --version
redis-server
```

### Unexpected warnings when starting Rails console

Examples:

* `Top level ::CompositeIO is deprecated...`
* `rb_check_safe_obj will be removed in Ruby 3.0`
* `Pattern matching is experimental...`
* `irb: warn: can't alias context from irb_context`

Cause: This app runs on an older Rails/Ruby dependency stack, and some gems emit warnings on startup.

What to do:

* If you see `Loading development environment` and get an `irb` prompt, you can continue.
* Treat these as non-blocking warnings unless the console exits with an exception.

## Project Samvera
This software has been developed by and is brought to you by the Samvera community. Learn more at the
[Samvera website](http://projecthydra.org)

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
