#!bin/bash

POD_NAME=sjefolaht_ipv4

sudo podman generate systemd -n $POD_NAME 
