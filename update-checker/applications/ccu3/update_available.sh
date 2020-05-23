#!/bin/bash
wget https://www.eq-3.de/service/downloads.html -q -O - | grep 'CCU3 Firmware'  |head -n 1|sed -e "s/^.*CCU3 Firmware //;s/<.*//"

