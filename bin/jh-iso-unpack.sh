#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "You must provide iso as [1]"
    exit 1
fi

ISO="$1"
CURDIR="$( pwd )"
NAME="$(basename -s ".iso" "$ISO" )"

TARGET="$CURDIR/$NAME"
MOUNTED="$CURDIR/$NAME.mounted"

if [ -n "$2" ]; then
    TARGET="$2"
fi

DO_FORCE=${DO_FORCE:-0}

echo "*** Unpacking $ISO into $TARGET"

# Will be removed by "clean_up"
mkdir -p "$MOUNTED"

clean_up() {
    cd "$CURDIR"

    if [[ -d "$MOUNTED" ]]; then
        mount | grep -qF " $MOUNTED " \
            && sudo umount "$MOUNTED";
            # && fusermount -u "$MOUNTED";
        sleep 1s
        rmdir "$MOUNTED"
    fi
}
trap clean_up INT
trap clean_up EXIT

if [[ -d "$TARGET" ]]; then
    if (( DO_FORCE )); then
        echo "Local dir $TARGET already exists, removing it"
        sudo rm -fr "$TARGET"
    else
        echo "Local dir $TARGET already exists, please remove first before attempting a second time"
        exit 1
    fi
fi

mkdir -p "$TARGET"
sudo mount -o loop "$ISO" "$MOUNTED"
# fuseiso "$ISO" "$MOUNTED"
cd "$MOUNTED"
sudo rsync -ai "$MOUNTED/" "$TARGET/"
# sudo chmod -R u+w "$TARGET"
if [ -e "$TARGET/[BOOT]" ]; then
    sudo rm -r "$TARGET/[BOOT]"
fi

clean_up

echo "*** Unacking $ISO into $TARGET done"
