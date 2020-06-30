#!/bin/bash

wget 'https://kiwiirc.com/downloads/' -q -O -|grep 'Download: Kiwi IRC - 64bit'|grep amd64\.deb|sed -e 's/^.*kiwiirc_//;s/_.*$//'

