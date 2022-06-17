#!/bin/bash

VOL_NAME=root_node_vol
CONFIG_FILENAME=sjefolaht_node_connection_info.config
VOL_SRC=~/.local/share/containers/storage/volumes/$VOL_NAME/_data
CONFIG_PATH_HOST=$VOL_SRC/networks/$CONFIG_FILENAME
RCLONE_PATH=nwazj://rezosur/koqfig

rclone copy $CONFIG_PATH_HOST $RCLONE_PATH
