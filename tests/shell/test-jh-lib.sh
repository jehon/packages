#!/usr/bin/env bash

set -o errexit

# Script Working Directory
TWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

# shellcheck source=../lib/test-helpers.sh
. "$TWD/../lib/test-helpers.sh"

#
# We need to re-import it for JH_SWD to be set correctly
#
# shellcheck source=../../usr/bin/jh-lib
. "$JH_ROOT/usr/bin/jh-lib"

assert_equals "JH_SWD" "$TWD" "$JH_SWD"
assert_equals "ROOT" "$JH_ROOT" "$JH_PKG_FOLDER"

assert_equals "jhGetConfigFile from packages" \
    "$JH_ROOT/usr/share/jehon/etc/npmrc" \
    "$(jhGetConfigFile "/etc/npmrc")"

assert_equals "jhGetConfigFile from etc" \
    "/etc/host" \
    "$(jhGetConfigFile "/etc/host")"

assert_equals "jhGetSharedFile from share" \
    "$JH_ROOT/usr/share/jehon/hyperv" \
    "$(jhGetSharedFile "/usr/share/jehon/hyperv")"

assert_file_exists "/etc/hosts"

if ok_ko "test" true >/dev/null 2>&1; then ok "test ok_ko true"; else false; fi
if ok_ko "test" false >/dev/null 2>&1; then false; else ok "test ok_ko false"; fi
if ok_ko "test" ls /etc >/dev/null 2>&1; then ok "test ok_ko ls /etc"; else false; fi
if ok_ko "test" ls /anything >/dev/null 2>&1; then false; else ok "test ok_ko ls /anything"; fi
