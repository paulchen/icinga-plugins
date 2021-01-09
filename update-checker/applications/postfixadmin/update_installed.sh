#!/bin/bash

grep "\\$CONF['version']" /var/www/postfixadmin/config.inc.php |sed -e "s/^.*=//;s/^[^']*'//;s/'.*$//"

