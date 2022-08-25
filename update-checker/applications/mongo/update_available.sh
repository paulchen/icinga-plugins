#!/bin/bash

MAJOR_VERSION=`curl https://releases.rocket.chat/latest/info -s | jq '.compatibleMongoVersions | sort_by(.) | reverse | .[0]' -r`

../../lib/dockerhub.py mongo "$MAJOR_VERSION"

