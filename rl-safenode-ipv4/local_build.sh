#!/bin/bash

CON_NAME=root_node
IMAGE=build/rootnode-ipv4

## IP PARAMETERS ##

CON_IP=10.88.0.2
CON_PORT_BASE=12000
CON_PORT_MAX=$(($CON_PORT_BASE + $NUM_NODES))
HOST_IP=$(ip -4 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done | head -n 1)
HOST_PORT_BASE=12000
HOST_PORT_MAX=$(($HOST_PORT_BASE + $NUM_NODES))
PUB_IP=$(curl -s ifconfig.me)
PUB_PORT_BASE=12000

sudo podman build -t $IMAGE .
sudo podman run -it \ 
  --name $CON_NAME \
  --publish $HOST_IP:$HOST_PORT_BASE-$HOST_PORT_MAX:$CON_PORT_BASE-$CON_PORT_MAX/udp \
  --ip 10.0.88.2 \
  $IMAGE
