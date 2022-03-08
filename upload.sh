#!/bin/bash

sudo podman exec root_node mkdir -p /root/snc/podman-scripts/rf-rootnode-ipv6
sudo podman cp . root_node:snc/podman-scripts/rf-rootnode-ipv6/
sudo podman exec root_node safe files put ./snc/podman-scripts/ --recursive
