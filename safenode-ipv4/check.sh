#!/bin/bash

USER=admin
SN_NETWORK_NAME=sjefolaht_ipv4
VOL_NAME=comnet_${SN_NETWORK_NAME}_vol
HOME_DIR=/home/admin
SN_DIR=$HOME_DIR/.safe
CONFIG_FILENAME=${SN_NETWORK_NAME}_node_connection_info.config
CONFIG_PATH_HOST=/var/lib/containers/storage/volumes/$VOL_NAME/_data/networks/$CONFIG_FILENAME
CF_NETWORKS_PATH_CON=$SN_DIR/cli/networks/$CONFIG_FILENAME
CF_SHARE_PATH_CON=$SN_DIR/share/networks/$CONFIG_FILENAME
CON_PATH_CON=$SN_DIR/node/node_connection_info.config

# First argument is root node if empty
CON_NAME=$1
if [ -z $CON_NAME ]; then
  CON_NAME=root_node
fi

sudo cat $CONFIG_PATH_HOST
echo

if [ -z $CON_NAME ]; then
  sudo podman exec -u $USER $CON_NAME cat $CF_NETWORKS_PATH_CON
else
  sudo podman exec -u $USER $CON_NAME cat $CF_SHARE_PATH_CON
fi
echo

sudo podman exec -u $USER $CON_NAME cat $CON_PATH_CON
echo

sudo podman exec -u $USER -w $SN_DIR -it $CON_NAME /bin/bash
