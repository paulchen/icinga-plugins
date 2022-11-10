#!/bin/bash

sudo -u paulchen /opt/kotlin-rocket-bot/misc/deploy.sh --no-systemd

systemctl restart kotlin-rocket-bot

