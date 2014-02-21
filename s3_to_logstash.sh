#!/bin/bash
#
# Download cloudfront gzipped logs and unpack them to a directory

# Edit this
S3_CONFIG="/root/.s3cfg"
BUCKET="s3://bucket.name"
LOCAL_GZIP="/mnt/cloudfront_gzip"
GZIP_PATH="/mnt/gzip"
S3_GZIP_LOG="/mnt/s3_gzip.log"
LOCAL_GZIP_LOG="/mnt/local_gzip.log"
COMPARE_LOG="/mnt/compare.log"
GZIP_DOWNLOAD_LOG="/mnt/download_gzip.log"
GZIP_DOWNLOADED="/mnt/downloaded.log"
DONE="/mnt/done.log"

# Remove old logs
rm -f $S3_GZIP_LOG $LOCAL_GZIP_LOG $COMPARE_LOG $GZIP_DOWNLOAD_LOG $GZIP_DOWNLOADED $DONE

# List what's on localhost and what's on s3
/usr/bin/s3cmd -c $S3_CONFIG ls $BUCKET | cut -d/ -f 5 | sort >> $S3_GZIP_LOG
find $LOCAL_GZIP -type f -name "*.gz" | cut -d/ -f 4 | sort >> $LOCAL_GZIP_LOG

# Compare the lists and ignore what's on local
comm --nocheck-order -23 $S3_GZIP_LOG $LOCAL_GZIP_LOG >> $COMPARE_LOG

# Add the s3 path to beginning of each line
perl -pe "print '$BUCKET'" $COMPARE_LOG >> $GZIP_DOWNLOAD_LOG

# Download what's missing from s3 in parallel
# -j10 = 10 concurrent threads
# -N1 = 1 argument from stdin, assigned to {1}
# {1} = that argument (The URL from the logsfile)
# Get parallel from http://www.gnu.org/software/parallel/
cat $GZIP_DOWNLOAD_LOG | parallel -j10 -N1 --progress --no-notice /usr/bin/s3cmd -c $S3_CONFIG --no-progress get {1} $GZIP_PATH >> $GZIP_DOWNLOADED

# Make a list of downloaded files
cat $GZIP_DOWNLOADED | awk '{print $5}' | sed -e s/"'"/""/g >> $DONE

# Uncomment to remove downloaded S3 files from S3. Adding expiry rule is prefered instead. 
# cat $GZIP_DOWNLOAD_LOG | parallel -j10 -N1 --no-notice /usr/bin/s3cmd -c $S3_CONFIG --no-progress del {1}
