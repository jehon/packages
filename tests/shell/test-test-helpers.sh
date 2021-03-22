#!/usr/bin/env bash

set -e

# Script Working Directory
SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

capture "ls /" ls /
assert_captured_success "should be successfull"
assert_captured_output_contains "contains at least 'etc'" "etc"

assert_success "ls /etc" ls /etc
assert_captured_output_contains "at least 'hosts'" "hosts"

capture "exit 0" exit 0
assert_captured_success

capture "exit 1" exit 1
assert_captured_failure

assert_file_exists "/etc/hosts"
# assert_file_exists "/etc/cron.daily/xxx"

echo "Test done"