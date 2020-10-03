#!/usr/bin/env bash

set -e

CURDIR="$( pwd )"

ISO="target-patched-$(date +"%Y-%m-%d_%H-%M-%S").iso"
TARGET="$CURDIR/iso"

if [ -n "$1" ]; then
    TARGET="$1"
fi

if [ -n "$2" ]; then
    ISO="$2"
fi

DO_FORCE=${DO_FORCE:-0}

echo "*** Packing $TARGET into $ISO"

if [[ -f "$ISO" ]]; then
    echo "Error: ISO file '$ISO' already exists, cannot update ISO !" >&2
    exit 1
fi

bootfile="$(find "$TARGET" -name "isolinux.bin" -printf "%P")"
catfile="$(find "$TARGET" -name "boot.cat" -printf "%P")"

echo "** Mk ISO FS **"
sudo mkisofs -U -r -v -T -J -joliet-long \
    -V "BOOT" -volset "BOOT"  -A "BOOT"  \
    -b "$bootfile" -c "$catfile" -no-emul-boot -boot-load-size 4 -boot-info-table \
    -o "$ISO" "$TARGET/"

echo "** Iso hybrid **"
sudo "isohybrid.pl" "$ISO"

echo "*** Packing $TARGET into $ISO done"
echo "*** Do not forget to remove $TARGET when finished"

