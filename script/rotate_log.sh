#!/bin/sh

hostname=$1
file_name=/mnt/common/scholar-logs/${hostname}_production.log
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
new_fileName=/mnt/common/scholar-logs/${hostname}_archive/${hostname}_production.log.$current_time

if [ -f $file_name ];
then

  # Move the log file to a new directory and add timestamp
  mv $file_name $new_fileName

  # Restart the app and generate a blank log file
  touch $file_name
  touch "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" )/tmp/restart.txt"
  
  # Compress the moved log file
  gzip $new_fileName

fi

