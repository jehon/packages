#!/usr/bin/env bash

# shellcheck source=../usr/bin/jh-lib
. jh-lib

echo "** Using systemd"

if [[ ! -x /usr/bin/daemonize ]] || [[ ! -x /usr/bin/fc-list ]] || [[ ! -r /usr/lib/systemd/user/dbus.service ]]; then
	echo "You should install these packages: daemonize dbus-user-session fontconfig"
	# sudo apt-get install -yqq daemonize dbus-user-session fontconfig
	read -r
	exit 1
fi

while true; do
	sleep 0.1s
	PID_SYSTEMD="$(pidof systemd)"
	echo "** Found: $PID_SYSTEMD"

	if [ -z "$PID_SYSTEMD" ]; then
		echo "Launching systemd"
		sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target
		while [[ -z "$PID_SYSTEMD" ]]; do
			# Wait for the service to start
			PID_SYSTEMD="$(pidof systemd)"
			sleep 0.1s
		done
	else
		# Check if we have one or more systemd

		PID1=$(echo "$PID_SYSTEMD" | cut -d ' ' -f 1)
		PID2=$(echo "$PID_SYSTEMD" | cut -d ' ' -f 2)

		if [ "$PID1" == "$PID2" ]; then
			# Only one value
			break
		fi

		# Clean up mutiples values
		echo "** Killing $PID1"
		# echo ""
		# cat /proc/$PID1/cmdline
		# echo ""
		kill "$PID1"
	fi
done

cat <<EOC >~/session-local.conf
<busconfig>
	<listen>tcp:host=localhost,port=0,family=ipv4</listen>
	<auth>ANONYMOUS</auth>
	<allow_anonymous/>
</busconfig>
EOC

#
# if ! nc -z 127.0.0.1 6001 ; then
#     echo "Need to start XServer"
#     "/mnt/c/Program Files/VcXsrv/xlaunch.exe" -run "C:\Users\jhn\Google Drive\Informatic\Softwares\config.xlaunch"
# fi
#

# export PATH="$HOME/src/packages/bin_wsl_2_win/:$PATH"
# export BROWSER=/home/jehon/src/packages/bin_wsl_2_win/vivaldi

# echo "Starting $*"
# DISPLAY=:1 "$@" &
# DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"
# echo "Initial display: $DISPLAY"

if [ "$PID_SYSTEMD" != 1 ]; then
	# exec: remplace the current shell with the rest of the command
	#   sudo: as root
	#      nsenter -t -a: switch namespace of pid
	#          su - $LOGNAME => but come back as user...
	#          runuser -u $LOGNAME => come back as user
	#              $@ => a potential command
	#
	#

	if [ -n "$1" ]; then
		# With a command
		echo "Launching command $*"
		exec sudo /usr/bin/nsenter -t "$(pidof systemd)" -a runuser -u "$LOGNAME" --whitelist-environment=DISPLAY "$@"
	else
		# Without a command (shell)
		exec sudo /usr/bin/nsenter -t "$(pidof systemd)" -a su --login "$LOGNAME" --whitelist-environment=DISPLAY
	fi
else
	echo "Already in systemd = 1"
fi
