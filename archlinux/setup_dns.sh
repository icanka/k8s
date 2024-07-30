#!/bin/bash

sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
if systemctl restart systemd-resolved; then
	dns=$(systemd-resolve --status | grep "DNS Servers: 8.8.8.8")
	if [[ -n $dns ]]; then echo "DNS is set"; else echo "DNS is not set" && exit 1; fi
else
	echo "Failed to restart systemd-resolved"
	exit 1
fi
