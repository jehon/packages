#!/usr/bin/env bash

set -e

# Script Working Directory
TWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

# shellcheck source=../lib/test-helpers.sh
. "$TWD/../lib/test-helpers.sh"

#
# We need to re-import it for SWD to be set correctly
#
# shellcheck source=../../jehon-base-minimal/usr/bin/jh-lib.sh
. "$ROOT/jehon-base-minimal/usr/bin/jh-lib.sh"

assert_equals "SWD" "$TWD" "$SWD"
assert_equals "ROOT" "$ROOT" "$PKG_FOLDER"

assert_equals "jhGetConfigFile from packages" \
    "$ROOT/jehon-base-minimal/usr/share/jehon-base-minimal/etc/npmrc" \
    "$( jhGetConfigFile "/etc/npmrc" )"

assert_equals "jhGetConfigFile from etc" \
    "/etc/host" \
    "$( jhGetConfigFile "/etc/host" )"

assert_file_exists "/etc/hosts"