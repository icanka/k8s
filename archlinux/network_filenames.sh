#!/bin/bash
# Fix the network interface names so that the names are predictable
# and system generated configuration such as dhcp.network file can not 
# overwrite vagrant specific configuration like enabling dhcp so that
# the network interface gets the ip address from the dhcp instead our static ip

config_dir="/etc/systemd/network"
prefix=10

for file in $(ls ${config_dir} | grep -E "^eth[0-9].*\.network$");do
    new_file="${prefix}-${file}"
    sudo mv "${config_dir}/${file}" "${config_dir}/${new_file}"
    prefix=$((prefix+10))
done

echo "Restarting systemd-networkd"
if sudo systemctl restart systemd-networkd; then
    echo "systemd-networkd restarted"
else
    echo "systemd-networkd restart failed"
    exit 1
fi