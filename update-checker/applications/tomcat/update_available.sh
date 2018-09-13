#!/bin/bash

wget -q -O - https://tomcat.apache.org/download-90.cgi|grep '#9\.0\.'|head -n 1|sed -e 's/^[^>]*>//;s/<.*//g'

