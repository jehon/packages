#!/usr/bin/env bash

# Thanks to https://stackoverflow.com/a/6003016/1954789

# Limitations:
#   the cursor must be at first position for this to work

# Console size
# TERMCOLS=$(tput cols)
TERMLINES=$(tput lines)

cleanLine() {
	# Add a new line, and clean it from previous output
	# Thanks to https://stackoverflow.com/a/6774395/1954789
	echo -ne "\r\033[K"
}

# Read and save the cursor position
echo -en "\E[6n"
read -sdR CURPOS
CURPOS=${CURPOS#*[} # Line;Column
CURLINE=${CURPOS%;*}
CURCOL=${CURPOS#*;}

# If we are already on last line, add a new line
if [[ $CURLINE = $TERMLINES ]] ; then
	if [ "$CURCOL" != "1" ]; then
		# Note if cursor is at the middle of a line
		#   we should: add a new line
		#              clear it up
		echo ""
		cleanLine
		CURLINE=$[CURLINE - 1]
	fi

	cleanLine
	echo ""
	CURLINE=$[CURLINE - 1]
	cleanLine

	echo ""
	CURLINE=$[CURLINE - 1]
	cleanLine
	
	echo ""
	CURLINE=$[CURLINE - 1]
	cleanLine
fi

# Go last line
echo -en "\033[$TERMLINES;0H"

# Clean the last message
cleanLine N

# Show message
echo -ne "\e[36m${1}\e[0m"

# Restore cursor position
echo -en "\033[${CURLINE};${CURCOL}H"

if [ "$CURCOL" == "1" ]; then
	cleanLine
fi
