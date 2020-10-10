#!/usr/bin/env bash

WID="$( xdotool search --name "VLC media player" | head -n 1 )"

if [ -z "$WID" ]; then
    echo "VLC not found"
    exit 101
fi

# https://www.vlchelp.com/vlc-media-player-shortcuts/
# https://gitlab.com/cunidev/gestures/-/wikis/xdotool-list-of-key-codes

PRESSED_KEY=""

release() {
    local LL="$PRESSED_KEY"
    # Forget it to avoid loop
    PRESSED_KEY="";
    if [ -n "$LL" ]; then
        xdt "$LL" "keyup"
    fi
}

xdt() {
    KEY="$1"
    ACT="${2:="key"}"
    if [ -n "$PRESSED_KEY" ]; then
        release
    fi
    case "$ACT" in
        "keydown" )
            PRESSED_KEY="$KEY"
            ;;
    esac
    xdotool "$ACT" --window "$WID" "$KEY"
}

case "$1" in
    "release" )
        release
        ;;

    "play" )
        # Custom key
        xdt "shift+threesuperior"
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
        xdt "Shift+Left" "keydown"
        ;;
    "start-prev-2" )
        xdt "Alt+Left" "keydown"
        ;;
    "start-prev-3" )
        xdt "Ctrl+Left" "keydown"
        ;;

    "next-frame" )
        xdt "e"
        ;;
    "start-next-1" )
        xdt "Shift+Right" "keydown"
        ;;
    "start-next-2" )
        xdt "Alt+Right" "keydown"
        ;;
    "start-next-3" )
        xdt "Ctrl+Right" "keydown"
        ;;

    * )
        echo "Unknown action: $1" >&2
        exit 102
        ;;
esac


