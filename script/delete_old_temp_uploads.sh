#!/bin/bash

UPLOADS_DIRECTORY=/mnt/common/scholar-temp-uploads/hyrax/uploaded_file/file
MAXIMUM_DAYS_TO_KEEP_FILES=30

find $UPLOADS_DIRECTORY/* -maxdepth 0 -type d -ctime +$MAXIMUM_DAYS_TO_KEEP_FILES -exec rm -rf {} \;
