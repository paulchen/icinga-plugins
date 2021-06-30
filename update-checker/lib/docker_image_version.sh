#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

docker ps --filter "name=^$1$" --format '{{.Image}}'|sed -e 's/.*://'

