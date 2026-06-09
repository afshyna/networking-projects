# IPsec VPN Site-to-Site with strongSwan behind NAT

<h1>Introduction to VPN </h1>
A VPN allows you to create a virtual connection between two different local networks. It creates a logical interconnection between local networks over a shared network (whether public, such as the Internet, or private, such as a corporate intranet or a carrier’s backbone) using a traffic segmentation mechanism or a tunnelling protocol. Encryption is possible but not always used.

<h1> Overview </h1>
This project consists of designing and deploying a secure IPsec IKEv2 Site-to-Site VPN tunnel between two remote LAN networks over the public Internet using strongSwan on VM Ubuntu (Linux) gateways.
The infrastructure was deployed in a real-world environment where both VPN gateways were located behind NAT devices and connected through public Internet access (Home LAN ↔ 4G Mobile Network).
The objective of this project was to securely interconnect two distant private networks while ensuring encrypted LAN-to-LAN communications through IPsec ESP tunnels.
________________________________________
<h1> Project Scenario </h1>
A secure communication channel was required between 2 isolated private networks connected through the Internet:
•	Home LAN network
•	Remote LAN connected through a 4G mobile network

Both sites were located behind NAT-enabled Internet gateways, introducing additional routing and IPsec NAT Traversal (NAT-T) constraints.

The project focused on:
•	secure inter-site connectivity
•	encrypted traffic transport
•	routing between distant LANs
________________________________________
<h1> Solution </h1>
The following technologies and mechanisms were implemented:
•	Deployment of an IPsec IKEv2 Site-to-Site VPN using strongSwan
•	Ubuntu (Linux) gateways used as VPN routers
•	Configuration of ESP encryption using AES256-GCM
•	NAT Traversal (NAT-T) implementation for VPN communication through NAT devices
•	LAN-to-LAN routing between remote private subnets
•	Initial authentication using Pre-Shared Key (PSK)
•	Migration to a PKI-based authentication model using X.509 certificates
•	Traffic analysis and troubleshooting using:
    o	tcpdump
    o	Wireshark
    o	ip xfrm
    o	ipsec status
•	Verification of Security Associations (SA)
•	Validation of encrypted traffic over public Internet
________________________________________

<h1> Network Architecture </h1>

**Main Components** :
• Linux Ubuntu VPN Gateway = GW-A (Site A)
    o	VM on VirtualBox / VMware
    o	Connetece to the home local router/box  (behind a NAT)
    o	LAN local : 192.168.1.0/24 
    o	Private IP (GW-A) : 192.168.1.167 
    o	Public IP (box IP) : 82.X.Y.Z 
•	Linux Ubuntu VPN Gateway = GW-B (Site B)
    o	VM on VirtualBox /VMware
    o	Connected to a 4G mobile network (behind a NAT)
    o	LAN local : 172.20.10.0/28
    o	Private IP (GW-A) : 172.20.10.8
    o	Public IP (box IP) : 37.A.B.C
•	Home LAN network (behind my local home router where i have access on it)
•	Remote LAN over 4G mobile access (not access to the local router)
•	NAT-enabled Internet gateways
•	Public Internet connectivity
________________________________________
<h1> Key Features </h1> 
•	IPsec IKEv2 VPN
•	ESP tunnel encryption
•	NAT Traversal (NAT-T)
•	Secure LAN-to-LAN communication
•	Linux networking and routing
•	PKI / X.509 certificate authentication
•	Real-world deployment over public Internet
•	Advanced network troubleshooting
________________________________________
Troubleshooting & Challenges
Several networking and security challenges were encountered and resolved during the deployment:
•	NAT preventing ESP traffic forwarding
•	Routing asymmetry issues
•	Missing ICMP replies between LANs
•	Incorrect subnet routing propagation
•	Security Association establishment failures
•	MTU and encapsulation considerations

<h1> Diagnostic tools used: </h1>
•	tcpdump
•	Wireshark
•	ip route
•	ipsec statusall 
•	ip xfrm state 
•	ip xfrm policy 
•	journalctl & strongSwan logs
________________________________________
<h1> Technologies Used </h1>
•	Linux Ubuntu
•	strongSwan
•	IPsec features
o	IKEv2
o	ESP
o	NAT Traversal (NAT-T) 
•	PKI & X.509 certificats
•	IP forwarding 
•	Virtualization (VirtualBox)
•	tcpdump
•	Wireshark

<h1> Features Implementation </h1>

<h2> 1. VPN Site-to-Site IPsec IKEv2 </h2>
Deployment of an IPsec ESP VPN tunnel in tunnel mode, enabling secure interconnection of two remote LANs over the public internet.

**Features**:
•	IKEv2
•	Encrypted ESP
•	NAT Traversal enabled
•	UDP 4500 encapsulation
•	AES256-GCM encryption
•	IKE fragmentation

<h2> 2. NAT and NAT-T Management </h2>
The project included a complex real-world scenario:
•	GW-B behind a 4G carrier NAT
•	Lack of port forwarding control on the mobile side

**Implemented solutions**:
•	Use of `forceencaps=yes`
•	ESP encapsulation in UDP/4500
________________________________________
<h2> 3. Inter-network Routing </h2>
Routing configuration between:
•	192.168.1.0/24
•	172.20.10.0/28

**Tasks performed**:
•	Enabling IPv4 forwarding
•	Configuring ufw rules
•	Validating LAN ↔ LAN traffic


<h2> 5. PSK Authentification </h2>
First implementation with:
•	Pre-shared key (PSK)
•	IKEv2 negotiation
•	Security Association validation
________________________________________

<h2> 6. Certificats X.509 Authentification </h2>
Migration of the VPN to a full PKI architecture.

**Achievements**:
• Generate a Certificate Authority (CA)
• Generate 4096-bit RSA keys
• Issue of X.509 certificates for each gateway
• Configure  strongSwan in authby=pubkey mode
• Manage  IKEv2 identities (leftid/rightid)
• Advanced troubleshooting of the certificate ↔ private key mapping

**PKI tools used** :
•	ipsec pki 
•	OpenSSL 
•	certificats PEM 
•	SAN / CN 

________________________________________
<h1> Project Objectives </h1>
•	Understand IPsec and IKEv2 mechanisms
•	Deploy secure VPN communications over the Internet
•	Implement NAT Traversal
•	Configure Linux routing for inter-site communication
•	Simulate real enterprise VPN deployment scenarios
________________________________________
<h1> Requirements </h1>
To reproduce this project, the following environment is required:
•	Linux Ubuntu VM installed on Virtualbox on physical hosts (for example, 2 computers)
•	strongSwan installed on both gateways
•	Internet connectivity
•	1 NAT-enabled router (at minimum)
•	Two distinct LAN networks
