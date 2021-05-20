#!/usr/bin/env bash

debug() {
	if [ -n "$DEBUG" ]; then
	    echo "$@" >&2
	fi
    true
}

error() {
    echo "$@" >&2
}
