#!/usr/bin/env bash

export PKG_NAME="jehon-base-minimal"

#
# SWD (Script Working Directory)
#   where the script currently execute
#
#   /usr/(s)bin
#   ~/src/packages/$PKG_NAME/usr/(s)bin
#
SWD="$( realpath "$( dirname "${BASH_SOURCE[1]}" )" )"

#
# Where is this file located ?
#
SELF="$( realpath "${BASH_SOURCE[0]}" )"

#
#
# Where is the package source file located
#
#
PKG_FOLDER="$(dirname "$(dirname "$(dirname "$(dirname "$SELF" )" )" )" )"
# If SELF is as /usr/bin, then it is not under package source
if [ "$PKG_FOLDER" = "/" ]; then
    PKG_FOLDER=""
fi

#
# Get the config file location
#
#   /usr/(s)bin => $1
#   ~/src/packages/... => packages/$PKG_NAME/usr/share/$PKG_NAME/etc/$(basename)
#
#
jhGetConfigFile() {
    if [ -z "$PKG_FOLDER" ]; then
        echo "$1"
        return 0
    fi

    CONF_DIR="$PKG_FOLDER/$PKG_NAME/usr/share/$PKG_NAME/etc"
    if [ -a "$CONF_DIR/$(basename "$1" )" ]; then
        echo "$CONF_DIR/$(basename "$1" )"
        return 0
    fi

    echo "$1"
    return 0
}

header() {
    if test -t 1 ; then
        echo -e "\e[93m$*\e[00m"
    else
        echo "* $*"
    fi
}

warning() {
    if test -t 1 ; then
        echo -e "\e[91m$*\e[00m"
    else
        echo "! $*"
    fi
}

ok_ko() {
    T1="$1"
    T2="$2"
    shift
    shift

    if [[ "$T1" == "$T2" ]] ; then
        ok "$@"
    else
        ko "$@"
    fi
}

ok() {
    if test -t 1 ; then
    	echo -e "\033[01;32m✓\033[0m $*"
    else
        echo "✓ $*"
    fi
}

ko() {
    if test -t 1 ; then
    	echo -e "\033[01;31m✗\033[0m $*"
    else
        echo "✗ $*"
    fi
}

export SWD
export PKG_FOLDER

export JH_SYNOLOGY_IP=192.168.1.9
