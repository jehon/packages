#!/usr/bin/env bash

set -o errexit

# Script Working Directory
SWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

ROOT="$(dirname "$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")")"

CONSTANT_RUN_TEST="i_am_in_docker"

if [ "$1" == "$CONSTANT_RUN_TEST" ]; then
    log_success "docker started"

    assert_equals "check username" "$(whoami)" "root"

    truncate --size=0 /etc/apt/apt.conf.d/99-test-packages.conf

    # Allow unsigned repositories just in case
    echo "APT::Get::AllowUnauthenticated \"true\";" >>/etc/apt/apt.conf.d/99-test-packages.conf
    echo "Acquire::AllowInsecureRepositories \"true\";" >>/etc/apt/apt.conf.d/99-test-packages.conf

    log_message "Level-up docker image - start"
    assert_success "Level-up docker image - apt-get update" apt update -y
    assert_success "Level-up docker image - apt-get install" apt install -y lsb-release gpg ca-certificates wget
    log_message "Level-up docker image - done"

    export JH_LOCAL_STORE="/app/repo/"
    # assert_success "start script"
    /app/start

    assert_file_exists "/etc/apt/sources.list.d/jehon-github.list"
    assert_file_exists "/etc/cron.daily/jh-backup-computer"

    ok_ko "sshd config applied" bash -c "sshd -T | grep 'permitrootlogin without-password' >/dev/null"
    ok_ko "ssh_config applied" bash -c "ssh -G synology-e | grep 'jehon.synology.me' >/dev/null"

    exit $?
fi

assert_file_exists "$ROOT/repo/jehon.deb"

echo "Launching docker"
# SCRIPT_NAME=""
docker run -v "$(realpath "$ROOT"):/app:ro" -w "/app" ubuntu:latest "$0" "$CONSTANT_RUN_TEST"

echo "Finished docker"
