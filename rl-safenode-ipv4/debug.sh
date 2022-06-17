#!/bin/bash

USER_PATH_C=/home/admin
CP_PATH=~/safe
IMAGE_NAME=debug/rootnode-ipv4
NVIM_PATH=debug_node:$USER_PATH_C/.config/nvim
CON_NAME=debug_node

podman commit root_node $IMAGE_NAME
podman run -d --rm --name $CON_NAME $IMAGE_NAME --entrypoint=/bin/bash
#podman cp $CP_PATH/keymappings.lua $NVIM_PATH/keymappings.lua
podman exec -it $CON_NAME /bin/bash
