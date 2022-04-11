#!/bin/bash

usage() {
	echo "Usage: $0 <file>"
	exit 3
}

if [ "$1" == "" ]; then
	usage
fi

if [ "$1" == "-" ]; then
	TAGS=`cat`
else
	TAGS=`cat $1`
fi
DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tag.sh"

STATE=0
for TAG in $TAGS; do
	"$CHECK_SCRIPT" "$TAG"
	RESULT=$?

	if [ "$RESULT" -gt "$STATE" ]; then
		STATE="$RESULT"
	fi
done

exit $STATE

