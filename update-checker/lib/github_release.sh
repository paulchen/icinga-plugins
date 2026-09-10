#!/bin/bash

set -o pipefail

if [ "$1" == "" ]; then
	exit 1
fi

CONFIG_FILE=`dirname "$0"`/../.config

if [ -f "$CONFIG_FILE" ]; then
	. "$CONFIG_FILE"
fi

# using $1 can be a security issue
URL="https://api.github.com/repos/$1/releases/latest"

if [ "$GITHUB_TOKEN" == "" ]; then
	wget --timeout=15 --header='Accept: application/vnd.github+json' "$URL" -q -O - | grep -Po '"tag_name": "\K.*?(?=")' || exit 1
else
	wget --timeout=15 --header="Authorization: Bearer $GITHUB_TOKEN" --header='Accept: application/vnd.github+json' "$URL" -q -O - | grep -Po '"tag_name": "\K.*?(?=")' || exit 1
fi

