#!/bin/bash

CONFIG_FILENAME=sjefolaht_node_connection_info.config
CONFIG_PATH_HOST=~/.local/share/safe/rf_cli/networks/$CONFIG_FILENAME
RCLONE_PATH=nwazj://rezosur/koqfig

rclone copy $CONFIG_PATH_HOST $RCLONE_PATH
