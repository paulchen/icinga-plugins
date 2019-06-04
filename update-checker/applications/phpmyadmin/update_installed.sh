#!/bin/bash

if [ ! -f /var/www/default/web/pma/README ]; then
	exit 1
fi

grep Version /var/www/default/web/pma/README|sed -e "s/^.* //"

