#!/bin/bash
#
# Download cloudfront gzipped logs and unpack them to a directory

# Edit this
S3_CONFIG="/root/.s3cfg"
BUCKET="s3://bucket.name"
GZIP_PATH="/mnt/gzip"
LOG_PATH="/mnt/logs"

# Sync data from bucket to localhost
/usr/bin/s3cmd -c $S3_CONFIG sync $BUCKET $GZIP_PATH

# Find and copy over the gzipped files, unpack them
find $GZIP_PATH -type f -mtime -30m -exec cp {} /mnt/nextgen_logs/ \;
find $LOG_PATH -type f -name "*.gz" -exec gunzip -f '{}' \;

# Remove old logs
find $LOG_PATH -type f -mtime +30 -exec rm -f '{}' \;

