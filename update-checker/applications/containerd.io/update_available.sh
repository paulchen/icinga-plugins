#!/bin/bash

apt-cache policy containerd.io | grep 'Candidate' | sed -e 's/.*: //'


