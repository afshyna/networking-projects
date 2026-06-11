
# Networking Projects
Welcome to the "Networking Projects" repository! This repertory is a collection of network architectures &amp; solutions, that showcase comprehensive network setups about different networking concepts.

**Portfolio of personal projets**:
- Network engineering
- Cybersecurity
- Routing & switching
- Security architecture

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

<h2>Project 2 - <a href="https://github.com/afshyna/networking-projects/tree/main/vpn-ipsec-site-to-site-CiscoIOS-gns3">IPsec Site-to-Site VPN using Cisco IOS</a></h2>

This project is about the simulation of an LAN-to-LAN IPsec VPN tunnel between two Cisco routers, using traditional IOS mechanisms,`crypto map`, `transform set`, and ACL‑based traffic selection, within a simulated GNS3 environment.

It demonstrates how legacy Cisco routers implement secure LAN-to-LAN connectivity over an untrusted network such as the public Internet.

**Technical Configuration & Architecture:**
- **VPN Type**: IPsec Tunnel Mode / Policy-Based IPsec (LAN-to-LAN)
- **Key Exchange Protocol**: IKEv1 (ISAKMP), the traditional negotiation model 
- **IPsec Phases**:
- Phase 1 (ISAKMP/IKE SA): Authentication, DH key exchange, protection of the control channel
- Phase 2 (IPsec/ESP SA): Creation of the encrypted data tunnel
- **Encryption & Integrity**: AES‑256 for confidentiality, SHA‑256 for integrity, DH Group 14 for key exchange
- **Authentication Scheme**: Pre‑Shared Key (PSK) between both Cisco routers
- **Security Policy**: Implementation of "Interesting Traffic" via Extended Access Control Lists (ACLs)
- **Verification & Troubleshooting:** analysis of Security Associations (SA) and SPIs using Cisco IOS diagnostic commands
<!-- NAT Management: NAT‑Traversal (NAT‑T) support for encapsulating ESP over UDP/4500 when routers are behind NAT 
    NAT Integration: Policy-based routing and crypto-map application on WAN interfaces
-->

<!-- 
<h2> OpenVPN & WireGuard solutions </h2> 
This micro-project is about the design and deployment of  VPN SSL tunnel / multi-sites architecture with failover & nomade clients.
-->
