#!/usr/bin/env bash

# Script Working Directory
SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

ROOT="$( dirname "$( dirname "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )" )"
. $ROOT/synology/scripts/rsync-replace-tokens.sh

USER="myuser"
TS="mytimestamp"
KEY="mykey"

assert_equals "without token"     "/truc" "/truc"
assert_equals "with user"         "/truc/myuser"                 "$( replaceTokens "/truc/{user}" )"
assert_equals "with user"         "/truc/myuser/something"       "$( replaceTokens "/truc/{user}/something" )"
assert_equals "with key"          "/truc/mykey/something"        "$( replaceTokens "/truc/{key}/something" )"

assert_equals "with ts"            "/truc/mytimestamp"            \
	"$( replaceTokens "/truc/{timestamp}" )"

assert_equals "with user and ts"   "/truc/myuser/bla/mytimestamp" \
	"$( replaceTokens "/truc/{user}/bla/{timestamp}" )"

assert_equals "with key, user,ts"  "/truc/mykeymyuser/bla/mytimestamp" \
	"$( replaceTokens "/truc/{key}{user}/bla/{timestamp}" )"
