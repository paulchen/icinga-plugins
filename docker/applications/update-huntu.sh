#!/bin/bash

docker pull php:8.2-apache-bookworm || exit 1

update() {
	NAME="$1"

	if [ ! -e "/var/www/$NAME/docker/build.sh" ]; then
		return
	fi

	sudo -u paulchen "/var/www/$NAME/docker/build.sh" --full-rebuild "$NAME" || exit 1
	systemctl restart "$NAME" || exit 1
}

update huntu-dev
update huntu

if [ "$1" == "-f" ]; then
	update huntu22
	update huntu19
	update huntu18
	update huntu17
	update huntu16
	update huntu15
	update huntu14
	update huntu13
	update huntu12
	update huntu11
	update huntu10
	update huntu09
fi

