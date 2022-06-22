#!/bin/bash

#CON_ID=root_node
POD_ID=pod_sjefolaht

sudo podman pod rm -f $POD_ID

#sudo podman stop $CON_ID
#sudo podman rm -f $CON_ID
