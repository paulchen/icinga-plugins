#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

# using $1 can be a security issue
wget -q -O - "https://github.com/$1/commits/master.atom" --timeout=15 | xpath -e '//entry[1]/id/text()' 2>/dev/null | sed -e "s/^.*Commit\///g"

