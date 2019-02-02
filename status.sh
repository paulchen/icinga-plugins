#!/bin/bash

if [ "$1" == "" ]; then
    echo "Wrong number of arguments"
    exit 3
fi

if [ ! -e "$1" ]; then
    echo "File $1 does not exist"
    exit 3
fi

if [ ! -f "$1" ]; then
    echo "$1 is not a file"
    exit 3
fi

if [ ! -r "$1" ]; then
    echo "$1 cannot be read"
    exit 3
fi

# https://stackoverflow.com/questions/2005021/how-can-i-tell-if-a-file-is-older-than-30-minutes-from-bin-sh#2005083
if test "`find $1 -mmin +1500`"; then
	echo "File $1 is older than 1500 minutes"
	exit 3
fi

readarray status < $1

echo ${status[1]}
exit ${status[0]}
