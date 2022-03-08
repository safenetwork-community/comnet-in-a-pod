#!/bin/bash

CON_ID=root_node

sudo podman stop $CON_ID
sudo podman rm -f $CON_ID
