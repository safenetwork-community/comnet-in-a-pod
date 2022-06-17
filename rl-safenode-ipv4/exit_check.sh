#!/bin/bash

podman commit root_node debug/sn_image
podman run -it --rm --entrypoint=/bin/bash --name debug_node debug/sn_image
