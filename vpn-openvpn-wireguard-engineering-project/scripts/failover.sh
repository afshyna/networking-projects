#!/bin/bash

# Target: Backup VPN tunnel endpoint IP on Tokyo's side
TARGET_IP="10.9.2.2"

# Reachability test
ping -c 1 -W 1 $TARGET_IP > /dev/null

if [ $? -eq 0 ]; then
    # Backup tunnel is UP -> Route traffic directly via local tun0 (VPN backup server used)
	ip route replace 172.20.10.0/28 via 10.9.2.2 dev tun0
else
    # Backup tunnel is DOWN -> Route traffic via Paris LAN gateway (primary route)
	ip route replace 172.20.10.0/28 via 192.168.100.200 dev enp0s8
fi
