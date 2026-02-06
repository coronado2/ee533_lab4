#!/bin/bash

ts=$(date +"%Y%m%d_%H%M%S")
log="udp_${HOSTNAME}_${ts}.log"

iperf -u -c 10.0.0.3 -b 1G -l 512 -t 30 >> $log 2>&1 &
iperf -u -c 10.0.1.3 -b 1G -l 512 -t 30 >> $log 2>&1 &
iperf -u -c 10.0.2.3 -b 1G -l 512 -t 30 >> $log 2>&1 &
iperf -u -c 10.0.3.3 -b 1G -l 512 -t 30 >> $log 2>&1 &

wait
[team
