#!/bin/bash

DIRECTORY=`dirname $0`
CHECK_SCRIPT="$DIRECTORY/check_tags.sh"

docker ps --format '{{.Image}}' | grep ".*:[0-9\.]*$" | sort | uniq | "$CHECK_SCRIPT" -

