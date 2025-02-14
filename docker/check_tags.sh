#!/bin/bash

usage() {
	echo "Usage: $0 <file>"
	exit 3
}

if [ "$1" == "" ]; then
	usage
fi

rm -f /tmp/check_docker_tags

DIRECTORY=`dirname $0`
PREPROCESS_SCRIPT="$DIRECTORY/preprocess.py"
CHECK_SCRIPT="$DIRECTORY/check_tag.sh"

if [ "$1" == "-" ]; then
	TAGS=`cat`
else
	TAGS=`"$PREPROCESS_SCRIPT" "$1"`
fi

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

