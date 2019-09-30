#!/bin/bash

# Update work and file index, and update stats
# Runs as a cron job daily 

cd "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
RAILS_ENV=production bundle exec rake custom_stats:update_index
RAILS_ENV=production bundle exec rake custom_stats:collect LIMIT="1000" DELAY="2" RETRIES="8"
