#!/bin/bash

apt-cache policy containerd.io | grep 'Installed' | sed -e 's/.*: //'


