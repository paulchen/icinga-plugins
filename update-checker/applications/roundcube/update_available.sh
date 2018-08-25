#!/bin/bash
wget -q -O - https://roundcube.net/feeds/atom.xml | xpath -e '//entry[not(contains(title/text(),"beta"))][1]/title/text()' 2>/dev/null | sed -e "s/[^\.0-9]//g"

