#!/bin/bash

apt-cache policy docker-ce | grep 'Installed' | sed -e 's/.*: //'


