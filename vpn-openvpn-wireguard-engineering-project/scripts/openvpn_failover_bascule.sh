#!/bin/bash

# Reachability test of the Primary VPN (Paris) 
ping -c 1 -W 1 10.9.1.1 > /dev/null

# VPN Backup (Auber) DOWN (<=> VPN principal UP): stop the backup vpn (if active)
if [ $? -eq 0 ]; then			
	netstat -lu | grep 1195 > /dev/null
	if [ $? -eq 0 ];then		# $? = 0 => srv-auber actif, $?1 => srv auber pas actif
		sudo systemctl stop openvpn@srv-auber
	fi

# VPN Primary (Paris) DOWN → launch the Backup VPN if not already active 
else
	netstat -lu | grep 1195 > /dev/null
	if [ $? -eq 1 ]; then 		
		sudo systemctl start openvpn@srv-auber
	fi
fi
