#!/bin/bash

IDS=`docker ps -q`

TOTAL=0
UNHEALTHY=0
UNHEALTHY_IDS=""
for ID in $IDS; do
	TOTAL=$((TOTAL+1))

	health=`docker inspect --format "{{.State.Health.Status }}" "$ID"`
	if [ "$health" != "healthy" ]; then
		UNHEALTHY=$((UNHEALTHY+1))
		NAME=`docker inspect --format "{{ .Name }}" "$ID"`
		UNHEALTHY_IDS="$UNHEALTHY_IDS\n$ID ($NAME)"
	fi
done

if [ "$UNHEALTHY" -eq "0" ]; then
	echo "All containers healthy; $TOTAL containers total"
else
	echo -e "$UNHEALTHY/$TOTAL container(s) unhealthy; ids of unhealthy containers:$UNHEALTHY_IDS"
	exit 2
fi

