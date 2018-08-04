#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

# using $1 can be a security issue
wget -q -O - "https://github.com/$1/releases.atom" | xpath -e '//entry[1]/title/text()' 2>/dev/null | sed -e "s/[^\.0-9]//g"

