#!/bin/bash

## GENERAL PARAMETERS ##

CON_NAME=root_node
IMAGE=safenode:latest
IMAGE_URL=ghcr.io/safenetwork-community
NUM_NODES=16
NUM_JNODES=$(($NUM_NODES-1))

# error, warn, info, debug, trace
LOG_LEVEL=debug

## SAFE APP PARAMETERS ##

SN_NETWORK_NAME=sjefolaht
CON_HOME=/home/admin
SAFE_PATH=$CON_HOME/.safe

IDLE_TIMEOUT_MSEC=5500
KEEP_ALIVE_INTERVAL_MSEC=4000
FIRST=true
SKIP_AUTO_PORT_FORWARDING=true

## IP PARAMETERS ##

CON_IPU=::a58:2
CON_IP=[$CON_IPU]
CON_PORT=12000
CON_PORT_BASE=${CON_PORT}
CON_PORT_MAX=$(($CON_PORT_BASE + $NUM_NODES - 1))

if [ $CON_PORT_MAX -eq $CON_PORT_BASE ]; then
  CON_PORT_RANGE=$CON_PORT_BASE
else
  CON_PORT_RANGE=$CON_PORT_BASE-$CON_PORT_MAX
fi

HOST_IPU=$(ip -6 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done | head -n 1)
HOST_IP=[$HOST_IPU]

HOST_PORT_BASE=12000
HOST_PORT_MAX=$(($HOST_PORT_BASE + $NUM_NODES - 1))

if [ $HOST_PORT_MAX -eq $HOST_PORT_BASE ]; then
  HOST_PORT_RANGE=$HOST_PORT_BASE
else
  HOST_PORT_RANGE=$HOST_PORT_BASE-$HOST_PORT_MAX
fi

PUB_IP=[${HOST_IP}]
PUB_IPR=\\[${HOST_IPU}\\]
PUB_PORT=12000

## PODMAN PARAMETERS ##

CON_NETWORK_NAME=podman
POD_NAME=pod_$SN_NETWORK_NAME
HOST_NAME=comnet_$SN_NETWORK_NAME

## VIM PARAMETERS ##

HOST_CP_PATH=~/safe
VIM_PATH_C=/usr/local/share/lua/5.1
KEYMAP_NAME=keymappings.lua
KEYMAP_PATH_C=$VIM_PATH_C/$KEYMAP_NAME
KEYMAP_PATH_H=$HOST_CP_PATH/$KEYMAP_NAME

## VOLUME PARAMETERS ##

CON_VOL_PATH=$SAFE_PATH/share
CON_NETWORKS_PATH=$SAFE_PATH/cli/networks
CONFIGFILE_NAME=${SN_NETWORK_NAME}_node_connection_info.config
VOL_NAME=${HOST_NAME}_vol
VOL_DIR=/var/lib/containers/storage/volumes/$VOL_NAME
VOL_PATH=$VOL_DIR/_data
HOST_CONFIG_PATH=$VOL_PATH/networks/$CONFIGFILE_NAME

## RCLONE PARAMETERS ##

RCLONE_PATH=nwazj://rezosur/koqfig

usage()
{
  echo "Usage: [-c cp_path] [-n num_nodes] [-v log_level]"
  exit
}

while getopts 'c:f:l:n:s:r:v:?h' c
do
  case $c in
    c) CP_PATH=$OPTARG ;;
    f) CONFIGFILE_NAME=$OPTARG ;;
    l) VIMFILE_NAME=$OPTARG ;;
    n) NUM_NODES=$OPTARG ;;
    s) NETWORK_NAME=$OPTARG ;;
    r) RCLONE_PATH=$OPTARG ;;
    v) LOG_LEVEL=$OPTARG ;;
    h|?) usage ;;
  esac
done

# Create volume if not existing
if [ ! -d $VOL_DIR ]
  then
  sudo podman volume create $VOL_NAME
fi

# Get the real VIM file if soft link
if [[ -L $KEYMAP_PATH_H && -e $KEYMAP_PATH_H ]]; then
  KEYMAP_PATH_H=$(realpath $KEYMAP_PATH_H)
fi

echo sudo podman pod create \
  --name $POD_NAME \
  --network $CON_NETWORK_NAME \
  --publish ${HOST_IP}:${HOST_PORT_RANGE}:${CON_PORT_RANGE}/udp \
  --replace \
  --userns auto \
  --ip6 $CON_IPU \
  -v $VOL_NAME:$CON_VOL_PATH 

sudo podman pod create \
  --name $POD_NAME \
  --network $CON_NETWORK_NAME \
  --publish ${HOST_IP}:${HOST_PORT_RANGE}:${CON_PORT_RANGE}/udp \
  --replace \
  --userns auto \
  --ip6 $CON_IPU \
  -v $VOL_NAME:$CON_VOL_PATH

