#! /bin/bash

resultat=$(ping -c1 10.9.3.1)

# si tunnel vpn up avec paris
if [[ "$resultat" == *"64 bytes"* ]]
then
	:

# si tunnel vpn down avec paris
else
	r=$(ping -c1 10.9.3.2)
	if [[ "$r" == *"64 bytes"* ]] # si tunnel up avec auber
	then
		:
	else
		wg-quick down wg0-srv-paris
		wg-quick up wg0-srv-auber
	fi
fi
