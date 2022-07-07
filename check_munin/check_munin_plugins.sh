#!/bin/bash

# for sudo to work you need to add a line in /etc/sudoers like:
# 
# icinga ALL=(ALL:ALL) NOPASSWD: /usr/sbin/munin-run-custom

cd /etc/munin/plugins
error=0
for plugin in *; do
	plugin_error=0
	sudo munin-run --ignore-systemd-properties --debug "$plugin" > /dev/null 2>&1 || plugin_error=1
	if [ "$plugin_error" -eq "1" ]; then
		error=1
		echo "Broken plugin: $plugin"
	fi
done

if [ "$error" -ne "0" ]; then
	exit 2
else
	echo "All plugins fine"
fi

