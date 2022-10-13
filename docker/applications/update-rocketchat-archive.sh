#!/bin/bash

sudo -u paulchen /opt/rocketchat-archive/misc/deploy.sh --no-systemd

systemctl restart rocketchat-archive

