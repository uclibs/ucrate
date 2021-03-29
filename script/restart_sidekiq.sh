#!/bin/sh

# Kill the Sidekiq process (if it exists) and restart it
# script/restart_sidekiq.sh [production|development]

ENVIRONMENT=$1
THREADS=$2
RVM=$3
APP_DIRECTORY="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )"
if [[ $RVM == "yes" ]]; then
    source "$HOME/.rvm/scripts/rvm"
    export PATH=$PATH:"$(rvm gemdir)/bin"
fi
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
# Check if threads were set
re='^[0-9]+$'
if ! [[ $THREADS =~ $re ]] ; then
   THREADS=8
fi

if [[ $ENVIRONMENT == "production" ]]; then
    export PATH=$PATH:/srv/apps/.gem/ruby/2.7.0/bin
fi

$APP_DIRECTORY/script/kill_sidekiq.sh

banner "starting Sidekiq"
if [[ -z "${FITS_HOME}" ]]; then
  export FITS_HOME=/opt/fits/fits
  export PATH=$PATH:/opt/fits/fits
fi
cd $APP_DIRECTORY
bundle exec sidekiq -d -c $THREADS -q ingest -q default -q event -q change -q import -q export -q fixity_check -L log/sidekiq.log -C config/sidekiq.yml -e $ENVIRONMENT
