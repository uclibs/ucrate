#!/bin/bash

UPLOADS_DIRECTORY=/mnt/common/scholar-temp-uploads/hyrax/uploaded_file/file
MAXIMUM_DAYS_TO_KEEP_FILES=30

# Check if the directory exists and is not empty
if [ -d "$UPLOADS_DIRECTORY" ] && [ "$(ls -A "$UPLOADS_DIRECTORY")" ]; then
    find "$UPLOADS_DIRECTORY"/* -maxdepth 0 -type d -ctime +$MAXIMUM_DAYS_TO_KEEP_FILES -exec rm -rf {} \;
else
    echo "Directory $UPLOADS_DIRECTORY is either non-existent or empty. Skipping cleanup."
fi
