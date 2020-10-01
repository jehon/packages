#!/usr/bin/env bash

# Thanks to https://superuser.com/a/691507

# sudo apt-get install sox libsox-fmt-mp3

for f in *.ogg; do 
	sox "$f" "${f%.ogg}.mp3"
done
