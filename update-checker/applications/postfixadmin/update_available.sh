#!/bin/bash

../../lib/github_release.sh postfixadmin/postfixadmin | sed -e 's/^postfixadmin-//' | sed -e 's/\.0$//'


