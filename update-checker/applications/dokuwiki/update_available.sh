#!/bin/bash

php /opt/admin-tools/dokuwiki_updates.php | xpath -e '//item[not(contains(description/text(), "candidate"))][1]/description/text()' 2>/dev/null|grep "update_check" |sed -e 's/^[^\[]*\[//;s/\].*$//'

#| sed -E "s/^.*([0-9]{4}-[0-9]{2}-[0-9]{2}[^ ]*)/\1/g;s/\.$//"

