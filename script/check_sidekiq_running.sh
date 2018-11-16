#!/bin/sh

# Kill the Sidekiq process (if it exists) and restart it
# script/check_sidekiq_running.sh [production|development]

RECIPIENTS="scholar@uc.edu"
HOSTNAME=$(hostname -s)
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

process_pid=`ps aux | grep sidekiq | grep busy | grep -v grep | awk '{print $2}'`

if [ ${#process_pid} -gt 0 ]
  then
    sleep 1;
  else
    echo "Hydra server $HOSTNAME did not have Sidekiq running.  Sidekiq has been automatically restarted and will be checked again in one hour." > /tmp/sidekiqalert
    sleep 1
    mail -s "Sidekiq restarted on $1" $RECIPIENTS < /tmp/sidekiqalert
    $APP_DIRECTORY/script/restart_sidekiq.sh $1
fi
