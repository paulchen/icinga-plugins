#!/bin/bash

/opt/admin-tools/docker-compose/nextcloud/build.sh || exit 1

systemctl restart nextcloud

