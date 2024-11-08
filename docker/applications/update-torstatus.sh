#!/bin/bash

USER=`whoami`

if [ "$USER" == "paulchen" ]; then
	set -a
	source /etc/default/torstatus
	set +a

	cd /var/www/TorNetworkStatus

	docker compose build --pull --no-cache || exit 1
else
	sudo -u paulchen "$0" || exit 1

	systemctl restart torstatus || exit 1
fi


