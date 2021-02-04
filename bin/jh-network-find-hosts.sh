#!/usr/bin/env bash

# Find live hosts on network
sudo nmap -sP 192.168.1.0/24 | grep report | awk '{print $5}'
