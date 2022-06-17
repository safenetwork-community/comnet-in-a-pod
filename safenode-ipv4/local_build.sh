#!/bin/bash

sudo podman build -t build/rootnode-ipv4 .
sudo podman run -it build/rootnode-ipv4
