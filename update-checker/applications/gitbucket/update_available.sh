#!/bin/bash
wget -q -O - https://github.com/gitbucket/gitbucket/releases.atom | xpath -e '//entry[1]/title/text()' 2>/dev/null | sed -e "s/[^\.0-9]//g"

