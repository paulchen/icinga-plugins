#!/bin/bash

sudo -u paulchen /opt/departure-monitor/misc/deploy.sh --full-rebuild || exit 1

systemctl restart departure-monitor-dev || exit 1
systemctl restart departure-monitor || exit 1