echo sudo podman run \
  --name $CON_NAME \
  --pod $POD_NAME \
  --env NETWORK_NAME=$SN_NETWORK_NAME \
  --env LOG_DIR=/home/admin/.safe/node/safenode \
  --env LOG_LEVEL=$LOG_LEVEL \
  --env SKIP_AUTO_PORT_FORWARDING=$SKIP_AUTO_PORT_FORWARDING \
  --env IDLE_TIMEOUT_MSEC=$IDLE_TIMEOUT_MSEC \
  --env KEEP_ALIVE_INTERVAL_MSEC=$KEEP_ALIVE_INTERVAL_MSEC \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT \
  --env FIRST=$FIRST \
  -d $IMAGE_URL/$IMAGE

sudo podman run \
  --name $CON_NAME \
  --pod $POD_NAME \
  --env NETWORK_NAME=$SN_NETWORK_NAME \
  --env LOG_DIR=/home/admin/.safe/node/safenode \
  --env LOG_LEVEL=$LOG_LEVEL \
  --env SKIP_AUTO_PORT_FORWARDING=$SKIP_AUTO_PORT_FORWARDING \
  --env IDLE_TIMEOUT_MSEC=$IDLE_TIMEOUT_MSEC \
  --env KEEP_ALIVE_INTERVAL_MSEC=$KEEP_ALIVE_INTERVAL_MSEC \
  --env CON_IP=$CON_IP \
  --env CON_PORT=$CON_PORT \
  --env PUB_IP=$PUB_IP \
  --env PUB_PORT=$PUB_PORT \
  --env FIRST=$FIRST \
  -d $IMAGE_URL/$IMAGE

sudo podman cp $KEYMAP_PATH_H $CON_NAME:$KEYMAP_PATH_C
echo sudo podman exec -u root $CON_NAME cp -r ${CON_NETWORKS_PATH} ${CON_VOL_PATH} 
sudo podman exec -u root $CON_NAME cp -r ${CON_NETWORKS_PATH} ${CON_VOL_PATH} 

# Expand node config file if join nodes.
if [ $NUM_JNODES -ne 0 ]; then

  sudo /usr/bin/nvim -es $HOST_CONFIG_PATH <<-EOF
:set expandtab
:set shiftwidth=2
:let g:lastcount=${PUB_PORT}
:fun PlusPlus()
let l:count=g:lastcount
let g:lastcount+=1
return l:count
endfun
/\(^\|"\)\@<![
:%s//\r&\r/g
/\(\("\)\@<=]\|]$\)
:%s//\r&/g
/${PUB_IPR}:${PUB_PORT}
:norm \$a,
:norm yy${NUM_JNODES}p
:norm ${NUM_JNODES}\$x
:norm gg
:%s/${PUB_IPR}:${PUB_PORT}/\=printf('${PUB_IP}:%d', PlusPlus())
:norm gg=G
:wq!
EOF
fi

sudo rclone copy $HOST_CONFIG_PATH $RCLONE_PATH

for (( i = 1; i < NUM_NODES; i++ ))
  do
  sleep 1
  ((CON_PORT++))
  ((PUB_PORT++))
  CON_NAME=join_node_$i

  echo sudo podman run \
    --name $CON_NAME \
    --pod $POD_NAME \
    --restart unless-stopped \
    --env NETWORK_NAME=$SN_NETWORK_NAME \
    --env LOG_DIR=/home/admin/.safe/node/safenode \
    --env LOG_LEVEL=$LOG_LEVEL \
    --env SKIP_AUTO_PORT_FORWARDING=$SKIP_AUTO_PORT_FORWARDING \
    --env IDLE_TIMEOUT_MSEC=$IDLE_TIMEOUT_MSEC \
    --env KEEP_ALIVE_INTERVAL_MSEC=$KEEP_ALIVE_INTERVAL_MSEC \
    --env CON_IP=$CON_IP \
    --env CON_PORT=$CON_PORT \
    --env PUB_IP=$PUB_IP \
    --env PUB_PORT=$PUB_PORT \
    --env FIRST=false \
    -d $IMAGE_URL/$IMAGE 

  sudo podman run \
    --name $CON_NAME \
    --pod $POD_NAME \
    --restart unless-stopped \
    --env NETWORK_NAME=$SN_NETWORK_NAME \
    --env LOG_DIR=/home/admin/.safe/node/safenode \
    --env LOG_LEVEL=$LOG_LEVEL \
    --env SKIP_AUTO_PORT_FORWARDING=$SKIP_AUTO_PORT_FORWARDING \
    --env IDLE_TIMEOUT_MSEC=$IDLE_TIMEOUT_MSEC \
    --env KEEP_ALIVE_INTERVAL_MSEC=$KEEP_ALIVE_INTERVAL_MSEC \
    --env CON_IP=$CON_IP \
    --env CON_PORT=$CON_PORT \
    --env PUB_IP=$PUB_IP \
    --env PUB_PORT=$PUB_PORT \
    --env FIRST=false \
    -d $IMAGE_URL/$IMAGE

  #sudo podman network connect --ip $CON_IP podman join_node_$i

  sudo podman cp $KEYMAP_PATH_H $CON_NAME:$KEYMAP_PATH_C
  done


