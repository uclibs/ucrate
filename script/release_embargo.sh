#!/bin/bash

# Change and expired embargoed objects to open access
# Runs as a cron job daily just after midnight

cd /srv/apps/curate_uc
bundle exec rake embargo_manager:release
