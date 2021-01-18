#!/usr/bin/env bash

set -e

NAME="$( git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p' )"
BRANCH="$( git branch --show-current )"

echo "NAME:   $NAME"

if [ -n "$1" ]; then
    if [ "$1" == "all" ]; then
        echo "Building all"
    	curl --fail -X POST "http://$JENKINS_TOKEN@$JENKINS_HOST/job/packages/build?delay=0sec"
        exit $?
    fi
    BRANCH="$1"
fi

echo "BRANCH: $BRANCH"

echo "Launching build..."
curl --fail -X POST "http://$JENKINS_TOKEN@$JENKINS_HOST/job/packages/job/$BRANCH/build?delay=0sec"
echo "Launching build... done"
