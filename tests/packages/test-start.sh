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

    sshd_version="$(ssh -V 2>&1 | awk -F '[^0-9.]+' '{print $2}')"
    ok_ko "Sshd version is above 8.1 (detected: $sshd_version)" bash -c "[[ \"$sshd_version\" > \"8.1\" ]]"

    ok_ko "ssh_config applied" bash -c "ssh -G synology-e | grep 'jehon.synology.me' >/dev/null"

    exit $?
fi

assert_file_exists "$ROOT/repo/jehon.deb"

test_in_docker() {
    echo "**************************************"
    echo "***                                ***"
    echo "*** Launching docker $1"
    echo "***                                ***"
    echo "**************************************"

    set -o pipefail
    docker run --rm -v "$(realpath "$ROOT"):/app:ro" -w "/app" "$1" "$0" "$CONSTANT_RUN_TEST" | jh-tag-stdin "$1"
    ok "docker test $1"
}

test_in_docker "debian:stable"
test_in_docker "ubuntu:latest"

ok "Finished docker's tests"
