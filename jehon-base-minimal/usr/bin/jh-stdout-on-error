#!/usr/bin/env bash

set -e

#
# Loglevel can be:
#   0 - normal
#  10 - debug
#
if [ "$LOGLEVEL" = "" ]; then
    LOGLEVEL=0
fi

export CAPTURED_OUTPUT=""
export CAPTURED_EXITCODE=0

# while IFS= read -r line; do
#     CAPTURED_OUTPUT="$CAPTURED_OUTPUT\n$line"
# done

if [ -z "$1" ]; then
    echo "Usage: capture <command> [args]+"
    exit 255
fi

set +e
CAPTURED_OUTPUT="$( "$@" 2>&1 )"
CAPTURED_EXITCODE="$?"
set -e

if [[ $CAPTURED_EXITCODE -gt 0 ]]; then
    echo "$CAPTURED_OUTPUT"
fi

exit $CAPTURED_EXITCODE;
