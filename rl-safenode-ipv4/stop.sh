#!/bin/bash

CON_NAME=root_node

podman stop $CON_NAME
podman rm -f $CON_NAME

