#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

# using $1 can be a security issue

if [ "$2" == "legacy" ]; then
	# some repos (like postfixadmin/postfixadmin) seem to tag their releases in some wrong way
	wget -q -O - "https://github.com/$1/releases.atom" --timeout=15 | xpath -e '//entry[1]/title/text()' 2>/dev/null | sed -e 's/[^0-9]*\([0-9\.]*\).*/\1/g'
else
	# stolen from https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
	wget -q -O - "https://api.github.com/repos/$1/releases/latest" --timeout=15 | grep -Po '"tag_name": "\K.*?(?=")'
fi

