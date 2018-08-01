#!/bin/bash
grep RCUBE_VERSION /var/www/mail/roundcube/program/lib/Roundcube/bootstrap.php |sed -e "s/^.* '//;s/'.*$//"


