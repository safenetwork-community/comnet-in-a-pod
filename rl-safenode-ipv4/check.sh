#!/bin/bash

CON_NAME=root_node
HOME_DIR=/home/admin
SN_DIR=$HOME_DIR/.safe
SN_CLI_DIR=$SN_DIR/cli
CONFIG_FILENAME=sjefolaht_node_connection_info.config
CONFIG_PATH_HOST=~/.local/share/containers/storage/volumes/root_node_vol/_data/networks/$CONFIG_FILENAME
CONFIG_PATH_GUEST=$SN_CLI_DIR/networks/$CONFIG_FILENAME

cat $CONFIG_PATH_HOST
echo

podman exec -u admin $CON_NAME cat $CONFIG_PATH_GUEST
echo

podman exec -u admin -w $SN_DIR -it $CON_NAME /bin/bash
