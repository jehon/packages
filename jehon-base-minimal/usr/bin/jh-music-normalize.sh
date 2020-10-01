#!/usr/bin/env bash

find . -name "[0-9] - *" -print0 | while IFS='' read -r -d '' file; do
	D=`dirname "$file"`
	F=`basename "$file"`

	$DRY mv -v "$file" "$D/0$F"
done
