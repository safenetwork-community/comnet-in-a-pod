#!/bin/bash

IMAGE_NAME=safenode:latest

sudo podman image rm ghcr.io/safenetwork-community/$IMAGE_NAME
sudo podman pull ghcr.io/safenetwork-community/$IMAGE_NAME
