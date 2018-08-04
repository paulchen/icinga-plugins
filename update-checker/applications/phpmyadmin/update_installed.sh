#!/bin/bash

grep Version /var/www/default/web/pma/README|sed -e "s/^.* //"

