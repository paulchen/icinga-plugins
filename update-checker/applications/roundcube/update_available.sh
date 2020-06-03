#!/bin/bash

wget -q -O - "https://github.com/roundcube/roundcubemail/releases.atom" --timeout=15 | xpath -e '//entry/title/text()' 2>/dev/null|sed -e 's/\[[^\[\]*\]//;s/^\s*//;s/\s*$//'|grep -vi 'release candidate'|sort -r|head -n 1| sed -e 's/[^0-9]*\([0-9\.]*\).*/\1/g'

