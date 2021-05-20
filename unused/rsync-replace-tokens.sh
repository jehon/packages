#!/usr/bin/env bash

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. "$SWD/rsync-lib.sh"

replaceTokens() {
    # 1: template
    # in env: all what is necessary
    #   user      => USER
    #   timestamp => TS
	#   key       => KEY
    #

    RES="$1"
    RES="${RES/\{user\}/$USER}"
    RES="${RES/\{timestamp\}/$TS}"
    RES="${RES/\{key\}/$KEY}"

    echo "$RES"
}
