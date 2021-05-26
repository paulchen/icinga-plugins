#!/bin/bash

tcpdump -i any -n host pfclient-upload.planefinder.net >> /var/log/pfclient/tcpdump.log 2> /dev/null

