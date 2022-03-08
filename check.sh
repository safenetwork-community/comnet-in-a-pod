#!/bin/bash

CONFIG_FILENAME=sjefolaht_node_connection_info.config
CONFIG_PATH_HOST=~/.local/share/safe/rf_cli/networks/$CONFIG_FILENAME
CONFIG_PATH_GUEST=/root/.safe/cli/networks/$CONFIG_FILENAME

cat $CONFIG_PATH_HOST
echo

sudo podman exec -u root root_node cat $CONFIG_PATH_GUEST
echo

sudo podman exec -u root -w /root/.safe -it root_node /bin/bash
