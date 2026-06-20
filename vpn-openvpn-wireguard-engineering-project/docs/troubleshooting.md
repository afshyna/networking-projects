# 🛠️  Troubleshooting (Difficulties encountered) & Solutions

This is a central file for general problems (ex : conflits IP, pare-feu, etc.). 

For each problem, it describe the **issue**, the **diagnostic method** ued, the possible **cause** & finally the **solution** to resolve it with a proof capture.


----- 
🔍 Problem encountered: VPN instability and connectivity losses
During tests of the site-to-site VPN and mobile VPN, intermittent instability was observed on the OpenVPN tunnel on the Paris server side. The main symptom was random loss of connectivity: the ping would work for a few seconds, then become completely unresponsive before temporarily returning.

The OpenVPN logs showed:
- inactivity timeouts (Inactivity timeout (--ping-restart))
- synchronisation errors (invalid or missing SID)
- TLS resets (TLS handshake failed)


🧪 Analysis of the problem
Initially, several network-related causes were considered:
UDP instability linked to the 4G mobile network
MTU issues / packet fragmentation
packet loss along the network path
However, following a more in-depth analysis of the local network infrastructure, the actual cause was identified as an IP address conflict on the local network.

🔍 Troubleshooting process and identification of the cause
In order to identify the cause of the VPN tunnel instability, a comparison was carried out between the two remote sites (Paris and Auber backup).


🧪 1. Observation of network behaviour
During testing:
The Auber site (backup) maintained a stable connection, with no loss of ping or interruption to the VPN tunnel.
The Paris site, on the other hand, was unstable: intermittent ping losses, temporary disconnections and restarts of the OpenVPN tunnel.

This difference in behaviour ruled out a general issue with OpenVPN or the 4G mobile network, as the connection was stable on one of the two servers.


🔎 2. Checking the configurations

Next, a comparison of the OpenVPN configurations between the two servers was carried out:

Identical OpenVPN settings
Identical routes
Consistent VPN configuration across both sites

No differences were identified at application level that could explain the malfunction.


🌐 3. Analysis of the network infrastructure (NAT / port forwarding)

The investigation then focused on the network layer, specifically:

the port forwarding configuration on the Paris site’s router
the NAT rules associated with the OpenVPN server

During this check, an anomaly was identified:

the IP address used for port forwarding on the VPN server corresponded to an IP address already associated with another device on the local network.
this IP address appeared with a hostname corresponding to a mobile phone already connected to the network.



⚠️ Identificatin of the Root cause: IP address conflict (ARP conflict)
The IP address assigned to the OpenVPN server at the Paris site was already in use by another device on the local network (a mobile phone). There was an IP address conflict (duplicate IP / ARP conflict) on the local network.

The cause is that i wanted to configured manually an IP on the paris server, by indicating an IP in the yaml file for the network interface enp0s3, in order to reproduce 

📉 Impact on the VPN
This conflict directly led to:
- connectivity losses on the OpenVPN tunnel
- data channel synchronisation errors
- timeouts and restarts of the VPN tunnel
- a perception of UDP network instability

This is due to the general problem caused by address conflict :  
- an ARP conflict on the local network
- instability in MAC ↔ IP resolution
- random redirection of packets between two machines

✅ Resolution
The problem was resolved by:
- changing the IP address of the other equipment by an unique IP  on the LAN
- resolving the conflict with the existing device on the local network
Following these corrections, the VPN connection became stable again and ping losses disappeared completely.

✅ Recommendation
Use a IP dynamically that is provided by the DHCP Server. 


---------------
<!--
STRUCTURE :
Issue/Symptômes: [Description courte du problème, ex: "Ping fails between Tokyo and Paris"]
Diagnostic Methods : [Quelle commande t'a permis d'isoler la panne ? ex: tcpdump -ni tun0 ou ip route get ...]
Causes possibles/Analyse : 
Solution(s): [Quelle modification as-tu apportée ? ex: "Ajout de la route dans le fichier ccd"]
Wireshark Analysis: [Lien vers la capture .pcap dans assets/captures-wireshark/ qui prouve que le problème est réglé].
-->


## II. Problèmes de connectivité VPN?


### Troubleshooting 10 
Issue : Au sprint 2, LOrsqu'on doit stoppe le service openvpn côte serveur paris, service redevient up peu de temps après 
 l'interface tun0 réaparrait avec son IP virtuelle ; 

🛠️ Solution : 
 on  désactive le service pour empêcher tout redémarrage automatique : 
sudo systemctl disable openvpn@server-parimont 


## 3. Problèmes NAT / Firewall ?
- Symptômes
- Vérifications iptables / ufw
- Solutions

## 4. Problèmes liés aux certificats ?
- Symptômes
- Vérifications
- Solutions

## 6. Problèmes de failover?
- Symptômes
- Analyse du script
- Solutions

## 7. Analyse Wireshark?
- Filtres utilisés
- Ce que tu as observé
- Comment tu as trouvé la cause

