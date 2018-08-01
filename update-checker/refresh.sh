#!/bin/bash
DIRECTORY=`dirname "$0"`

cd "$DIRECTORY"
if [ ! -d applications ]; then
	echo "Directory applications does not exist"
	exit 1
fi

cd applications

STATUS=0
MESSAGE=""
for DIR in */; do
	# remove trailing slash
	DIR="${DIR/\//}"

	cd "$DIR"

	if [ ! -f update_available.sh ]; then
		echo "Directory applications/$DIR/update_available.sh does not exist"
		exit 2
	fi

	if [ ! -f update_installed.sh ]; then
		echo "Directory applications/$DIR/update_installed.sh does not exist"
		exit 3
	fi

	FAIL=0
	AVAILABLE=`./update_available.sh` || FAIL=1
	INSTALLED=`./update_installed.sh` || FAIL=1

	if [ "$FAIL" -ne "0" ]; then
		echo "Error updating versions for application $1"
		exit 4
	fi

	if [ "$AVAILABLE" == "$INSTALLED" ]; then
		MESSAGE="$MESSAGE $DIR - OK ($AVAILABLE);"
	else
		MESSAGE="$MESSAGE $DIR - update available ($INSTALLED -> $AVAILABLE);"
		STATUS=2
	fi

	cd ..
done

cd ..

rm -f update.status
echo $STATUS >> update.status
echo $MESSAGE >> update.status

