#!/bin/bash

sudo -u paulchen /opt/docker-munin-mongodb/deploy.sh --no-systemd || exit 1

systemctl restart docker-munin-mongodb || exit 1

