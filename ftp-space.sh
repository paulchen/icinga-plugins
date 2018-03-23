#!/bin/bash
c=0
while [ true ]; do
	echo df | sftp u170766@u170766.your-backup.de 2> /dev/null | tail -n 1 > /tmp/ftp-space
	ERROR=${PIPESTATUS[1]}
	if [ "$ERROR" -eq "0" ]; then
		break
	fi
	c=$((c+1))
	if [ "$c" -ge "3" ]; then
		exit 1
	fi
	echo "Error while getting FTP storage space information, retrying in 60 seconds..." 1>&2
	sleep 60
	echo "Retrying..." 1>&2
done

TOTAL=`cat /tmp/ftp-space |tr -s " " ":"|cut -d ":" -f 2|sed -e "s/ //g"`
FREE=`cat /tmp/ftp-space |tr -s " " ":"|cut -d ":" -f 4|sed -e "s/ //g"`
mkdir -p /etc/ftp-space
echo $TOTAL > /etc/ftp-space/total
echo $FREE > /etc/ftp-space/free
chown -R nagios:nagios /etc/ftp-space
rm /tmp/ftp-space

