#!/bin/bash

usage() {
	echo "Usage: check_cert.sh -H <host> -p <port> -w <days> [-d]" >&2
	exit 3
}

cleanup() {
	rm -f $CERTFILE
	rm -f $DATAFILE
	rm -f $DOMAINSFILE
	rm -f $RAWFILE

	rmdir $CERTDIR
}


DEBUG=0
while getopts ":H:p:w:d" opt; do
	case $opt in
		H)
			HOST=$OPTARG
			;;

		p)
			PORT=$OPTARG
			;;

		w)
			WARNING_DAYS=$OPTARG
			;;

		d)
			DEBUG=1
			;;

		\?)
			usage
			;;
	esac
done

if [ "$HOST" == "" ] || [ "$PORT" == "" ] || [ "$WARNING_DAYS" == "" ]; then
	usage
fi

CERTDIR=/tmp/check_cert_$RANDOM

RAWFILE=$CERTDIR/rawdata
CERTFILE=$CERTDIR/cert.pem
DATAFILE=$CERTDIR/certdata
DOMAINSFILE=$CERTDIR/certdomains

mkdir -p $CERTDIR

# TODO check every IP address
# TODO support IPv6
IP=`dig -t A +short $HOST|tail -n 1`
# echo openssl s_client -connect $IP:$PORT -servername $HOST -showcerts
#exit 2
COUNT=0
while [ "$COUNT" -le "3" ]; do
	echo '' | timeout 5 openssl s_client -connect $IP:$PORT -servername $HOST -showcerts > $RAWFILE 2>&1 && break
	COUNT=$((COUNT+1))
done

if [ "$COUNT" -eq "3" ]; then
	echo "Unable to connect to $IP:$PORT"
	cleanup
	exit 3
fi

ERROR=0
cat $RAWFILE | openssl x509  > $CERTFILE || ERROR=1
if [ "$ERROR" -ne "0" ]; then
	echo "Unable to process certificate for $IP:$PORT (error code $ERROR), data in $CERTDIR"
#	cleanup
	exit 3
fi

STARTTIMESTAMP=`date --date="$(openssl x509 -in $CERTFILE -noout -startdate | cut -d= -f 2)" +%s`
ENDTIMESTAMP=`date --date="$(openssl x509 -in $CERTFILE -noout -enddate | cut -d= -f 2)" +%s`

NOW=`date +%s`

FUTURE=$((NOW+WARNING_DAYS*86400))

openssl x509 -in $CERTFILE -text -noout > $DATAFILE

grep 'Subject: CN=' $DATAFILE|sed -e "s/^.*=//g" > $DOMAINSFILE

WTF=`grep -A 1  'X509v3 Subject Alternative Name' $DATAFILE|tail -n 1`

for a in $WTF; do echo $a|sed -e "s/^DNS://g;s/,.*$//g"; done >> $DOMAINSFILE

COUNT=`grep -c "^$HOST$" $DOMAINSFILE`

EXITCODE=0
if [ "$COUNT" -eq 0 ]; then
	echo "Certificate is not valid for hostname $HOST"
	EXITCODE=2
elif [ "$NOW" -le "$STARTTIMESTAMP" ]; then
	echo "Certificate for $HOST is not yet valid"
	EXITCODE=2
elif [ "$NOW" -gt "$ENDTIMESTAMP" ]; then
	echo "Certificate for $HOST has expired"
	EXITCODE=2
elif [ "$FUTURE" -gt "$ENDTIMESTAMP" ]; then
	echo "Certificate for $HOST will expire in less than $WARNING_DAYS days"
	EXITCODE=1
else
	echo "Certificate for $HOST is valid and will not expire within $WARNING_DAYS days"
fi

if [ "$DEBUG" -eq 0 ]; then
	cleanup
fi

exit $EXITCODE

