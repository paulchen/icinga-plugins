#!/bin/bash

grep updateVersion /home/paulchen/public_html/dokuwiki/doku.php|sed -e 's/^[^"]*"//;s/".*$//'

