#!/bin/bash
wget -q -O - https://roundcube.net/feeds/atom.xml | xpath -e '//entry[not(contains(title/text(),"beta")) and not(contains(title/text(),"RC")) and not(contains(title/text(),"Candidate"))][1]/title/text()' 2>/dev/null | sed -e "s/[^\.0-9]//g"

