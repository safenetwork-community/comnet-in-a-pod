#!/bin/bash

CON_NAME=root_node
IMAGE_NAME=safenode
WORK_DIR=/root
UPLOAD_DIR=$WORK_DIR/snc/podman-scripts/
IMAGE_DIR=$UPLOAD_DIR/$IMAGE_NAME
CP_DIR=$CON_NAME:$IMAGE_DIR

sudo podman exec $CON_NAME mkdir -p $IMAGE_DIR 
sudo podman cp . $CP_DIR
sudo podman exec $CON_NAME safe files put $UPLOAD_DIR --recursive
