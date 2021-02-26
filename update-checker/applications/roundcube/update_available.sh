#!/bin/bash

wget -q -O - "https://github.com/roundcube/roundcubemail/releases.atom" --timeout=15 | grep '<title>' | grep -vi beta | tail -n +2 | sort --version-sort -r | head -n 1 | sed -e 's/<[^>]*>//g;s/^\s*//;s/\s*$//;s/[^0-9]*\([0-9\.]*\).*/\1/g'

