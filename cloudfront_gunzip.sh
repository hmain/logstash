#!/bin/bash
# Check for new cloudfront logs and gunzip them

# Edit this
$DONE_LOG="/mnt/done.log"
$GZIP_DIR="cloudfront_gzip/"
$LOG_DIR="cloudfront_logs/"

# File-list to gunzip
cat $DONE_LOG | while read line;
do
 mv $line $LOG_DIR ;
 i=$(echo $line | sed -e s/"$GZIP_DIR"/"$LOG_DIR"/g) ;
 gunzip $i ;
done
