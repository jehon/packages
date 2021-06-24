#!/usr/bin/env bash

INPUT="$1"
RAW=$(basename "$INPUT" ".MTS")
OUTPUT="$RAW.avi"

# ffmpeg -i "$INPUT" \
# 	-acodec copy \
# 	-vcodec libx264 \
# 	-deinterlace \
# 	-threads 0 \
# 	-y \
# 	"$OUTPUT"
#	 
# #	-crf 21 \
# #	-r 30000/1001 \
# # -vpre lossless_medium

ffmpeg -i "$INPUT" -scodec copy -acodec copy -vcodec copy -f mp4 "$OUTPUT";

# # remux m2ts movies into mkv with ffmpeg
# for i in *.MTS; do 
# 	ffmpeg -i $i -scodec copy -acodec copy -vcodec copy -f mpg4 $(basename $i .m2ts).mkv;
# 	echo "Conversion done";
# done
