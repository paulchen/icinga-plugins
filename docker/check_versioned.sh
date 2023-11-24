#!/bin/bash

DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tags.sh"

docker ps --format '{{.Image}}' | grep -i ".*:[0-9\.A-Z\-]*$" | grep -v ':latest$' | sort | uniq | "$CHECK_SCRIPT" -

