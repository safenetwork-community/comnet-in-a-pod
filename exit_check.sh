#!/bin/bash

sudo podman commit root_node debug/sn_image
sudo podman run -it --rm --entrypoint=/bin/bash --name debug_node debug/sn_image