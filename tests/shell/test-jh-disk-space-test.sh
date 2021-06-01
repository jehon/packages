#!/usr/bin/env bash

set -o errexit

# Script Working Directory
SWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

SCRIPT="$JH_ROOT/jehon-base-minimal/usr/bin/jh-disk-space-test.sh"

test_capture run "$SCRIPT" / 1
assert_captured_success "should be successfull"

test_capture run "$SCRIPT" / 100000
assert_captured_failure "should be failing"
