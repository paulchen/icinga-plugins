#!/bin/bash

usage() {
	echo "Usage: $0 <tag>"
	exit 3
}

if [ "$1" == "" ]; then
	usage
fi

ERROR=0
LOCAL=`docker inspect "$1" --format '{{.Id}}' 2> /dev/null` || ERROR=1

if [ "$ERROR" -eq "1" ]; then
	echo "$1: error checking local version"
	exit 3
fi

REMOTE=`docker manifest inspect "$1" -v | jq -r 'if type=="array" then .[0] else . end | if has("OCIManifest") then .OCIManifest else .SchemaV2Manifest end | .config.digest' || ERROR=1`

if [ "$ERROR" -eq "1" ]; then
	echo "$1: error checking version on DockerHub"
	exit 3
fi

if [ "$REMOTE" == "" ]; then
	echo "$1: error checking version on DockerHub"
	exit 3
fi

if [ "$LOCAL" != "$REMOTE" ]; then
	echo "$1: update available ($LOCAL -> $REMOTE)"
	exit 2
fi
echo "$1: OK ($LOCAL)"

