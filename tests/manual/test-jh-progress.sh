#!/usr/bin/env bash

echo "Start the test"

echo -n "I do this... "
jh-progress "this"
sleep 0.5
echo "done"
sleep 0.5

for i in {0..30}; do
	echo "I do $i ..."
	jh-progress "Progress: $i"
	# sleep 0.1
done

echo -n "I do this again... "
jh-progress "this"
sleep 0.5
echo "done"
sleep 0.5

jh-progress
echo "End the test"
