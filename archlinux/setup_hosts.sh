#!/bin/bash
#set -ex

#NODE_IP=$1
#NODE_NAME=$2

IP_NW=$1
MASTER_IP_START=$2
NODE_IP_START=$3
NUM_MASTER_NODE=$4
NUM_WORKER_NODE=$5

MY_IP=$(ip - 4 addr show | grep -oP "(?<=inet\s)($IP_NW\.)(\d+)")
echo "PRIMARY_IP=${MY_IP}" >>/etc/environment

nodes=()
for i in $(seq 0 $NUM_MASTER_NODE); do
    num=$(($MASTER_IP_START + $i))
    nodes+=("${IP_NW}${num} controlplane0${i}")
done

for i in $(seq 0 $NUM_WORKER_NODE); do
    num=$(($NODE_IP_START + $i))
    nodes+=("${IP_NW}${num} worker0${i}")
done

for line in "${nodes[@]}"; do
    if ! grep -q "$line" /etc/hosts; then
        echo -e "$line" | sudo tee -a /etc/hosts
    fi
done
