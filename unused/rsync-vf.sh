#!/usr/bin/env bash

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. "$SWD/rsync-parse-command.sh"

if [ -z "$CONF" ]; then
	CONF="$HOME/.ssh/virtual_folders.json"
	debug "Config: looking at $CONF"
	if [ ! -r $CONF ]; then
		debug "Config: looking at $CONF"
		CONF="$SWD/virtual_folders.json"
	fi
	if [ ! -r "$CONF" ]; then
		echo "Configuration not found at ~/.ssh/virtual-folders.json or $CONF" >&2
		exit 255
	fi
else
	debug "Config was set: $CONF"
	if [ ! -r "$CONF" ]; then
		echo "Configuration not found at $CONF" >&2
		exit 255
	fi
fi

# if [ -n "$1" ]; then
#     KEY="$1"
# fi

# TS=$( date +"%Y-%m-%d_%H-%M-%S" )
TS=$( date +"%Y-%m-%d" )
USER="$(whoami)"

debug "Config:    $CONF"
debug "Timestamp: $TS"
debug "User:      $USER"
debug "Key:       $KEY"
debug "Original:  $SSH_ORIGINAL_COMMAND"

if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
    echo "No SSH_ORIGINAL_COMMAND found"
    exit 255
fi

# Parsing the rsync command
NEW_COMMAND="$( parseCommand "$CONF" "$SSH_ORIGINAL_COMMAND" )"
debug "New command found: $NEW_COMMAND"

$NEW_COMMAND
