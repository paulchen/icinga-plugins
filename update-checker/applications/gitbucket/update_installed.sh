#!/bin/bash
ls /opt/apache-tomcat/webapps/gitbucket/WEB-INF/lib/gitbucket*|sed -e "s/^.*-//;s/\.jar//"


