#!/usr/bin/env bash

set -e

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. $SWD/../lib/test-helpers.sh

ROOT="$( dirname "$( dirname "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )" )"
. $ROOT/synology/scripts/rsync-parse-command.sh

testSuccess() {
    jh-stdout-on-error.sh "$@"

    TITLE="$1"
    shift

    OUTPUT=$( jh-stdout-on-error.sh "$@" )
    RES=$?
    assert_equals "$TITLE - with success" 0 "$RES"
    assert_equals "$TITLE - without output" "" "$OUTPUT"
}

assert_equals "on success: no output"  "" "$( jh-stdout-on-error.sh bash -c "echo coucou" )"
assert_success "on success: exit code 0" jh-stdout-on-error.sh bash -c "echo coucou"

assert_equals "on failure: output" "testresult" "$( jh-stdout-on-error.sh bash -c "echo testresult; false" )"
assert_success "on failure: exit code > 0" bash -c "! jh-stdout-on-error.sh false"

assert_equals "on failure: output with multiple lines" "\n1\n2\n3" "$( bash -c "echo \"\n1\n2\n3\" && false" )"
