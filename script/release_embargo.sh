#!/bin/bash

# Change and expired embargoed objects to open access
# Runs as a cron job daily just after midnight

cd /srv/apps/curate_uc
export PATH=$PATH:/srv/apps/.gem/ruby/2.7.0/bin
export RELEASE_DATE=`date +\%Y-\%m-\%d -d "+1 day"`
RAILS_ENV=production bundle exec rake embargo_release["$RELEASE_DATE"]
