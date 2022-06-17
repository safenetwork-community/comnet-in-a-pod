#!/bin/bash

## GENERAL PARAMETERS ##

CON_NAME=root_node
ROOT_IMAGE=rootnode-ipv4:ubuntu
# JOIN_IMAGE=joinnode-ipv4:ubuntu
IMAGE_URL=ghcr.io/safenetwork-community
NUM_NODES=15
VERBOSE=-vvvv
RCLONE_PATH=nwazj://rezosur/koqfig

## SAFE APP PARAMETERS ##

SN_NETWORK_NAME=sjefolaht
CON_HOME=/home/admin
SAFE_PATH=$CON_HOME/.safe
SN_NODE_PATH=$SAFE_PATH/node
SN_CLI_PATH=$SAFE_PATH/cli

## IP PARAMETERS ##

CON_IP=10.88.0.2
CON_PORT_BASE=12000
CON_PORT_MAX=65535
HOST_IP=$(ip -4 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done | head -n 1)
HOST_PORT_BASE=12000
HOST_PORT_MAX=65535
PUB_IP=$(curl -s ifconfig.me)
PUB_PORT=12000

## PB PARAMETERS ##

CON_PORT_PB=4443
HOST_PORT_PB=443

## VOLUME PARAMETERS ##

CON_NETWORK_NAME=podman
VOL_NAME=root_node_vol
VOL_DIR=~/.local/share/containers/storage/volumes/$VOL_NAME
VOL_SRC=$VOL_DIR/_data

## SAFE VOL PARAMETERS ##

CONFIGFILE_NAME=${SN_NETWORK_NAME}_node_connection_info.config
CONFIGFILE_PATH=$VOL_SRC/networks/$CONFIGFILE_NAME

## VIM PARAMETERS ##

HOST_CP_PATH=~/safe
VIMFILE_NAME=keymappings.lua
CON_VIMFILE_PATH=$CON_HOME/.config/nvim/$VIMFILE_NAME
VIM_PATH_C=$CON_NAME:$CON_VIMFILE_PATH
VIM_PATH_H=$HOST_CP_PATH/$VIMFILE_NAME

usage()
{
  echo "Usage: [-c cp_path] [-n num_nodes] [-v verbose]"
  exit
}

while getopts 'c:f:l:n:s:r:v:?h' c
do
  case $c in
    c) CP_PATH=$OPTARG ;;
    f) CONFIGFILE_NAME=$OPTARG ;;
    l) VIMFILE_NAME=$OPTARG ;;
    n) NUM_NODES=$OPTARG ;;
    s) SN_NETWORK_NAME=$OPTARG ;;
    r) RCLONE_PATH=$OPTARG ;;
    v) VERBOSE=$OPTARG ;;
    h|?) usage ;;
  esac
done

# Create volume if not existing
if [ ! -d $VOL_DIR ]
  then
  podman volume create $VOL_NAME
fi

# Get the real VIM file if soft link
if [[ -L $VIM_PATH_H && -e $VIM_PATH_H ]]
then
  VIM_PATH_H=$(realpath $VIM_PATH_H)
fi

echo podman run \
  --name $CON_NAME \
  --network $CON_NETWORK_NAME \
  --sysctl net.ipv4.ip_unprivileged_port_start=$HOST_PORT_PB \
  --publish ${HOST_IP}:${HOST_PORT_BASE}-${HOST_PORT_MAX}:${CON_PORT_BASE}-${CON_PORT_MAX}/udp \
  --publish ${HOST_IP}:${HOST_PORT_PB}:${CON_PORT_PB}/tcp \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT_BASE \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT \
  --env VERBOSE=$VERBOSE \
  --userns=keep-id \
  --ip $CON_IP \
  -v $VOL_NAME:$SN_CLI_PATH \
  -d $IMAGE_URL/$ROOT_IMAGE

podman run \
  --name $CON_NAME \
  --network $CON_NETWORK_NAME \
  --sysctl net.ipv4.ip_unprivileged_port_start=$HOST_PORT_PB \
  --publish ${HOST_IP}:${HOST_PORT_BASE}-${HOST_PORT_MAX}:${CON_PORT_BASE}-${CON_PORT_MAX}/udp \
  --publish ${HOST_IP}:${HOST_PORT_PB}:${CON_PORT_PB}/tcp \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT_BASE \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT \
  --env VERBOSE=$VERBOSE \
  --userns=keep-id \
  --ip $CON_IP \
  -v $VOL_NAME:$SN_CLI_PATH \
  -d $IMAGE_URL/$ROOT_IMAGE

podman exec $CON_NAME safe networks add $SN_NETWORK_NAME            
podman exec $CON_NAME safe networks switch $SN_NETWORK_NAME
podman cp $VIM_PATH_H $VIM_PATH_C

rclone copy $CONFIGFILE_PATH $RCLONE_PATH

for (( i = 1; i <= NUM_NODES; i++ ))
  do
  sleep 3
  CON_PORT=$(($CON_PORT_BASE + $i))
  ((PUB_PORT++))

  echo podman exec \
    -d $CON_NAME sn_node $VERBOSE \
    --idle-timeout-msec 5500 \
    --keep-alive-interval-msec 4000 \
    --skip-auto-port-forwarding \
    --local-addr $CON_IP:$CON_PORT \
    --public-addr $PUB_IP:$PUB_PORT \
    --log-dir $SN_NODE_PATH/node_dir_$i \
    --root-dir $SN_NODE_PATH/node_dir_$i \
    --hard-coded-contacts [\"${HOST_IP}:${HOST_PORT_BASE}\"]
  
  podman exec \
    -d $CON_NAME sn_node $VERBOSE \
    --idle-timeout-msec 5500 \
    --keep-alive-interval-msec 4000 \
    --skip-auto-port-forwarding \
    --local-addr $CON_IP:$CON_PORT \
    --public-addr $PUB_IP:$PUB_PORT \
    --log-dir $SN_NODE_PATH/node_dir_$i \
    --root-dir $SN_NODE_PATH/node_dir_$i \
    --hard-coded-contacts [\"${HOST_IP}:${HOST_PORT_BASE}\"]
  
  done
