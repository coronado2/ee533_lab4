#!/bin/bash

echo "Starting iperf server"
if [ -n "$1" ]
then
PORT=$1
else
PORT=5001
fi

iperf -s -p $PORT
