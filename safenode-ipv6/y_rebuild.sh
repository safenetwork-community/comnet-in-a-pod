#!/bin/sh

SN_NETWORK_NAME=sjefolaht
POD_NAME=pod_$SN_NETWORK_NAME

sudo podman pod exists $POD_NAME && ./stop.sh 
./build.sh 
./podrun.sh
sudo podman ps -a
