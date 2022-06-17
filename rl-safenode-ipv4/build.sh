#!/bin/bash

ROOT_IMAGE=rootnode-ipv4:ubuntu
JOIN_IMAGE=joinnode-ipv4:ubuntu
IMAGE_URL=ghcr.io/safenetwork-community

podman image rm ${IMAGE_URL}/${ROOT_IMAGE}
podman pull ${IMAGE_URL}/${ROOT_IMAGE}
podman image rm ${IMAGE_URL}/${JOIN_IMAGE}
podman pull ${IMAGE_URL}/${JOIN_IMAGE}
