#!/usr/bin/env bash

# https://www.vlchelp.com/vlc-media-player-shortcuts/
# https://gitlab.com/cunidev/gestures/-/wikis/xdotool-list-of-key-codes

# #
# # Be the only one remaining
# #
# SELF="$(basename "$0" )"
# ME="$$"
# echo "Me: $ME"
# OTHER="$( ps x | grep bash | grep "$SELF" | awk '{print $1}' | grep -v "$ME" | head -n 1 )"
# if [ -n "$OTHER" ]; then
#     echo "Killing '$OTHER'"
#     kill "$OTHER"
# fi

#
# Auto release other keys
#
PRESSED_KEY=""
release() {
    local LL="$PRESSED_KEY"
    # Forget it to avoid loop
    PRESSED_KEY="";
    if [ -n "$LL" ]; then
        xdt "$LL" "keyup"
    fi
}

#
# Send a key
#
xdt() {
    KEY="$1"
    ACT="${2:-"key"}"
    if [ -n "$PRESSED_KEY" ]; then
        release
    fi
    case "$ACT" in
        "keydown" )
            PRESSED_KEY="$KEY"
            ;;
    esac
    set -x
    xdotool search -name "VLC media player" "$ACT" --clearmodifiers "$KEY"
    set +x
}


#
# Main: send a key
#
case "$1" in
    "release" )
        release
        ;;

    "play" )
        # Custom key
        xdt "BackSpace"
        # xdt "space"
        ;;
    "pause" )
        # Custom key
        xdt "twosuperior"
        # xdt "space"
        ;;
    "show-timing" )
        xdt "t"
        ;;

    "show-subtitle" )
        xdt "v"
        ;;
    "next-audio" )
        xdt "b"
        ;;

    "prev-frame" )
        # Does not exists
        xdt "Shift+Left"
        ;;
    "start-prev-1" )
        xdt "Shift+Left"
        ;;
    "start-prev-2" )
        xdt "Alt+Left"
        ;;
    "start-prev-3" )
        xdt "Ctrl+Left"
        ;;

    "next-frame" )
        xdt "e"
        ;;
    "start-next-1" )
        xdt "Shift+Right"
        ;;
    "start-next-2" )
        xdt "Alt+Right"
        ;;
    "start-next-3" )
        xdt "Ctrl+Right"
        ;;

    * )
        echo "Unknown action: $1" >&2
        exit 102
        ;;
esac
