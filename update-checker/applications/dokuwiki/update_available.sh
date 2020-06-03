#!/bin/bash
wget -q -O - https://rueckgr.at/~paulchen/dokuwiki_updates.php | xpath -e '//item[1]/description/text()' 2>/dev/null |grep "update_check" |sed -e 's/^[^\[]*\[//;s/\].*$//'

#| sed -E "s/^.*([0-9]{4}-[0-9]{2}-[0-9]{2}[^ ]*)/\1/g;s/\.$//"

