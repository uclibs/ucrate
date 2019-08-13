#!/bin/bash
if [ ! -f "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/scholar-dev.variables" ]; then
    echo "Missing scholar-dev.variables file in static"
else 
    cp "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/static/scholar-dev.variables" ../.env.development.local
fi
ln -s /srv/apps/scholar_capistrano/current /srv/apps/curate_uc 2> /dev/null
ln -s /srv/apps/scholar-avatars "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/systems/avatars" 2> /dev/null
ln -s /srv/apps/scholar-public-uploads "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )" )/shared/public/uploads/" 2> /dev/null
/bin/date +"%m-%d-%Y %r" > "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/config/deploy_timestamp"
touch "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/tmp/restart.txt"
source "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/script/restart_sidekiq.sh" development 8 no
echo "The deploy to Scholar@UC DEV is finished" | mail -s 'Scholar@UC deploy finished (scholar-dev)' scholar@uc.edu