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

MINUTES=1500
if [ "$2" != "" ]; then
	MINUTES=$2
fi

# https://stackoverflow.com/questions/2005021/how-can-i-tell-if-a-file-is-older-than-30-minutes-from-bin-sh#2005083
if test "`find $1 -mmin +$MINUTES`"; then
	echo "File $1 is older than $MINUTES minutes"
	exit 3
fi

readarray status < $1

# https://unix.stackexchange.com/questions/68322/how-can-i-remove-an-element-from-an-array-completely
# https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
for i in "${status[@]:1}"
do
	echo -n "$i"
done

echo ${status[1]}
exit ${status[0]}

