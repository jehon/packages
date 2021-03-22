#!/usr/bin/env bash

shopt -s nullglob

JH_THIS_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#
# must_run: 0 -> call the topic on this one
#
# is_content: 0 -> can recurse inside
#
#
#
#

myRunParts() {
	for F in "$JH_THIS_ROOT"/jh-src.d/*.sh; do
		# shellcheck source=/dev/null
		if ! source "$F" "$@"; then
			return 1
		fi
	done
	return 0
}

# Preconfiguration tasks
myRunParts prepare "$@"

treatDir() {
	# Treat current directory
	for F in "$JH_THIS_ROOT"/jh-src.d/*.sh; do
		# shellcheck source=/dev/null
		if source "$F" "must_run"; then
			# shellcheck source=/dev/null
			source "$F" "$@" \
				|& jh-tag-stdin.sh "$PWD" "$(basename "$F" )"
		fi
	done

	for d in ./* ; do
	    [ -r "$d" ] || continue
	    [ -d "$d" ] || continue
		N=$(basename "$d")

		if ! myRunParts "is_content" "$N" ; then
			continue
		fi

		# Recurse (deep first)

		pushd "$d" > /dev/null || exit 255
		treatDir "$@"
		popd > /dev/null || exit 255

	done
}

treatDir "$@"

# Post configuration tasks
myRunParts finish "$@"
