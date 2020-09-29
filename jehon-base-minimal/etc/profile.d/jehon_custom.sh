#!/usr/bin/env bash

# For pip (python) local install
if [ -x /home/jehon/.local/bin ]; then
	export PATH=~/.local/bin/:"$PATH"
fi
