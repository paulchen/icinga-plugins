#!/bin/bash
DIRECTORY=`dirname "$0"`
LOGFILE=/var/log/update-checker.log
STATUSFILE="$DIRECTORY/update.status"

_log() {
	DATE=`date --rfc-3339=seconds`
	SEVERITY=$1
	LOG_MESSAGE=$2

	echo $DATE $SEVERITY $LOG_MESSAGE >> $LOGFILE
}

log() {
	_log "INFO" "$1"
}

log_error() {
	_log "ERROR" "$1"
	echo "$1"
}

cd "$DIRECTORY"
if [ ! -d applications ]; then
	log_error "Directory applications does not exist"
	exit 1
fi

log "Application startup"

DO_CHECK=0
if [ ! -e "$STATUSFILE" ]; then
	log "$STATUSFILE does not exist, performing check"
	DO_CHECK=1
elif test "`find $STATUSFILE -mmin +150`"; then
	log "$STATUSFILE is older than 150 minutes, performing check"
	DO_CHECK=1
fi

if [ "$DO_CHECK" -eq "0" ]; then
	log "Last check was less than 150 minutes ago, exiting"
	exit 0
fi

cd applications

STATUS=0
MESSAGE=""
for DIR in */; do
	# remove trailing slash
	DIR="${DIR/\//}"

	cd "$DIR"
	log "Processing directory $DIR"

	if [ -f ignore ]; then
		cd ..
		continue
	fi

	if [ ! -f update_available.sh ]; then
		log_error "File applications/$DIR/update_available.sh does not exist"
		exit 2
	fi

	if [ ! -f update_installed.sh ]; then
		log_error "File applications/$DIR/update_installed.sh does not exist"
		exit 3
	fi

	rm -f /tmp/update_available.log
	rm -f /tmp/update_installed.log

	UPDATE_FAIL=0
	for a in 1 2 3; do
		FAIL=0
		AVAILABLE=`./update_available.sh` 2> /tmp/update_available.log || FAIL=1

		log "Output from update_available.sh: $AVAILABLE"

		if [ "$FAIL" -eq "0" ]; then
			if [ "$AVAILABLE" != "" ]; then
				break;
			fi
		fi

		FAIL=1
		log_error "Error while checking available version for $DIR (iteration $a)"
	done
	UPDATE_FAIL=$FAIL
	
	if [ "$UPDATE_FAIL" -eq "0" ]; then
		for a in 1 2 3; do
			FAIL=0
			INSTALLED=`./update_installed.sh` 2> /tmp/update_installed.log || FAIL=1

			log "Output from update_installed.sh: $INSTALLED"

			if [ "$FAIL" -eq "0" ]; then
				if [ "$INSTALLED" != "" ]; then
					break;
				fi
			fi

			FAIL=1
			log_error "Error while checking installed version for $DIR (iteration $a)"
		done
	fi
	if [ "$UPDATE_FAIL" -eq "0" ]; then
		UPDATE_FAIL=$FAIL
	fi


	if [ "$UPDATE_FAIL" -ne "0" ]; then
		log_error "Error updating versions for application $1"

		log_error "Error output from update_available.sh: "
		cat /tmp/update_available.log >> $LOGFILE

		if [ -f /tmp/update_installed_log ]; then
			log_error "Error output from update_installed.sh: "
			cat /tmp/update_installed.log >> $LOGFILE
		else
			log_error "Installed version not checked"
		fi

		rm -f /tmp/update_available.log
		rm -f /tmp/update_installed.log

		exit 4
	fi

	rm -f /tmp/update_available.log
	rm -f /tmp/update_installed.log

	if [ "$AVAILABLE" == "$INSTALLED" ]; then
		APP_MESSAGE="$DIR - OK ($AVAILABLE);"
	else
		APP_MESSAGE="$DIR - update available ($INSTALLED -> $AVAILABLE);"
		STATUS=2
	fi

	MESSAGE="$MESSAGE $APP_MESSAGE"

	log "Resulting message: $APP_MESSAGE"
	log "Processing directory $DIR completed"

	cd ..
done

log "Full message: $MESSAGE"
log "Execution completed"

cd ..

rm -f "$STATUSFILE"
echo $STATUS >> "$STATUSFILE"
if [ "$MESSAGE" == "" ]; then
	MESSAGE="No applications checked"
fi

echo $MESSAGE >> "$STATUSFILE"

