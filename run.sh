#!/bin/bash

## GENERAL PARAMETERS ##

ADM_PATH=/root/.safe/cli/
CLI_PATH=~/.local/share/safe/rf_cli/
CON_NAME=root_node
IMAGE=rf-rootnode-ipv6:latest
NETWORK_NAME=podman1
NODE_PATH=/root/.safe/node
NUM_NODES=15
VERBOSE=-v

## IP PARAMETERS ##

#CON_IP6 = fdc2:9f3e:3d11:040c
CON_IP6=fdc2:2c37:1a5c:5ad1::2
CON_IP=[$CON_IP6]
CON_PORT_BASE=12000
CON_PORT_MAX=$(($CON_PORT_BASE + $NUM_NODES))
HOST_IP=[$(ip -6 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done | head -n 1)]
HOST_PORT_BASE=12000
HOST_PORT_MAX=$(($HOST_PORT_BASE + $NUM_NODES))
PUB_IP=[$(curl -s ifconfig.co)]
PUB_PORT_BASE=12000

usage()
{
  echo "Usage: [-n num_nodes] [-v verbose]"
  exit
}

while getopts 'n:v:?h' c
do
  case $c in
    n) NUM_NODES=$OPTARG ;;
    v) VERBOSE=$OPTARG ;;
    h|?) usage ;;
  esac
done

echo "num_nodes:"$NUM_NODES
echo "verbose:"$VERBOSE

if [ ! -d $CLI_PATH ]
then
  mkdir -p $CLI_PATH
  sudo chown root:root $CLI_PATH
  unshare chown root:root $CLI_PATH
fi

echo sudo podman run \
  --name $CON_NAME \
  --network $NETWORK_NAME \
  --restart unless-stopped \
  --publish $HOST_IP:$HOST_PORT_BASE-$HOST_PORT_MAX:$CON_PORT_BASE-$CON_PORT_MAX/udp \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT_BASE \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT_BASE \
  --env VERBOSE=$VERBOSE \
  --ip6 $CON_IP6 \
  --mount type=bind,source=$CLI_PATH,destination=$ADM_PATH \
  -d ghcr.io/safenetwork-community/$IMAGE

sudo podman run \
  --name $CON_NAME \
  --network $NETWORK_NAME \
  --restart unless-stopped \
  --publish $HOST_IP:$HOST_PORT_BASE-$HOST_PORT_MAX:$CON_PORT_BASE-$CON_PORT_MAX/udp \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT_BASE \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT_BASE \
  --env VERBOSE=$VERBOSE \
  --ip6 $CON_IP6 \
  --mount type=bind,source=$CLI_PATH,destination=$ADM_PATH \
  -d ghcr.io/safenetwork-community/$IMAGE

sudo podman exec root_node safe networks add sjefolaht
sudo podman exec root_node safe networks switch sjefolaht
sudo podman cp ~/sur/keymappings.lua root_node:~/.config/nvim/keymappings.lua

for (( i = 1; i <= num_nodes; i++ ))
  do
  CON_PORT = $(($CON_PORT_BASE + $i))
  PUB_PORT = $(($PUB_PORT_BASE + $i))
  sudo podman exec
    -d $CON_NAME sn_node $VERBOSE
    --idle-timeout-msec 5500
    --keep-alive-interval-msec 4000
    --skip-auto-port-forwarding
    --local-addr $CON_IP:$CON_PORT
    --public-addr $PUB_IP:$PUB_PORT
    --log-dir $NODE_PATH/node_dir_$i
    --root-dir $NODE_PATH/node_dir_$i
  done
