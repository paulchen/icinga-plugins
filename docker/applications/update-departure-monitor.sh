#!/bin/bash

sudo -u paulchen /opt/departure-monitor/misc/deploy.sh --no-systemd

systemctl restart departure-monitor-dev
systemctl restart departure-monitor

