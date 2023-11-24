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
	TAGS=`cat`
else
	TAGS=`cat $1|grep '^- image: '|sed -e 's/- image: //'`
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

if [ ! -e /tmp/check_docker_tags ]; then
	echo 'No image to check'
	exit 3
fi

echo $STATE
cat /tmp/check_docker_tags
rm -f /tmp/check_docker_tags
exit $STATE

