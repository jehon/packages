#!/usr/bin/env bash

# Script Working Directory
SWD="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

PATCH="$JH_TEST_TMP/jh-patch-file-patch.txt"
TARGET="$JH_TEST_TMP/jh-patch-file-original.txt"
BACKUP="$TARGET-before-patch-file"

(
	# Setup the source file
	echo "This is the file"
	echo "This is the end"
) >"$TARGET"

cat <<-EOF >"$PATCH"
	#
	# Tag: test
	# File: $TARGET
	#
	#

	Hello world
EOF

test_capture "jh-patch-file-patch" "$JH_ROOT"/usr/bin/jh-patch-file "$PATCH"
assert_captured_success "should be successfull"

test_capture "jh-patch-file-patch read" cat "$TARGET"
assert_captured_output_contains "Tag:[[:space:]]+test"
assert_captured_output_contains "File:[[:space:]]+$TARGET"
test_capture_empty
assert_true "The backup file $BACKUP exists" "$([[ -r "$BACKUP" ]])"

test_capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_captured_output_contains "Hello world"
test_capture_empty

test_capture "jh-patch-file-patch" $JH_ROOT/usr/bin/jh-patch-file "uninstall" "$TARGET" "test"
assert_captured_success "should be successfull"

test_capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_true "Should not contain patch" "$([[ $(cat "$TARGET" | grep "Hello world") = "" ]])"
test_capture_empty
