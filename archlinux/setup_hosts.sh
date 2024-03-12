#!/bin/bash
set -ex

NODE_IP=$1
NODE_NAME=$2

# Add node to /etc/hosts if it's not already there
if ! grep -q "$NODE_IP $NODE_NAME" /etc/hosts; then
	echo "$NODE_IP $NODE_NAME" | sudo tee -a /etc/hosts
fi
