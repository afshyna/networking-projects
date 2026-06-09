
# Networking Projects
Welcome to the "Networking Projects" repository! This repertory is a collection of network architectures &amp; solutions, that showcase comprehensive network setups about different networking concepts

<!-- This is commented out. 
Portfolio of personal projets :
- Network engineering
- Cybersecurity
- Routing & switching
- Security architecture
-->
<h2>Project 1 - <a href="https://github.com/afshyna/networking-projects/tree/main/vpn-ipsec-strongswan-site-to-site"> IPsec Site-to-site VPN with strongSwan </a> </h2>

This project is about the design and deployment of an IPsec VPN tunnel to interconnect two distant LANs  over the public Internet, located behind NAT, in a secure way.

**Technical Configuration & Architecture:**
* **VPN Type:** IPsec Tunnel Mode (LAN-to-LAN)
* **Key Exchange Protocol:** Internet Key Exchange Version 2 (IKEv2) via strongSwan
* **Encryption & Integrity:** Advanced cryptographic suite using AES256-GCM
* **Authentication Scheme:** Initial Pre-Shared Key (PSK) phase, migrated to a robust Public Key Infrastructure (PKI) with X.509 digital certificates (using PKI CA)
* **NAT Management:** NAT-Traversal (NAT-T) implementation to handle encapsulation over UDP ports 500/4500 through local routers
* **Packet Filtering & Security:** Advanced Stateful firewalling using Linux Netfilter (`UFW`)
* **IP Addressing Scheme:** Internet Protocol Version 4 (IPv4) 

<!-- This is commented out. 
<h2> Project 2 - IPsec  using Cisco IOS </h2>
This project is about the simulation of an LAN-to-LAN IPsec VPN tunnel between two Cisco routers, using the design network simulator GNS3

<h2> OpenVPN & WireGuard solutions </h2> 
This micro-project is about the design and deployment of  VPN SSL tunnel / multi-sites architecture with failover & nomade clients.
-->
