#!/bin/bash

sudo -u paulchen /opt/kotlin-rocket-bot/misc/deploy.sh --no-systemd || exit 1

systemctl restart kotlin-rocket-bot || exit 1

