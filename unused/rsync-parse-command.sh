#!/usr/bin/env bash

SWD="$( dirname "${BASH_SOURCE[0]}" )"
. "$SWD/rsync-lib.sh"
. "$SWD/rsync-replace-tokens.sh"

parseCommand() {
    #
    # Return status:
    #     1: unparsable
    #     2: options does not match config
    #    10: invalid config
    #   255: system error
    #
    CFG="$1"
    CMD="$2"

    #
    #
    # Global parameters
    #
    #
    if [ ! -r "$CFG" ]; then
        error "Could not read config file: $1"
        return 255
    fi

    C_RSYNC=$( cat "$CFG" | jq -r ".system.rsync" 2>/dev/null )
    if [ -z "$C_RSYNC" ] || [ "$C_RSYNC" == "null" ]; then
        debug "Using default value for rsync command"
        C_RSYNC="rsync"
    fi
    debug "C_RSYNC: $C_RSYNC"

    # Helper
    REGEX_PATH_STR="(\.|[^ ]+)"
    REGEX_ALNUM="[a-zA-Z0-9]"

    R_COMMAND=1
    REGEX="^((${REGEX_PATH_STR}/)?rsync) --server"

    (( R_SENDER = R_COMMAND + 3 ))
    REGEX="${REGEX}( --sender)?"
    
    ARGS="(.*)"

    (( R_ARGS = R_SENDER + 1 ))
    REGEX="${REGEX}${ARGS}"

    (( R_LOCAL = R_ARGS + 1 ))
    REGEX="${REGEX} ${REGEX_PATH_STR}"

    (( R_TARGET = R_LOCAL + 1 ))
    REGEX="${REGEX} ${REGEX_PATH_STR}\$"

    # // Detect if we would modify local folder:
    # var rsyncRegExpRW = regexp.MustCompile(`.* (--remove-source-files|--remove-sent-files) .*`)

    if [[ $CMD =~ ${REGEX} ]]; then
        debug "Parsing ok"
        debug "SRC: $CMD"
        for (( i=1; i<${#BASH_REMATCH[@]}+1; i++ )); do
            debug "-- $i: ${BASH_REMATCH[$i]}"
        done
        P_COMMAND="${BASH_REMATCH[$R_COMMAND]}"
        P_SENDER="${BASH_REMATCH[$R_SENDER]}"
        P_LOCAL="${BASH_REMATCH[$R_LOCAL]}"
        P_TARGET="${BASH_REMATCH[$R_TARGET]}"
        P_ARGS="${BASH_REMATCH[$R_ARGS]}"

        debug "P_COMMAND:  '$P_COMMAND'"
        debug "P_SENDER:   '$P_SENDER'"
        debug "P_ARGS:     '$P_ARGS'"
        debug "P_LOCAL:    '$P_LOCAL'"
        debug "P_TARGET:   '$P_TARGET'"
    else
        error "Could not parse: '$CMD'"
        debug "REGEX: $REGEX"
        return 1
    fi

    #
    #
    # Get the context
    #
    #
    FOUND_CFG=""
    while read R ; do
        if [[ -n "$FOUND_CFG" ]]; then
            error "Found more than one result for $P_TARGET"
            return 10
        fi
        FOUND_CFG="$R"
    done < <( cat "$CFG" | jq -c ".vfs[] | select(.key == \"${P_TARGET}\" )" )

    if [[ -z "$FOUND_CFG" ]]; then
        error "No config found for $P_TARGET"
        return 10
    fi

    debug "Found: $FOUND_CFG"
    if echo "$FOUND_CFG" | jq --exit-status ".readonly" 2>&1 >/dev/null ; then
        debug "Is readonly"
        C_RO=1
        if [[ -z "$P_SENDER" ]]; then
            error "Read-only filesystem, but received '--sender'"
            return 2
        fi
    else
        debug "Is read-write"
        C_RO=0
    fi

    #
    # 
    # Add options and match others
    #
    #

    # Target folder:
    C_TARGET="$( echo "$FOUND_CFG" | jq -r ".path" )"
    debug "C_TARGET: $C_TARGET"
    REAL_TARGET=$( replaceTokens "$C_TARGET" )
    debug "REAL_TARGET: $REAL_TARGET"

    # Backup dir:
    C_BACKUP="$( echo "$FOUND_CFG" | jq -r ".backup" )"
    if [ -n "$C_BACKUP" ] && [[ "$C_BACKUP" != "null" ]]; then
        debug "We have a backup config: $C_BACKUP"
        REAL_BACKUP=" --backup --backup-dir $( replaceTokens "$C_BACKUP" )"
        debug "REAL_BACKUP: $REAL_BACKUP"
    fi

    #
    #
    # Parse args
    #
    #

    REGEX_ARGS="^"
        # 	`-([BCEFIJLMMOPSWcdefghiklmnoprstu(?P<verbose>v)xyz]|\.)+` +
    REGEX_ARGS="${REGEX_ARGS}([ ]-[BCEFIJLMMOPSWcdefghiklmnoprstuvxyz.]+)?"

    #  Excluded:
    #  --devices(D) --specials(D) --xattrs(X) --acls(A) --hard-links(H)
    #  --copy-dirlinks(k)
    #  --super --fake-super
    #  --remove-source-files
    #  --partial-dir --temp-dir
    #  --backup(b)
    #  --dparam=(M)
    #  --remote-option(M)
    #  --temp-dir(T)
    # 
    #  Suspicious
    #  --archive(a) (implies D)
    #  --relative(R)
    # 
    #  Client parameters?
    #  - 0468q
    # 
    REGEX_ARGS="${REGEX_ARGS}( "
    REGEX_ARGS="${REGEX_ARGS}((--chmod=(${REGEX_ALNUM}|-|\+)+)|(--chown=(${REGEX_ALNUM}|:)+)|(--log-format=(${REGEX_ALNUM}|%)+)"
    REGEX_ARGS="${REGEX_ARGS}|(--modify-window=[0-9]+)|(--max-size ${REGEX_ALNUM}+)"
    REGEX_ARGS="${REGEX_ARGS}|(--bwlimit=[0-9]+)"

    if (( ! C_RO )); then
        # Read-only filesystem
        REGEX_ARGS="${REGEX_ARGS}|(--delete)|(--delete-excluded)|(--max-delete=[0-9]+)"
    fi
    REGEX_ARGS="${REGEX_ARGS}))*\$"

    if [[ $P_ARGS =~ ${REGEX_ARGS} ]]; then
        debug "Parsing args ok"
        debug "P_ARGS: $P_ARGS"
        debug "REGEX_ARGS: $REGEX_ARGS"
    else
        error "Could not parse arguments: '$P_ARGS'"
        debug "REGEX_ARGS: $REGEX_ARGS"
        return 1
    fi

    echo "${C_RSYNC} --server${P_SENDER}${P_ARGS}${REAL_BACKUP} ${P_LOCAL} ${REAL_TARGET}"
}
