#!/usr/bin/env bash

if ! nc -z 127.0.0.1 6001 ; then
    echo "Need to start XServer"
    "/mnt/c/Program Files/VcXsrv/xlaunch.exe" -run "C:\Users\jhn\Google Drive\Informatic\Softwares\config.xlaunch"
fi

export PATH=~/src/packages/bin_wsl_2_win/:$PATH
export BROWSER=/home/jehon/src/packages/bin_wsl_2_win/vivaldi

echo "Starting $*"
DISPLAY=:1 "$@" &
