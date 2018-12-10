#!/bin/bash

# Update work and file index, and update stats
# Runs as a cron job daily 

cd /srv/apps/curate_uc
RAILS_ENV=production bundle exec rake custom_stats:update_index
RAILS_ENV=production bundle exec rake custom_stats:collect LIMIT="1000" DELAY="2" RETRIES="8"
