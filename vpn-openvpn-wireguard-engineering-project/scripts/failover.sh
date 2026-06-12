#! /bin/bash

# Test de reachabilite : Test VPN de secours (IP tunnel cote Tokyo)
ping -c 1 -W 1 10.9.2.2 > /dev/null

if [ $? -eq 0 ]; then
	# Tunnel VPN de secours est UP : route vers le serveur VPN de secours utilisé
	ip route replace 172.20.10.0/28 via 10.9.2.2 dev tun0
else
	# Tunnel VPN est DOWN : route principale utilisé
	ip route replace 172.20.10.0/28 via 192.168.100.200 dev enp0s8

fi
