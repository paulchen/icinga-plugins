#!/bin/bash

# for nagios-nrpe-server:
# command[check_ircd_v4_6667]=/opt/icinga/check_irc.sh 127.0.0.1 6667
# command[check_ircd_v6_6667]=/opt/icinga/check_irc.sh ::1 6667
# command[check_ircd_v4_6697]=/opt/icinga/check_irc.sh 127.0.0.1 6697 --ssl
# command[check_ircd_v6_6697]=/opt/icinga/check_irc.sh ::1 6697 --ssl

ID=$RANDOM
test_irc() {
	echo "NICK ircd$1"
	echo "USER monitor 0 * Monitor"

	sleep 5

	echo "QUIT" 2>/dev/null
}

PROTOCOL="-4"
if [ "`echo $1|grep -c ':'`" -ne "0" ]; then
	PROTOCOL="-6"
fi
HOST=$1
PORT=$2

COMMANDLINE="nc $HOST $PORT -w 8"
if [ "$3" == "--ssl" ]; then
	if [ "$PROTOCOL" == "-6" ]; then
		COMMANDLINE="openssl s_client -connect [$HOST]:$PORT"
	else
		COMMANDLINE="openssl s_client -connect $HOST:$PORT"
	fi
fi
echo "$COMMANDLINE"
test_irc $ID | $COMMANDLINE > /tmp/check_irc_$ID
cat /tmp/check_irc_$ID
TEMP=`cat /tmp/check_irc_$ID | grep 'There are'`
rm -f /tmp/check_irc_$ID

if [ "$TEMP" == "" ]; then
	echo "Error while checking status of IRC server"
	exit 2
fi

USERS=`echo "$TEMP"|sed -e "s/^.*are //;s/ .*$//"`
INVISIBLES=`echo "$TEMP"|sed -e "s/^.*and //;s/ .*$//"`
SERVERS=`echo "$TEMP"|sed -e "s/^.*on //;s/ .*$//"`

WARNING=0
CRITICAL=0

if [ "$USERS" -gt 100 ]; then
	CRITICAL=1
elif [ "$USERS" -gt 80 ]; then
	WARNING=1
fi

if [ "$INVISIBLES" -gt 20 ]; then
	CRITICAL=1
elif [ "$INVISIBLES" -gt 15 ]; then
	WARNING=1
fi

if [ "$SERVERS" -ne 2 ]; then
	CRITICAL=1
fi

echo "Status: $USERS users, $INVISIBLES invisible, $SERVERS servers"

if [ "$CRITICAL" -ne 0 ]; then
	exit 2
elif [ "$WARNING" -ne 0 ]; then
	exit 1
fi

