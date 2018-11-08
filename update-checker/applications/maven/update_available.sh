#!/bin/bash

wget https://maven.apache.org/download.cgi -q -O -|grep Downloading|sed -e 's/^.*Maven //;s/<.*$//'

