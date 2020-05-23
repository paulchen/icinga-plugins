#!/bin/bash

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"

if [ ! -f current ]; then
	echo "File 'current' not found"
	exit 1
fi
cat current

