#!/bin/bash

grep 'Apache Tomcat Version' /opt/apache-tomcat/RELEASE-NOTES |sed -e "s/[^0-9]//g"

