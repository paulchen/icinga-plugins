#!/bin/bash

apt-cache policy docker-ce | grep 'Candidate' | sed -e 's/.*: //'


