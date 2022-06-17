#!/bin/bash

SN_NETWORK_NAME=sjefolaht_ipv4
POD_NAME=pod_$SN_NETWORK_NAME
USER_PATH_C=/home/admin
CP_PATH=~/safe
IMAGE_NAME=debug/safenode-ipv4
NVIM_PATH=debug_node:/usr/local/share/lua/5.1
DCON_NAME=debug_node
NVIM_FILENAME=keymappings.lua

# First argument is root node if empty
CON_NAME=$1
if [ -z $CON_NAME ]; then
  CON_NAME=root_node
fi

# If image does not exist, run commit 
sudo podman image exists $IMAGE_NAME || sudo podman commit $CON_NAME $IMAGE_NAME

if [ $(sudo podman ps -a --format {{.Names}} | grep -Fx $DCON_NAME | wc -l) -eq 0 ]; then
  sudo podman run --entrypoint=/bin/bash -it --pod $POD_NAME --name $DCON_NAME $IMAGE_NAME
  sudo podman cp $CP_PATH/$NVIM_FILENAME $NVIM_PATH/$NVIM_FILENAME
fi

sudo podman exec -u root -it $DCON_NAME /bin/bash
