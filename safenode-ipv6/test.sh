#!/bin/bash

HOST_IPU=$(ip -6 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done | head -n 1)
HOST_IPR=\\[${HOST_IPU}\\]
HOST_IP=[$HOST_IPU]
HOST_PORT=12000

SN_NETWORK_NAME=sjefolaht
HOST_NAME=comnet_$SN_NETWORK_NAME
CONFIGFILE_NAME=${SN_NETWORK_NAME}_node_connection_info.config
VOL_NAME=${HOST_NAME}_vol
VOL_DIR=/var/lib/containers/storage/volumes/$VOL_NAME
VOL_PATH=$VOL_DIR/_data
HOST_CONFIG_PATH=$VOL_PATH/networks/$CONFIGFILE_NAME

echo $HOST_IPU
echo $HOST_IPR
echo $HOST_IP
sudo cat $HOST_CONFIG_PATH

# Expand node config file
sudo /usr/bin/nvim -es $HOST_CONFIG_PATH <<-EOF
:set expandtab
:set shiftwidth=2
:let g:lastcount=${HOST_PORT}
:fun PlusPlus()
let l:count=g:lastcount
let g:lastcount+=1
return l:count
endfun
/\(^\|"\)\@<![
:%s//\r&\r/g
/\(\("\)\@<=]\|]$\)
:%s//\r&/g
/${HOST_IPR}:${HOST_PORT}
:norm \$a,
:norm yy15p
:norm 15\$x
:norm gg
:%s/${HOST_IPR}:${HOST_PORT}/\=printf('${HOST_IP}:%d', PlusPlus())
:norm gg=G
:wq!
EOF

sudo cat $HOST_CONFIG_PATH
