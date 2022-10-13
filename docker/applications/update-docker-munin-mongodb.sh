#!/bin/bash

sudo -u paulchen /opt/docker-munin-mongodb/deploy.sh --no-systemd

systemctl restart docker-munin-mongodb

