#!/bin/bash

wget -q -O - http://repo.mongodb.org/apt/debian/dists/buster/mongodb-org/4.2/main/binary-amd64/Packages|grep -A 1 'Package: mongodb-org$' |grep Version|sed -e 's/Version: //'|sort -V|tail -n 1


