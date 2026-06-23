
# Networking Projects
Welcome to the "Networking Projects" repository dedicated to **advanced networking projects** ! 

This repertory is a collection of network architectures &amp; solutions, that showcase comprehensive network setups, including VPN setup with site-to-site and remote-access architectures  with automatic failover solutions.

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

<h2>Project 3 - <a href="https://github.com/afshyna/networking-projects/tree/main/vpn-openvpn-wireguard-engineering-project">  OpenVPN & WireGuard solutions </a> </h2>

This micro-project focuses on the design and deployment of a resilient VPN infrastructure combining OpenVPN site-to-site connectivity and WireGuard remote-access VPN services.

The architecture simulates a realistic enterprise environment with multiple branch offices, a primary server site, a disaster recovery site, nomad users, Internet exposure through NAT/PAT, and automated failover mechanisms.

It demonstrates how secure VPN services can be deployed, monitored, and maintained in production-like conditions while ensuring business continuity during outages.

<strong>Technical Configuration & Architecture:</strong>

- <strong>VPN Technologies:</strong> OpenVPN (SSL/TLS) for Site-to-Site connectivity and WireGuard for Remote-Access VPN
- <strong>Architecture Type:</strong> Multi-site VPN infrastructure with Primary Site (Paris-Montrouge) and Disaster Recovery Site (Aubervilliers)
- <strong>Remote Offices:</strong> Tokyo and New York branch networks connected through routed VPN tunnels
- <strong>Site-to-site:</strong> OpenVPN & WireGuard VPN for LAN-to-LAN communication between server's LAN and client's LAN.
- <strong>Remote Access:</strong> WireGuard VPN access for nomad users (laptops and smartphones)
- <strong>Authentication Scheme:</strong> X.509 certificates and TLS authentication for OpenVPN, public/private key cryptography for WireGuard
- <strong>Routing Design:</strong> Static routing, CCD files, iroute directives, route propagation and inter-LAN communication
- <strong>High Availability:</strong> Automatic failover between primary and backup VPN servers using multiple remote endpoints, keepalive mechanisms and dynamic route switching
- <strong>NAT & Internet Exposure:</strong> NAT/PAT, port forwarding and MASQUERADE rules for VPN connectivity behind residential routers
- <strong>Firewall & Security:</strong> Linux iptables filtering, forwarding policies
- <strong>Network Services Validation:</strong> ICMP, HTTP and traceroute testing across VPN tunnels
- <strong>Troubleshooting & Analysis:</strong> Packet-level analysis using Wireshark and tcpdump, routing-table verification, failover testing and incident simulation
- <strong>Automation:</strong> Bash scripting, system-timers monitoring and dynamic route replacement for network resilience




