#!/usr/bin/env bash

# Script Working Directory
SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

JH_ROOT="$( dirname "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )"

. $JH_ROOT/synology/scripts/rsync-parse-command.sh

CFG="tests/data/vf.json"

export USER="myuser"
export TS="mytimestamp"
export KEY="mykey"

checkShouldFail() {
    capture "$1" parseCommand "$CFG" "$2"
    assert_captured_failure "Should exit when running: $2"
    capture_empty
}

checkMatch() {
    # $: name of test
    # $: source command
    # $: target command
    capture "$1" parseCommand "$CFG" "$2"
    assert_captured_success "Should succeed: $1 with '$2'" "$?"

    N=$(parseCommand "$CFG" "$2")
    assert_equals "$1" "$3" "$N"

    log_success "Test $1: parsing $2 ok"
}

checkShouldFail "without an rsync command" \
    "ls /truc"

checkMatch "parser general" \
	"rsync --server -r . /brol" \
    "/bin/overriden/rsync --server -r . /target/brolmachin"

checkShouldFail "with backup should fail" \
    "/bin/overriden/rsync --server -r --backup-dir /test . /brol"

checkShouldFail "with invalid config: no match" \
	"rsync --server -r . /does-not-match"

checkShouldFail "with invalid config: multiple match" \
	"rsync --server -r . /synology"

checkMatch "with backup" \
    "rsync --server --sender -r . /truc" \
    "/bin/overriden/rsync --server --sender -r --backup --backup-dir /target/backup . /target/trucmachin"

checkMatch "with read-only ok" \
    "rsync --server --sender -r . /ro" \
    "/bin/overriden/rsync --server --sender -r . /target/ro"

checkMatch "with writable destination" \
    "rsync --server -r . /brol" \
    "/bin/overriden/rsync --server -r . /target/brolmachin"

checkShouldFail "with read only but asking rw" \
    "rsync --server -r . /ro"

checkShouldFail "with updir reference" \
    "rsync --server -r . /source/.."

checkMatch "with tokens" \
    "rsync --server -r . /interpreted" \
    "/bin/overriden/rsync --server -r --backup --backup-dir /target/mykey/myuser/backup/mytimestamp . /target/mykey/myuser/and/mytimestamp"

#
# Real live examples
#

checkMatch "real example 1" \
	"rsync --server -logtpre.iLsfxC . /synology/hosthooks" \
    "/bin/overriden/rsync --server -logtpre.iLsfxC . /volume3/scripts/hosthooks"

checkMatch "real example 2" \
	"/bin/rsync --server -lOtre.iLsfxC --log-format=%i --max-delete=1000 --delete-excluded --modify-window=2 . /synology/rootssh" \
	"/bin/overriden/rsync --server -lOtre.iLsfxC --log-format=%i --max-delete=1000 --delete-excluded --modify-window=2 . /root/.ssh"

checkMatch "real example 3" \
 		"/bin/rsync --server -lOtrxe.iLsfxC --log-format=%i --max-size 4000000000 --delete-excluded --modify-window=2 . /synology/hosthooks" \
 		"/bin/overriden/rsync --server -lOtrxe.iLsfxC --log-format=%i --max-size 4000000000 --delete-excluded --modify-window=2 . /volume3/scripts/hosthooks"
