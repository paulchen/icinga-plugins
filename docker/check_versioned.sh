#!/bin/bash

DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tags.sh"

set -o pipefail

docker ps --format '{{.Image}}' | grep -i ".*:[0-9\.A-Z\-]*$" | grep -v '\-custom' | sort | uniq | "$CHECK_SCRIPT" - | tail -n +2 > /tmp/docker-versioned.tmp

STATUS=$?

COUNT=`grep -c 'update available' /tmp/docker-versioned.tmp`

echo "$COUNT update(s) available"

cat /tmp/docker-versioned.tmp

rm -f /tmp/docker-versioned.tmp

exit $STATUS

