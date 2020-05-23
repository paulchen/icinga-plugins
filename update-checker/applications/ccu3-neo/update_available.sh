#!/bin/bash
wget "https://www.mediola.com/wp-content/sub-projects/helpdesk/data/downloads.json?_=`date +%s`000" -q -O - | python3 -c "import sys, json; print(json.load(sys.stdin)['de']['software']['neoserver']['current']['info']['version'])"

