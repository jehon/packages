#!/usr/bin/env bash

case "$1" in
	"test" )
		RUNNING="$( sc.exe queryex "$2" | grep STATE | grep "RUNNING" )"
		if [ "$RUNNING" != "" ]; then
			# echo "Service is running"
			exit 0
		fi
		exit 1
		;;
	"start" | "stop" )
		echo "$1ing the service $2"
		powershell.exe "Start-Process powershell -Verb runAs -ArgumentList '-Command net $1 $2'"
		;;
	"waitstart" )
		if ! $0 test "$2" ; then
			$0 start "$2"
		fi
		;;
	* )
		echo "Specify action"
		;;
esac
