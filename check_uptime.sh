#!/bin/bash

usage() {
	echo "Usage: check_uptime.sh -w <minutes> -c <minutes>" >&2
	exit 3
}

while getopts "w:c:" opt; do
	case $opt in
		w)
			WARNING_MINUTES=$OPTARG
			;;

		c)
			CRITICAL_MINUTES=$OPTARG
			;;

		\?)
			usage
			;;
	esac
done

if [ "$WARNING_MINUTES" == "" ] || [ "$CRITICAL_MINUTES" == "" ]; then
	usage
fi

UPTIME=`cat /proc/uptime|cut -d " " -f 1| sed -e "s/\..*//g"`
UPTIME_MINS=$((UPTIME/60))

if [ "$UPTIME_MINS" -gt "$CRITICAL_MINUTES" ]; then
	echo "CRITICAL: Uptime $UPTIME_MINS minutes"
	exit 2
fi

if [ "$UPTIME_MINS" -gt "$WARNING_MINUTES" ]; then
	echo "WARNING: Uptime $UPTIME_MINS minutes"
	exit 1
fi

echo "OK: Uptime $UPTIME_MINS minutes"

