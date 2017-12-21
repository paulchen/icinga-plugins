#!/bin/bash

usage() {
	echo "Usage: check_certlist.sh -d <directory> -w <days> [-g]" >&2
	exit 3
}

DEBUG=0
while getopts ":d:w:g" opt; do
	case $opt in
		d)
			DIRECTORY=$OPTARG
			;;

		w)
			WARNING_DAYS=$OPTARG
			;;

		g)
			DEBUG=1
			;;

		\?)
			usage
			;;
	esac
done

if [ "$DIRECTORY" == "" ] || [ "$WARNING_DAYS" == "" ]; then
	usage
fi

DEBUGFLAG=""
if [ "$DEBUG" -eq 1 ]; then
	DEBUGFLAG="-d"
fi

SCRIPT=`dirname $0`/check_cert.sh

STATUS=0
for FILE in $DIRECTORY/port_*; do
	if [[ $FILE =~ \.example$ ]]; then
		continue;
	fi

	PORT=`echo $FILE | sed -e "s/^.*_//g";`

	for HOST in `cat $FILE`; do
		# TODO support IPv6
		IP=`dig -t A +short $HOST`
		if [ "$IP" == "" ]; then
#			echo "Skipping $HOST..."
			continue
		fi
		RESULT=`bash $SCRIPT -H $HOST -p $PORT -w $WARNING_DAYS $DEBUGFLAG`
		ERRORCODE=$?

		if [ "$ERRORCODE" -gt 0 ]; then
			if [ "$ERRORCODE" -gt "$STATUS" ]; then
				STATUS=$ERRORCODE
			fi

			echo "$HOST:$PORT - $RESULT"
		fi
	done
done

if [ "$STATUS" -eq 0 ]; then
	echo "All certificates are valid"
fi

exit $STATUS

