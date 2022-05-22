#!/bin/bash

# Description
# This script shows the open network ports on a system.
# Use -4 to only display TCPv4 ports.

if [[ "${1}" = '-4' ]]
then
  netstat -nutl ${1} | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}'
fi



