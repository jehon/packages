#!/usr/bin/env bash

set -e

# The root of the repository
JH_ROOT="$(dirname "$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" )" )"
export JH_ROOT

# shellcheck source=../../jehon-base-minimal/usr/bin/jh-lib.sh
. "$JH_ROOT/jehon-base-minimal/usr/bin/jh-lib.sh"

# TODO: use jh-lib.sh and factorized facilities

JH_TMP="$JH_ROOT/tmp"
mkdir -p "$JH_TMP"
export JH_TMP

# JH_ORIGINAL_ARGS=( "$@" )
# export JH_ORIGINAL_ARGS

JH_TEST_DATA="$JH_ROOT/tests/data"
export JH_TEST_DATA

JH_TEST_TMP="$JH_TMP/$(basename "$0")"
mkdir -p "$JH_TEST_TMP"

#
# Resolve a path according to the JH_ROOT of this git repository
#
relative_to_root() {
	JH_ROOT_RP="$(realpath "$JH_ROOT")"
	ARG_RP="$(realpath "$1")"

	echo "${ARG_RP#${JH_ROOT_RP}/}"
}

# Create a "3"rd out where all structured messages will go
# This allow us to capture stdout and stderr everywhere,
# while still letting passing through the messages "Success / failure / ..."
exec 3>&2

#
# Loglevel can be:
#   0 - normal
#  10 - debug
#
if [ "$LOGLEVEL" = "" ]; then
    LOGLEVEL=0
fi

#
# Log something for message (on >3)
#
log_message() {
    ( echo "$@" ) >&3
}

#
# Log something for debug purpose (on >3)
#
log_debug () {
    if [[ $LOGLEVEL -eq 0 ]]; then
        return
    fi
    ( echo "$@" ) >&3
}

#
# Log the success (with a green ✓)
#
log_success() {
    (
        echo -e "\e[1;32m\xE2\x9C\x93\e[1;00m Test '\e[1;33m$1\e[00m' success"
    ) >&3
}

#
# Log the failure and exit with code '1' (with a red ✘)
#
log_failure() {
    (
		if [ -n "$JH_CAPTURED_OUTPUT" ]; then
        	echo "*** Captured output begin ***"
        	echo -e "$JH_CAPTURED_OUTPUT"
        	echo "*** Captured output end ***"
		fi
        echo -e "\e[1;31m\xE2\x9C\x98\e[1;00m Test '\e[1;33m$1\e[00m' failure: \e[1;31m$2\e[1;00m"
        echo "To have potentially more details, please run tests.sh with LOGLEVEL=10"
    ) >&3
    exit 1
}

# #
# # Force the script to run in docker
# #   If not already running in docker, restart in docker automatically
# #
# only_in_docker() {
# 	# 1: docker image or tag
# 	# 2: relative path
# 	# 3..n: arguments

# 	if [ -z "$IN_DOCKER" ]; then
# 		log_message "Restarting through docker: $0 ${JH_ORIGINAL_ARGS[*]}"
# 		"$JH_ROOT"/bin/run-in-docker.sh "$1" "$0" "${JH_ORIGINAL_ARGS[@]}"
# 		exit $?
# 	fi
# }

assert_true() {
	local V=$?
	if [ -n "$2" ]; then
		V="$2"
	fi
    if (( V != 0 )) ; then
        log_failure "$1" "result is not-zero ($V)"
    fi
    log_success "$1"
}

assert_equals() {
	local V=$?
	if [ -n "$2" ]; then
		V="$2"
	fi
    if [[ "$2" != "$3" ]] ; then
        log_failure "$1" "result ($3) does not equal expected ($2)"
    fi
    log_success "$1: Expected ($2) is equal to result ($3)"
}

assert_file_exists() {
	if [ -e "$1" ]; then
		log_success "File exists: $1"
	else
		log_failure "File exists: $1" "not found ( $( cd "$(dirname "$1")" && find . -maxdepth 1 -type f -exec basename "{}" ";" | tr '\n' ' ' ))"
	fi
}

assert_success() {
	capture "$@"
	assert_captured_success ""
}

capture() {
	CAPTURED_HEADER="$1"
    JH_CAPTURED_OUTPUT=""
	JH_CAPTURED_EXITCODE=0
	shift

	if [ -z "$1" ]; then
		echo "Usage: capture <header> <command> <arg>+ "
		exit 255
	fi

    JH_CAPTURED_OUTPUT="$( "$@" 2>&1 )" || JH_CAPTURED_EXITCODE="$?" || true

    log_debug ""
	return 0
}

capture_file() {
	capture "$1" cat "$2"
}

capture_empty() {
	CAPTURED_HEADER=""
    JH_CAPTURED_OUTPUT=""
	JH_CAPTURED_EXITCODE=0
}

assert_captured_output_contains() {
	local MSG="$1"
	local TEST="$2"
	if [ -z "$1" ]; then
		echo "Usage: assert_captured_output_contains [header] <expected-regex>"
		echo "   header default to contains"
		exit 255
	fi
	if [ -z "$TEST" ]; then
		TEST="$MSG"
	fi

	local FOUND=0
	local BACKUP_IFS="$IFS"
	IFS=$'\n'

	while read -r R; do
        if [[ "$R" =~  $TEST ]]; then
            FOUND=1
            LINE="[=>] $R" >&3
        else
            LINE="[  ] $R" >&3
        fi
        log_debug "$LINE"
	done < <(echo -e "$JH_CAPTURED_OUTPUT")
	IFS="$BACKUP_IFS"
    log_debug ""

    if [ $FOUND != 1 ]; then
        log_failure "$CAPTURED_HEADER: $MSG" "$TEST not found in output"
		return 1
    fi
    log_success "$CAPTURED_HEADER: $MSG"
}

assert_captured_success() {
    if [[ $JH_CAPTURED_EXITCODE -gt 0 ]]; then
        log_failure "$CAPTURED_HEADER: $1" "command return $JH_CAPTURED_EXITCODE"
		return "$RES"
    fi
    log_success "$CAPTURED_HEADER: $1"
}

assert_captured_failure() {
    if [[ $JH_CAPTURED_EXITCODE -eq 0 ]]; then
        log_failure "$CAPTURED_HEADER: $1" "command return $JH_CAPTURED_EXITCODE (success)"
		return "$RES"
    fi
    log_success "$CAPTURED_HEADER: $1"
}

capture_dump_to_file() {
	if [ -z "$1" ]; then
		log_error "[capture_dump_to_file] Specify file as [1]"
		exit 255
	fi
	echo -e "$JH_CAPTURED_OUTPUT" > "$1"
}

#
#
# Main debug
#
#
log_debug "JH_ROOT: $JH_ROOT"
log_debug "JH_TMP: $JH_TMP"
