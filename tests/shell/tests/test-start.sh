#!/usr/bin/env bash

set -e

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. $SWD/../lib/test-helpers.sh

ROOT="$( dirname "$( dirname "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )" )"
. $ROOT/synology/scripts/rsync-parse-command.sh

CONSTANT_RUN_TEST="i_am_in_docker"

if [ "$1" == "$CONSTANT_RUN_TEST" ]; then
    log_success "docker started"

    assert_equals "check username" "$(whoami)" "root"

    log_message "Level-up docker image - start"
    assert_success "Level-up docker image - apt-get update" apt update -y
    assert_success "Level-up docker image - apt-get install" apt install -y lsb-release gpg ca-certificates
    log_message "Level-up docker image - done"

    export LOCAL_STORE="/app/repo/"
    # assert_success "start script"
    /app/start

    exit $?
fi

echo "Launching docker"
# SCRIPT_NAME=""
docker run -v "$(realpath "$ROOT"):/app:ro" -w "/app" ubuntu:latest "$0" "$CONSTANT_RUN_TEST"

echo "Finished docker"
