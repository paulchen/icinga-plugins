#!/bin/bash

/opt/apache-maven/bin/mvn --version|head -n 1|sed -e "s/Apache Maven //;s/ .*//"

