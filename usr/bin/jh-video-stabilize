#!/usr/bin/env bash

ffmpeg -i "$1" -vf vidstabtransform,unsharp=5:5:0.8:3:3:0.4 "stabilized-$1"
