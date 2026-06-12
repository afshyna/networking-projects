#! /bin/bash

RESULTAT=$(ping -c 1 10.9.3.1)

# si ping OK
if [[ "$RESULTAT" == *"64"* ]]
then
	:

#si ping NOK
else
	ip route del 10.9.3.0/24 via 192.168.100.200 dev enp0s8 metric 5
fi
