#!/bin/sh

# Kill the Sidekiq process if it exists

function banner {
  echo -e "$0 ↠ $1"
}

process_pid=`ps aux | grep sidekiq | grep busy | grep -v grep | awk '{print $2}'`

if [ ${#process_pid} -gt 0 ]
then
  banner "killing Sidekiq"
  kill $process_pid
  sleep 5
fi
