#!/usr/bin/env bash

set -e

# Script Working Directory
TWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

. "$TWD/../lib/test-helpers.sh"

SCRIPT="$ROOT/jehon-base-minimal/usr/bin/jh-disk-space-test.sh"

capture run "$SCRIPT" / 1
assert_captured_success "should be successfull"

capture run "$SCRIPT" / 100000
assert_captured_failure "should be failing"
