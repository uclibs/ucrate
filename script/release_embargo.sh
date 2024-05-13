#!/bin/sh

# Change and expired embargoed objects to open access
# Runs as a cron job daily just after midnight
# script/release_embargo.sh [production|development]

ENVIRONMENT=$1

APP_DIRECTORY="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"

if [ $# -eq 0 ]; then
    echo -e "ERROR: no environment argument [production|development] provided"
    exit 1
fi

if [ $ENVIRONMENT != "production" ] && [ $ENVIRONMENT != "development" ]; then
    echo -e "ERROR: environment argument must be either [production|development] most likely this will be development for local machines and production otherwise"
    exit 1
fi

if [[ $ENVIRONMENT == "production" ]]; then
    export PATH=$PATH:/srv/apps/.gem/ruby/2.7.0/bin
fi

cd $APP_DIRECTORY
export RELEASE_DATE=`date +\%Y-\%m-\%d -d "+1 day"`
RAILS_ENV=$ENVIRONMENT bundle exec rake embargo_release["$RELEASE_DATE"]
