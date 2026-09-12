#!/bin/bash

IDS=`docker ps -q`

TOTAL=0
declare -A COUNTS

for ID in $IDS; do
	TOTAL=$((TOTAL+1))

	# Possible values include:
	#   healthy, unhealthy, starting
	# Containers without a HEALTHCHECK are counted as "none".
	HEALTH=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$ID")
	COUNTS["$HEALTH"]=$(( ${COUNTS["$HEALTH"]:-0} + 1 ))
done

echo -n "Total containers: $TOTAL"

# Sort the state names for deterministic output.
for STATE in $(printf '%s\n' "${!COUNTS[@]}" | sort); do
	echo -n "; $STATE: ${COUNTS[$STATE]}"
done
echo ""

# Exit status:
#   0 = all containers healthy
#   2 = at least one unhealthy container
#   1 = no unhealthy containers, but at least one is not healthy
if [ "${COUNTS[unhealthy]:-0}" -gt 0 ]; then
	exit 2
elif [ "${COUNTS[healthy]:-0}" -eq "$TOTAL" ]; then
	exit 0
else
	exit 1
fi

