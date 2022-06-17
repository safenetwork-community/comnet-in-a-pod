#!/bin/bash

podman exec root_node mkdir -p /root/snc/podman-scripts/rootnode-ipv4
podman cp . root_node:snc/podman-scripts/rootnode-ipv4/
podman exec root_node safe files put ./snc/podman-scripts/ --recursive
