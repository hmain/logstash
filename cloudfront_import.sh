#!/bin/bash
# Import logs slowly so that logstash can catch up

# Edit this
$LOG_DIR="cloudfront_logs/"
$IMPORT_DIR="cloudfront_import/"

# Grab the 10 oldest files and move them
find $LOG_DIR -type f ! -name '*.gz' | head | sort | while read line; do
 touch $line;
 mv $line $CLOUDFRONT_IMPORT;
done;

  # Remove files older than 1 hour and delete them to undo clogging of the import dir
  find $CLOUDFRONT_IMPORT -type f -mmin +59 -exec rm -f {} \;
