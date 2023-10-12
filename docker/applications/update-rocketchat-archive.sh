#!/bin/bash

sudo -u paulchen /opt/rocketchat-archive/misc/deploy.sh --no-systemd || exit 1

systemctl restart rocketchat-archive || exit 1

