#/!bin/bash

POD_NAME=sjefolaht

sudo podman generate systemd -n $POD_NAME 
