#!/bin/bash

grep '^\$version' /var/www/postfixadmin/functions.inc.php |sed -e "s/^[^']*'//;s/'.*$//"

