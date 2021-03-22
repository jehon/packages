#!/usr/bin/env bash

# Script Working Directory
SWD="$( dirname "${BASH_SOURCE[0]}" )"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

PATCH="$JH_TEST_TMP/jh-patch-file-patch.txt"
TARGET="$JH_TEST_TMP/jh-patch-file-original.txt"
BACKUP="$TARGET-before-patch-file"

(
	# Setup the source file
	echo "This is the file"
	echo "This is the end"
) > "$TARGET"

cat <<-EOF >"$PATCH"
	#
	# Tag: test
	# File: $TARGET
	#
	#

	Hello world
EOF

capture "jh-patch-file-patch" "$JH_ROOT"/jehon-base-minimal/usr/bin/jh-patch-file.sh "$PATCH"
assert_captured_success "should be successfull"

capture "jh-patch-file-patch read" cat "$TARGET"
assert_captured_output_contains "Tag:[[:space:]]+test"
assert_captured_output_contains "File:[[:space:]]+$TARGET"
capture_empty
assert_true "The backup file $BACKUP exists" "$([[ -r "$BACKUP" ]])"

capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_captured_output_contains "Hello world"
capture_empty

capture "jh-patch-file-patch" $JH_ROOT/jehon-base-minimal/usr/bin/jh-patch-file.sh "uninstall" "$TARGET" "test"
assert_captured_success "should be successfull"

capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_true "Should not contain patch" "$([[ $(cat "$TARGET" | grep "Hello world") = "" ]])"
capture_empty
