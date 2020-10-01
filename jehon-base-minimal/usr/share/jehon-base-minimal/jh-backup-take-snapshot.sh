#!/usr/bin/env bash

ROOT="/var/backups"
if [ -z "$1" ]; then
    echo "No namespace given. Abort" >&2
    exit 255
fi

mkdir -p "$ROOT/$1"

dt=$(date +%Y-%m-%d-%H.%M.%S)
for file in $ROOT/live/* ; do
    # http://stackoverflow.com/a/965072/1954789
    filename=`basename "$file"`
    name=${filename%.*}
    ext="${filename##*.}"
    DEST=$1/${dt}-${name}.${ext}
    echo "File: $file -> $DEST"
    cp $file "$ROOT/$DEST"
done

# Remove duplicates backups files
#   Since too old files are removed before, we are sure
#   to keep one individual backup at anytime
fdupes "/var/backups/$1" -f -r | xargs -L 1 --no-run-if-empty -I{} rm -v "{}"
