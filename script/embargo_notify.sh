#!/bin/sh

# Notify editors that a work has been released
# script/embargo_notify.sh [production|development]

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

banner "Notify Embargoe Editors"

cd $APP_DIRECTORY

RAILS_ENV=$ENVIRONMENT bundle exec rake embargo_notify
