#!/bin/bash

server_ip=$1
log="iperf_${HOSTNAME}.Log"
echo "Running iperf to $server_ip"
iperf -c $server_ip -t 10 -i 1 | tee "$log"
