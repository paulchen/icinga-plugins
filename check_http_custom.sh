#!/bin/bash

PROTOCOL="http"
HOST=""
IP=""
TIMEOUT=10
PORT=80
EXPECTED=200
IP46=""

while getopts ":H:I:p:e:t:s46u:" opt; do
	case $opt in
		s)
			PROTOCOL=https
			PORT=443
			;;

		H)
			HOST=$OPTARG
			;;

		I)
			IP=$OPTARG
			;;

		p)
			PORT=$OPTARG
			;;

		e)
			EXPECTED=$OPTARG
			;;

		t)
			TIMEOUT=$OPTARG
			;;

	
		4)
			IP46=-4
			;;

		6)
			IP46=-6
			;;

		u)
			URL=$OPTARG
			;;

		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 3
			;;

		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 3
			;;
	esac
done

#if [ "$IP46" == "-6" ]; then
	[[ "$HOST" =~ ":" ]] && HOST="[$HOST]"
#fi

if [ "$URL" == "" ]; then
	URL="$PROTOCOL://$HOST:$PORT"
fi

OPTIONS="$IP46 -t $TIMEOUT"

STATUS_CODE=$(/usr/bin/nice -n 19 /usr/bin/ionice -c3 wget $OPTIONS $URL -S -q -O /dev/null -U 'check_http_custom.sh' --no-check-certificate 2>&1|grep HTTP|tail -n 1|sed -e 's/^.*HTTP[^ ]* //;s/ .*$//')
if [ "$STATUS_CODE" == "" ]; then
	echo "Error fetching $URL"
	exit 2
fi

if [ "$STATUS_CODE" != "$EXPECTED" ]; then
	echo "Wrong status code: $STATUS_CODE, expected: $EXPECTED"
	exit 1
fi

echo "OK"
exit 0

