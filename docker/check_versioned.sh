#!/bin/bash

DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tags.sh"

set -o pipefail

docker ps --format '{{.Image}}' | grep -i ".*:[0-9\.A-Z\-]*$" | grep -v ':latest$' | grep -v '\-custom' | sort | uniq | "$CHECK_SCRIPT" - | tail -n +2

exit $?

