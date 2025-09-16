#!/bin/bash

if [ "$1" == "" ]; then
	exit 1
fi

# using $1 can be a security issue

# stolen from https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
wget -q -O - "https://api.github.com/repos/$1/releases/latest" --timeout=15 | grep -Po '"tag_name": "\K.*?(?=")'

