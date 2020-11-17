#!/usr/bin/env bash

I="1"

for fullfile in * ; do
    if [ ! -f "$fullfile" ]; then
        continue;
    fi
    dirn="$(dirname -- "$fullfile" )"
    filename="$(basename -- "$fullfile")"
    ext="${filename##*.}"
    fn="${filename%.*}"
    nf="$dirn/$fn [$I].$ext"

    echo "$fullfile => $nf"
    mv "$fullfile" "$nf"
    (( I++ ))

done
