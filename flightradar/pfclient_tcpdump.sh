#!/bin/bash

sleep 30

tcpdump -i any -n host pfclient-upload.planefinder.net >> /var/log/pfclient/tcpdump.log 2> /dev/null

