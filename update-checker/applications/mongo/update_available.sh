#!/bin/bash

ROCKETCHAT_VERSION=`../rocketchat/update_installed.sh`

MAJOR_VERSION=`curl "https://releases.rocket.chat/$ROCKETCHAT_VERSION/info" -s 2> /dev/null | jq '.compatibleMongoVersions | sort_by(.) | reverse | .[0]' -r 2> /dev/null`

if [ "$MAJOR_VERSION" == "" ]; then
	echo "Unable to fetch supported MongoDB versions from Rocket.Chat"
	exit 1
fi

../../lib/dockerhub.py library mongo "$MAJOR_VERSION" '^[0-9]+\.[0-9]+\.[0-9]+$'

