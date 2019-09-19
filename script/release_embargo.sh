#!/bin/bash

# Change and expired embargoed objects to open access
# Runs as a cron job daily just after midnight

cd "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
export RELEASE_DATE=`date -v +1d "+%Y-\%m-\%d"`
bundle exec rake embargo_release["$RELEASE_DATE"]