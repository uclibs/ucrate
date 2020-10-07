#!/bin/bash
if [ ! -f "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/.env.development.local" ]; then
    echo "Missing updated .env.development.local file in the static directory. The server may not function properly"
else
    cp "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/.env.development.local" "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
fi

# Kill rails server if exists
kill -9 $(lsof -i tcp:3002 -t) 2> /dev/null
source "$HOME/.rvm/scripts/rvm" && bin/bundle exec rails server -p 3002 -b 0.0.0.0 -d
source script/restart_sidekiq.sh development 1
#bin/bundle exec rails hyrax:default_admin_set:create
#bin/bundle exec rails hyrax:default_collection_types:create
#bin/bundle exec rails hyrax:workflow:load
