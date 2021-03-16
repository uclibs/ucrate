#!/bin/bash
source "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/script/kill_sidekiq.sh"
yes | cp -rf "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"/public/assets/banner_image-*.jpg "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"/public/assets/banner_image.jpg

# Create symlinks for log files
touch /mnt/common/scholar-logs/libschpwl1_production.log
rm -f "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/production.log"
ln -s /mnt/common/scholar-logs/libschpwl1_production.log "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/production.log"
touch /mnt/common/scholar-logs/libschpwl1_sidekiq.log
rm -f "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/sidekiq.log"
ln -s /mnt/common/scholar-logs/libschpwl1_sidekiq.log "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/log/sidekiq.log"

# Create symlinks for system, avatar, upload, and branding directories
ln -s /srv/apps/scholar_capistrano/current /srv/apps/curate_uc 2> /dev/null
rm /srv/apps/scholar_capistrano/shared/public/system/avatars 2> /dev/null
rm /srv/apps/scholar_capistrano/shared/public/uploads 2> /dev/null
rm /srv/apps/scholar_capistrano/shared/public/branding 2> /dev/null
mkdir -p "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/system" 2> /dev/null
ln -s /mnt/common/avatars "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/system/avatars" 2> /dev/null
ln -s /mnt/common/scholar-public-uploads "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/uploads" 2> /dev/null
ln -s /mnt/common/branding "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/branding" 2> /dev/null

# Update the deploy timestamp
/bin/date +"%m-%d-%Y %r" > "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/config/deploy_timestamp"

# Re-generate the robots.txt file to allow indexing (production only)
/bin/printf "User-agent: *\nAllow: /\n" > /srv/apps/scholar_capistrano/current/public/robots.txt

# Restart the application and sidekiq
touch "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/tmp/restart.txt"
source "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/script/restart_sidekiq.sh" production 8 no

# Send notification that deploy is finished
echo "The deploy to `hostname` is finished" | mail -s "Scholar@UC deploy finished (`hostname`)" scholar@uc.edu
