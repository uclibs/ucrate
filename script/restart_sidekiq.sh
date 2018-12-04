#!/bin/sh

# Kill the Sidekiq process (if it exists) and restart it
# script/restart_sidekiq.sh [production|development]

ENVIRONMENT=$1
APP_DIRECTORY="/srv/apps/curate_uc"

function banner {
    echo -e "$0 ↠ $1"
}

if [ $# -eq 0 ]; then
    echo -e "ERROR: no environment argument [production|development] provided"
    exit 1
fi

if [ $ENVIRONMENT != "production" ] && [ $ENVIRONMENT != "development" ]; then
    echo -e "ERROR: environment argument must be either [production|development] most likely this will be development for local machines and production otherwise"
    exit 1
fi

$APP_DIRECTORY/script/kill_sidekiq.sh

banner "starting Sidekiq"
export PATH=$PATH:/srv/apps/.gem/ruby/2.5.0/bin
export FITS_HOME=/opt/fits/fits
export PATH=$PATH:/opt/fits/fits
cd $APP_DIRECTORY
bundle exec sidekiq -d -c 8 -q ingest -q default -q event -q change -L log/sidekiq.log -C config/sidekiq.yml -e $ENVIRONMENT
