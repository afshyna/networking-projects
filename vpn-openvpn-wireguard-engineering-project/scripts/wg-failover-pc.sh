#!/bin/bash

## Location (PC): /usr/local/bin/

# Reachability test of the Primary VPN (Paris)
ping -c 1 -W 1 10.9.3.1 > /dev/null

# VPN Primary (Paris) DOWN → launch the Backup VPN if not already active 
if [ $? -eq 1 ]; then				 # $?=0 : vpn client paris up, $?=1 : vpn client paris down
	wg-quick down wg0-pc-paris
	wg-quick up wg0-pc-auber
fi

# Reachability test of the backup VPN (Auber)
ping -c 1 -W 1 10.9.4.1 > /dev/null
if [ $? -eq 1 ]; then				# si vpn client auber down
	wg-quick down wg0-pc-auber
	wg-quick up wg0-pc-paris
fi

