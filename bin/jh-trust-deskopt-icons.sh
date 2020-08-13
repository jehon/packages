#!/usr/bin/env bash

gspid=$(pgrep "gnome-session")
dbsavn="DBUS_SESSION_BUS_ADDRESS"
dbsadd=""
dtdir="$HOME/Desktop"
dtfile=""
istrusted=0

echo "DESKTOP ICONS CONFIGURATION..."
if ! (( gspid )) ; then
	echo "GNOME session not found"
	exit 1
fi

dbsadd="$(grep -z "$dbsavn" "/proc/$gspid/environ")"
if [[ "$dbsadd" = "" ]]; then
	echo "environment variable '$dbsavn' not found"
	exit 1
fi

eval "export $dbsadd"
dtfile="$1"
istrusted=$(gio info "$dtfile" | awk '$1 == "metadata::trusted:" && $2 == "yes" {print 1 ; exit}')
if (( istrusted )) ; then
	echo "ALREADY TRUSTED  $dtfile"
	exit 0
fi

gio set "$dtfile" "metadata::trusted" yes
