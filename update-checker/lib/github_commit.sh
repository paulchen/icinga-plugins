#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

if [ "$2" == "" ]; then
	# using $1 can be a security issue
	COMMIT=`wget -q -O - --header="Accept: text/xml" "https://github.com/$1/commits/master.atom" --timeout=15 | xpath -e '//entry[1]/id/text()' 2>/dev/null | sed -e "s/^.*Commit\///g"`
	if [ "$COMMIT" == "" ]; then
		DEFAULT_BRANCH=`wget -qO- "https://api.github.com/repos/$1" | jq -r '.default_branch'`
		if [ "$DEFAULT_BRANCH" != "" ]; then
			"$0" "$1" "$DEFAULT_BRANCH"
		fi
	else
		echo "$COMMIT"
	fi
else
	wget -q -O - --header="Accept: text/xml" "https://github.com/$1/commits/$2.atom" --timeout=15 | xpath -e '//entry[1]/id/text()' 2>/dev/null | sed -e "s/^.*Commit\///g"
fi

