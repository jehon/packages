#!/usr/bin/env bash

PID=$(lsof -t "-i:$1")

if [ "$PID" != "" ]; then
  echo "Kill $PID"
  kill -9 "$PID"
else
  echo "Nobody seem to listen to port $1"
fi
