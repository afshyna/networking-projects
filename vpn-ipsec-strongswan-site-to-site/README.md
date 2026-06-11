# IPsec VPN Site-to-Site with strongSwan behind NAT

<h1>Introduction to VPN </h1>

A VPN allows you to create a virtual connection between two different local networks. It creates a logical interconnection between local networks over a shared network (whether public, such as the Internet, or private, such as a corporate intranet or a carrier’s backbone) using a traffic segmentation mechanism or a tunnelling protocol. Encryption is possible but not always used.

<h1> Overview </h1>

This project consists of designing and deploying a secure IPsec IKEv2 Site-to-Site VPN tunnel between two remote LAN networks over the public Internet using strongSwan on VM Ubuntu (Linux) gateways.

The infrastructure was deployed in a real-world environment where both VPN gateways were located behind NAT devices and connected through public Internet access (Home LAN ↔ 4G Mobile Network).

The objective of this project was to securely interconnect two distant private networks while ensuring encrypted LAN-to-LAN communications through IPsec ESP tunnels.

<h1> Project Scenario </h1>
A secure communication channel was required between 2 isolated private networks connected through the Internet:
<ul> 
    <li> Home LAN network </li>
    <li> Remote LAN connected through a 4G mobile network </li>
</ul>


Both sites were located behind NAT-enabled Internet gateways, introducing additional routing and IPsec NAT Traversal (NAT-T) constraints.

<img src="VPN-IPsec-site-to-site-Strongswan-NAT.png"></img>


The project focused on:
<ul> 
    <li> secure inter-site connectivity </li>
    <li> encrypted traffic transport </li>
    <li> routing between distant LANs </li>
</ul>


<h1> Solution </h1>
The following technologies and mechanisms were implemented:

- Deployment of an IPsec IKEv2 Site-to-Site VPN using strongswan
- Ubuntu gateways used as VPN routers
- ESP encryption using AES256-GCM
- NAT Traversal (NAT-T) implementation for VPN communication through NAT devices
- LAN-to-LAN routing between remote private subnets
- Initial PSK authentication then PKI/X.509 authentication
- Traffic analysis tools : `tcpdump`, Wireshark, `ip xfrm`, `ipsec status`
- Security Association (SA) verification
- Validation of encrypted traffic over public Internet

<h1> Network Architecture </h1>

**Main Components** :
<ul>
    
<li>Linux Ubuntu VPN Gateway = GW-A (Site A)</li>
<ul>
    <li>VM on VirtualBox / VMware</li>
    <li>Connected to the home local router/box  (behind a NAT)</li>
    <li>LAN local : 192.168.1.0/24</li>
    <li>Private IP (GW-A) : 192.168.1.167</li>
    <li>Public IP (box IP) : 82.X.Y.Z</li>
</ul>
<li>Linux Ubuntu VPN Gateway = GW-B (Site B)</li>
<ul>
    <li>Connected to a 4G mobile network (behind a NAT)</li>
    <li>LAN local : 172.20.10.0/28</li>
    <li>Private IP (GW-A) : 172.20.10.8</li>
    <li>Public IP (box IP) : 37.A.B.C</li>
</ul>

<li>Home LAN network (behind my local home router where i have access on it)</li>
<li>Remote LAN over 4G mobile access (not access to the local router)</li>
<li>NAT-enabled Internet gateways</li>
<li>Public Internet connectivity</li>
</ul>


<h1> Key Features </h1> 
<ul>
<li>IPsec IKEv2 VPN</li>
<li>ESP tunnel encryption</li>
<li>NAT Traversal (NAT-T)</li>
<li>Secure LAN-to-LAN communication</li>
<li>PKI / X.509 certificate authentication</li>
<li>Real-world deployment over public Internet</li>
</ul>

<h1> Verification tools used: </h1>

- Wireshark
- `tcpdump`
- `ipsec statusall`
- `ip xfrm state`
- `ip xfrm policy`
- journalctl & strongSwan logs

<h1> Technologies Used </h1>
<ul>
<li>Linux Ubuntu</li>
<li>strongSwan</li>
<li>IPsec features</li>
<ul> 
    <li>IKEv2</li>
    <li>ESP</li>
    <li>NAT Traversal (NAT-T)</li>
