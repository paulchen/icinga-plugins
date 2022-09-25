#!/bin/bash

usage() {
	echo "Usage: $0 <file>"
	exit 3
}

if [ "$1" == "" ]; then
	usage
fi

rm -f /tmp/check_docker_tags

if [ "$1" == "-" ]; then
	TAGS=`cat|grep '^- '|sed -e 's/- //'`
else
	TAGS=`cat $1|grep '^- '|sed -e 's/- //'`
fi
DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tag.sh"

STATE=0
for TAG in $TAGS; do
	"$CHECK_SCRIPT" "$TAG" >> /tmp/check_docker_tags
	RESULT=$?

	if [ "$RESULT" -gt "$STATE" ]; then
		STATE="$RESULT"
	fi
done

echo $STATE
cat /tmp/check_docker_tags
rm -f /tmp/check_docker_tags
exit $STATE

