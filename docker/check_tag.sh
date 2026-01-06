#!/bin/bash

usage() {
	echo "Usage: $0 <tag>"
	exit 3
}

if [ "$1" == "" ]; then
	usage
fi

ERROR=0
LOCALS=`docker image inspect "$1" --format '{{.RepoDigests}}'|sed -e 's/\[//g;s/\]//g;s/[^ ]*@//g'`

if [ "$ERROR" -eq "1" ]; then
	echo "$1: error checking local version"
	exit 3
fi

REMOTE=`/opt/regctl image digest --list "$1" || ERROR=1`

if [ "$ERROR" -eq "1" ]; then
	echo "$1: error checking version on DockerHub"
	exit 3
fi

if [ "$REMOTE" == "" ]; then
	echo "$1: error checking version on DockerHub"
	exit 3
fi

for LOCAL in $LOCALS; do
	if [ "$LOCAL" == "$REMOTE" ]; then
		echo "$1: OK ($REMOTE)"
		exit 0
	fi
done

echo "$1: update available ($LOCAL -> $REMOTE)"
exit 2