</ul>
<li>PKI & X.509 certificats</li>
<li>IP forwarding</li>
<li>Virtualization (VirtualBox)</li>
<li>tcpdump</li>
<li>Wireshark</li>
</ul>

<h1> Features Implementation </h1>

<h3> 1. VPN Site-to-Site IPsec IKEv2 </h3>

Deployment of an IPsec ESP VPN tunnel in tunnel mode, enabling secure interconnection of two remote LANs over the public internet.

**Features**:

<ul>
<li>IKEv2</li>
<li>Encrypted ESP</li>
<li>NAT Traversal enabled</li>
<li>UDP 4500 encapsulation</li>
<li>AES256-GCM encryption</li>
<li>IKE fragmentation</li>
</ul>

<h3> 2. NAT and NAT-T Management </h3>

The project included a real-world scenari where both gateways are behind NAT. So ESP encapsulation in UDP/4500 is required.

**Tasks performed**:
- Configuring an `ufw` rule to allow UDP traffic 4500 
- Configuring a port redirection on the home router (GW-A) to redirect UDP traffic 4500 from anywhere to the GW-A.

<h3> 3. Inter-network Routing </h3>

Routing configuration between:
<ul>
<li>192.168.1.0/24</li>
<li>172.20.10.0/28</li>
</ul>

**Tasks performed**:
- Enabling IPv4 forwarding
- Validating LAN to LAN traffic


<h3> 4. Authentification : PSK  </h3>

First implementation of IPsec tunnel with pre-shared key (PSK)
- definition the authentication method of strongswan with the option `authby=psk`
- Definition of the PSK value in the `/etc/ipsec.secrets`

    Format : `@IP-local-leftid    @IP-local-rightid : PSK "key-value"`

<h3> 5. Authentification : Certificats X.509  </h3>

Second implementation of IPsec tunnel using X.509 certificates generated by the PKI tools `ipsec pki`

**Achievements**:
- Generate a Certificate Authority (CA)
- Generate 4096-bit RSA keys
- Issue X.509 certificates for each gateway 
- Definition of the authentication method of strongSwan with the option `authby=pubkey` 
- Manage IKEv2 identities (`leftid`/`rightid`)
- Path to the local private key of the GW in the `/etc/ipsec.secrets`

    Format : `RSA gwX-key.pem"`


<h1> Project Objectives </h1>
<ul>
<li>Understand IPsec and IKEv2</li>
<li>Deploy secure VPN communications over the Internet</li>
<li>Implement NAT Traversal</li>
<li>Simulate real enterprise VPN deployment scenarios </li>
</ul>

<h1> Requirements </h1>
To reproduce this project, you will require to have the following environments :
<ul>
<li>Linux Ubuntu VM on VirtualBox</li>
<li>strongSwan installed on both gateways</li>
<li>Internet connectivity</li>
<li> NAT-enabled router management (1 at minimum) </li>
<li>Two distinct LAN networks</li>
</ul>

<h1> 📚 Resources & Useful Links </h1>

Here are the official documentation and community resources that served as the basis for the design and troubleshooting of this architecture:

* **Articles & Tutoriels de Référence :**
  * [Setup a Site to Site IPsec VPN with Strongswan and PreShared Key Authentication](https://ruan.dev/blog/2018/02/11/setup-a-site-to-site-ipsec-vpn-with-strongswan-and-preshared-key-authentication)
  * [Configuring Site-to-Site IPSec VPN on Ubuntu using Strongswan](https://gist.github.com/Horat1us/38b712d65fd11abdab23347eca41b9fb) 
  * [Décortiquer IPsec avec strongSwan sur Debian](https://www.thibautprobst.fr/posts/ipsec/) – Understanding the Theoretical Workings of IPsec and NAT-T + Practical Example
  * [How to Install and Configure IPsec VPN with StrongSwan on Ubuntu 22.04](https://wiki.crowncloud.net/?How_to_Install_and_Configure_IPsec_VPN_with_StrongSwan_on_Ubuntu_22_04) – Command references for generating certificates and key pairs
