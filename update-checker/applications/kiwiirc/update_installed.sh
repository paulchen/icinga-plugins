#!/bin/bash

apt-cache policy kiwiirc|grep Installed:|sed -e 's/^.*: //'

