#!/bin/bash
echo df | sftp u55033@u55033.your-backup.de 2> /dev/null | tail -n 1 > /tmp/ftp-space
TOTAL=`cat /tmp/ftp-space |tr -s " " ":"|cut -d ":" -f 2`
FREE=`cat /tmp/ftp-space |tr -s " " ":"|cut -d ":" -f 4`
mkdir -p /etc/ftp-space
echo $TOTAL > /etc/ftp-space/total
echo $FREE > /etc/ftp-space/free
chown -R nagios:nagios /etc/ftp-space

