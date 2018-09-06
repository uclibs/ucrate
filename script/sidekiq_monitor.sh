#!/bin/bash
HOSTNAME=$( hostname )

BACKLOG_MAX=100 # Number of allowed jobs in queue before warning is sent
LATENCY_MAX=2000  # Amount of time (in seconds) between when the oldest job was enqueued and the current time before a warning is sent

BACKLOG=$( curl -s http://${HOSTNAME}.private/queue-status )
TEMP=$( curl -s http://${HOSTNAME}.private/queue-latency )
LATENCY=${TEMP%.*}

if [ $BACKLOG -gt $BACKLOG_MAX ] && [ $LATENCY -gt $LATENCY_MAX ]; then
  mail -s "Scholar Sidekiq Backlog/Latency warning" scholar@uc.edu <<< "The web server ${HOSTNAME} currently has a sidekiq backlog of ${BACKLOG} and a latency of ${LATENCY}. Your desired maximums for these values are BACKLOG: ${BACKLOG_MAX} and LATENCY: ${LATENCY_MAX}"
elif [ $BACKLOG -gt $BACKLOG_MAX ]; then
  mail -s "Scholar Sidekiq Backlog warning" scholar@uc.edu <<< "The web server ${HOSTNAME} currently has a sidekiq backlog of ${BACKLOG} which is above your desired ${BACKLOG_MAX} maximum. To assist in troubleshooting the sidekiq latency currently is ${LATENCY} seconds."
  echo "BACKLOG ${BACKLOG}"
elif [ $LATENCY -gt $LATENCY_MAX ]; then
  mail -s "Scholar Sidekiq Latency warning" scholar@uc.edu <<< "The web server ${HOSTNAME} currently has a sidekiq latency of ${LATENCY} which is above your desired maximum latency of ${LATENCY_MAX}. To assist in troubleshooting the sidekiq backlog is currently ${BACKLOG} jobs." 
fi
