#!/usr/bin/env bash

# We need to calculate it us-self to be able to import jh-lib
JH_PKG_FOLDER="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

#
# Look for the files locally
#
export PATH="$JH_PKG_FOLDER/bin:$JH_PKG_FOLDER/$JH_PKG_MINIMAL_NAME/usr/bin:$PATH"
