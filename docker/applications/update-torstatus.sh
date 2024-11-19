#!/bin/bash

USER=`whoami`

if [ "$USER" == "paulchen" ]; then
	set -a
	source /etc/default/torstatus
	set +a

	cd /var/www/TorNetworkStatus

	# for some reason, "docker compose build --pull" doesn't pull all images as expected
	IMAGES1=`grep image docker-compose.yml |sed -e 's/^\s*image:\s*//'`
	IMAGES2=`find . -iname Dockerfile 2>/dev/null -exec grep -i from {} \;|sed -e 's/^\s*from\s*//i'`

	for IMAGE in $IMAGES1 $IMAGES2; do
		docker pull $IMAGE
	done

	docker compose build --no-cache || exit 1
else
	sudo -u paulchen "$0" || exit 1

	systemctl restart torstatus || exit 1
fi


