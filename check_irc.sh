#!/bin/bash

# for nagios-nrpe-server:
# command[check_ircd_v4_6667]=/opt/icinga/check_irc.sh 127.0.0.1 6667
# command[check_ircd_v6_6667]=/opt/icinga/check_irc.sh ::1 6667
# command[check_ircd_v4_6697]=/opt/icinga/check_irc.sh 127.0.0.1 6697 --ssl
# command[check_ircd_v6_6697]=/opt/icinga/check_irc.sh ::1 6697 --ssl

test_irc() {
	echo "NICK ircd$RANDOM"
	echo "USER monitor localhost localhost :"

	sleep 5

	echo "QUIT"
}

HOST=$1
PORT=$2

ERROR=0
SSL=""
if [ "$3" == "--ssl" ]; then
	SSL="--ssl"
fi
TEMP=`test_irc | ncat $SSL $HOST $PORT -i 2 -w 8 2> /dev/null | grep 'There are'` || ERROR=1

if [ "$ERROR" -ne 0 ]; then
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

