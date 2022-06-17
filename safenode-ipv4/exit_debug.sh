SN_NETWORK_NAME=sjefolaht_ipv4
POD_NAME=pod_$SN_NETWORK_NAME
USER_PATH_C=/home/admin
CP_PATH=~/safe
IMAGE_NAME=debug/joinnode-ipv4
NVIM_PATH=debug_node:/usr/local/share/lua/5.1
DCON_NAME=root_node
CON_NAME=debug_node
NVIM_FILENAME=keymappings.lua

# If image does not exist, run commit 
sudo podman image exists $IMAGE_NAME || sudo podman commit $DCON_NAME $IMAGE_NAME

sudo podman run --entrypoint /bin/bash --pod $POD_NAME -it --name $CON_NAME $IMAGE_NAME
