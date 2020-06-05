#!/bin/bash

usage() {
	echo "Usage: check_certlist.sh -d <directory> -w <days> -c <days> [-g]" >&2
	exit 3
}

DEBUG=0
while getopts ":d:w:c:g" opt; do
	case $opt in
		d)
			DIRECTORY=$OPTARG
			;;

		w)
			WARNING_DAYS=$OPTARG
			;;

		c)
			CRITICAL_DAYS=$OPTARG
			;;

		g)
			DEBUG=1
			;;

		\?)
			usage
			;;
	esac
done

if [ "$DIRECTORY" == "" ] || [ "$WARNING_DAYS" == "" ] || [ "$CRITICAL_DAYS" == "" ]; then
	usage
fi

SCRIPT=/opt/check_ssl_cert/check_ssl_cert

STATUS=0
for FILE in $DIRECTORY/port_*; do
	if [[ $FILE =~ \.example$ ]]; then
		continue;
	fi

	PORT=`echo $FILE | sed -e "s/^.*_//g";`

	for HOST in `cat $FILE|grep -v '^#'`; do
		if [ "$DEBUG" -eq 1 ]; then
			echo Checking $HOST:$PORT...
		fi	
		RESULT=`bash $SCRIPT -H $HOST -p $PORT -w $WARNING_DAYS -c $CRITICAL_DAYS`
		ERRORCODE=$?
		if [ "$DEBUG" -eq 1 ]; then
			echo "Error Code: $ERRORCODE, $RESULT"
		fi	

		if [ "$ERRORCODE" -gt 0 ]; then
			if [ "$ERRORCODE" -gt "$STATUS" ]; then
				STATUS=$ERRORCODE
			fi

			echo -n "$HOST:$PORT - $RESULT; "
		fi
	done
done

if [ "$STATUS" -eq 0 ]; then
	echo "All certificates are valid"
fi

echo ""

exit $STATUS

