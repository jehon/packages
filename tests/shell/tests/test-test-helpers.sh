#!/usr/bin/env bash

set -e

# Script Working Directory
TWD="$( dirname "${BASH_SOURCE[0]}" )"

. "$TWD/../lib/test-helpers.sh"

capture "ls /" ls /
assert_captured_success "should be successfull"
assert_captured_output_contains "contains at least 'etc'" "etc"

assert_success "ls /etc" ls /etc
assert_captured_output_contains "at least 'hosts'" "hosts"

capture "exit 0" exit 0
assert_captured_success

capture "exit 1" exit 1
assert_captured_failure

echo "Test done"