#!/usr/bin/env bash

if [[ ! -x /usr/bin/daemonize ]] || [[ ! -x /usr/bin/fc-list ]] ||[[ ! -r /usr/lib/systemd/user/dbus.service ]]; then
    echo "You should install these packages: daemonize dbus-user-session fontconfig"
    # sudo apt-get install -yqq daemonize dbus-user-session fontconfig
    read
    exit 1
fi

PID_SYSTEMD="$(pidof systemd)"
if [ -z "$PID_SYSTEMD" ]; then
    echo "Launching systemd"
    sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target
    while [[ -z "$PID_SYSTEMD" ]] ; do
        PID_SYSTEMD="$(pidof systemd)"
        sleep 0.1s
    done
fi

echo "Found: $PID_SYSTEMD"

if [ "$PID_SYSTEMD" != 1 ]; then
    exec sudo nsenter -t $(pidof systemd) -a su - $LOGNAME
else
    echo "Already in systemd = 1"
fi
# if ! nc -z 127.0.0.1 6001 ; then
#     echo "Need to start XServer"
#     "/mnt/c/Program Files/VcXsrv/xlaunch.exe" -run "C:\Users\jhn\Google Drive\Informatic\Softwares\config.xlaunch"
# fi

# export PATH="$HOME/src/packages/bin_wsl_2_win/:$PATH"
# export BROWSER=/home/jehon/src/packages/bin_wsl_2_win/vivaldi

# echo "Starting $*"
# DISPLAY=:1 "$@" &

