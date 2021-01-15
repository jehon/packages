#!/usr/bin/env bash

addTag() {
	T="$2"
	T="${T%% }"
	T="${T## }"
	if [ -z "$T" ]; then
		return
	fi
	EXP="$EXP\[$( printf "\e[1;%sm" "$1" )$T$( printf "\e[00m" )\]"
}

addTag "33" "$1"
addTag "32" "$2"
addTag "35" "$3"

sed -e "s%^%$EXP %"
