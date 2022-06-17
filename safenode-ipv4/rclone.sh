#!/bin/bash

VOL_NAME=comnet_sjefolaht_ipv4_vol
CONFIG_FILENAME=sjefolaht_ipv4_node_connection_info.config
VOL_SRC=/var/lib/containers/storage/volumes/$VOL_NAME/_data
CONFIG_PATH_HOST=$VOL_SRC/$CONFIG_FILENAME
RCLONE_PATH=nwazj://rezosur/koqfig

sudo rclone copy $CONFIG_PATH_HOST $RCLONE_PATH
