#!/usr/bin/env bash

# Script Working Directory
SWD="$( dirname "${BASH_SOURCE[0]}" )"

# shellcheck source=../lib/test-helpers.sh
. "$SWD/../lib/test-helpers.sh"

TARGET="/tmp/jh-patch-file-original.txt"
BACKUP="$TARGET-before-patch-file"

(
	# Setup the source file
	echo "This is the file"
	echo "This is the end"
) > "$TARGET"

capture "jh-patch-file-patch" $JH_ROOT/jehon-base-minimal/usr/bin/jh-patch-file.sh $JH_TEST_DATA/jh-patch-file-patch.txt
assert_captured_success "should be successfull"

capture "jh-patch-file-patch read" cat /tmp/jh-patch-file-original.txt
assert_captured_output_contains "Tag:[[:space:]]+test"
assert_captured_output_contains "File:[[:space:]]+$TARGET"
capture_empty

[[ -r "$BACKUP" ]]
assert_true "The backup file exists"

capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_captured_output_contains "Hello world"
capture_empty

capture "jh-patch-file-patch" $JH_ROOT/jehon-base-minimal/usr/bin/jh-patch-file.sh "uninstall" "$TARGET" "test"
assert_captured_success "should be successfull"

capture_file "read the generated file" "$TARGET"
assert_captured_output_contains "This is the file"
assert_true "Should not contain patch" $([[ $(cat "$TARGET" | grep "Hello world") = "" ]])
capture_empty

rm -f "$TARGET"
rm -f "$BACKUP"
