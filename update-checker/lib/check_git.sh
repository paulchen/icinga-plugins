#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

cd "$1" || exit 1
git log|grep '^commit'|head -n 1|sed -e 's/^commit //'

