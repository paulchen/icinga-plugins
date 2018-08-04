#!/bin/bash
ls /opt/apache-tomee/webapps/gitbucket/WEB-INF/lib/gitbucket*|sed -e "s/^.*-//;s/\.jar//"


