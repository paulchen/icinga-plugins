#!/bin/bash

DIR=`dirname "$0"`
cd "$DIR"

STATUSFILE=update.status
if [ ! -e "$STATUSFILE" ]; then
    echo "File $STATUSFILE does not exist"
    exit 3
fi

if [ ! -f "$STATUSFILE" ]; then
    echo "$STATUSFILE is not a file"
    exit 3
fi

if [ ! -r "$STATUSFILE" ]; then
    echo "$STATUSFILE cannot be read"
    exit 3
fi

# https://stackoverflow.com/questions/2005021/how-can-i-tell-if-a-file-is-older-than-30-minutes-from-bin-sh#2005083
if test "`find $STATUSFILE -mmin +250`"; then
	echo "File $STATUSFILE is older than 250 minutes"
	exit 3
fi

readarray status < $STATUSFILE

echo ${status[1]}
exit ${status[0]}
