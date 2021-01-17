#!/usr/bin/env bash

# Not tested

sudo nmap 192.168.1.0/24 -sU -p 50000-50002 --open | grep report | awk '{print $5}'

sudo nmap 192.168.1.0/24 -sU -p 1900 --open | grep report | awk '{print $5}'
