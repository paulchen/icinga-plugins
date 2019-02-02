#!/bin/bash

wget -q -O - http://jdk.java.net/11/|grep version|head -n 1|sed -e "s/.*version //;s/<.*//g"

