#!/usr/bin/env bash

set -e

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. $SWD/../lib/test-helpers.sh

JH_ROOT="$( dirname "$( dirname "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )" )"
#. $JH_ROOT/synology/scripts/rsync-parse-command.sh

test_capture_empty

test_capture "run successfull" jh-run-and-capture bash -c "echo coucou"
assert_captured_success "Should success"
assert_captured_output_contains "run failure show command" "echo coucou"
# assert_true "Output only ok" "" "$JH_TEST_CAPTURED_OUTPUT"

test_capture "run failure" jh-run-and-capture bash -c "echo coucou; nothing"
assert_captured_failure "Shoud fail"
assert_equals "run failure exit code" "$JH_TEST_CAPTURED_EXITCODE" "127"
assert_captured_output_contains "run failure show command" "echo coucou; nothing"
assert_captured_output_contains "run failure show stdout" "coucou"
assert_captured_output_contains "run failure show stderr" "nothing:"
