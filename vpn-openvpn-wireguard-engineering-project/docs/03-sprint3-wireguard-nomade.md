<h1> 🏁 Sprint 3 : WireGuard Remote Access VPN with VPN connection from nomade host (PC) to the central site (VPN server Paris) </h1>

##  Sprint Objective
- Set up mobile VPN access enabling a remote user to securely access to internal networks (Paris, Auber, Tokyo, NY).
- Deploy a modern, lightweight WireGuard VPN for remote users (nomad PC + smartphone).
- Integrate WireGuard into the existing multi‑site OpenVPN architecture.

## Why WireGuard?

WireGuard was chosen for:
- its ease of configuration;
- its performance;
- its low CPU usage;
- its use of modern cryptography;
- its minimal number of configuration lines.

Compared to OpenVPN:
| OpenVPN | WireGuard |
|----------|-----------|
| TLS | Built-in cryptography |
| More complex | Very simple |
| More resource-intensive | Very lightweight |
| Multiple certificate files | Public/private key |


##  Architecture Overview
![Architecture Sprint 3](diagrams/04-sprint4-vpn-wireguard-nomade-clients-pc-phone_srv-paris-primary.png)

The Mobile/PC establishes a WireGuard tunnel to:
- Paris-Montrouge (OpenVPN primary server)
- Aubervilliers (OpenVPN backup server)

The WireGuard servers are connected to the OpenVPN network already set up in previous sprints.
The mobile client can therefore access:
- the internal networks of the central sites;
- the networks of the Tokyo and New York offices;
- the VPN addresses of the various tunnels.

###  Addressing plan 
**WireGuard Tunnel Network**:
- WireGuard subnet: `10.9.3.0/24`
- Paris server: `10.9.3.1` (UDP/49151)
- Nomad PC: `10.9.3.100`
- Iphone : `10.9.3.200`

**Physical Networks**:
- backup OpenVPN tunnel subnet : 10.9.2.0/24
- Paris/Auber LAN: `192.168.1.0/24`
- Inter-site Auber-Paris networks: `192.168.100.0/24`
- Tokyo/NY LAN: `172.20.10.0/28`

### Remote Access Concept
A “nomad client” is an external device (4G/5G, Wi‑Fi public, home network) with no direct access to Paris.
All access must go through WireGuard.

## Server Configuration

### Key Generation
Generate public & privates keys !

```bash
cd 03-wireguard-nomad/keys
umask 077
wg genkey | tee server-paris-privatekey.key | wg pubkey > server-parismont-publickey.key
```

### Paris Server Configuration
Set the wireguard configuration in /etc/wireguard/wg0-paris.conf:

```text
[Interface]
Address = <Local_IP_VPN_server>   # 10.9.3.1
ListenPort = <Listenning_port>          # 49151
PrivateKey = <SERVER_PRIVATE_KEY>

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.9.3.100/32
```

## Nomad PC Configuration

- Generate private/public keys of the PC.
- Set the wireguard configuration in /etc/wireguard/wg0-pc-nomade.conf:

```code
[Interface]
Address = <Local_IP_VPN_client>             # 10.9.3.100/32 

[Peer]
Endpoint = <PUBLIC_IP>:<Listenning_port>    # 88.162.41.79:49151
AllowedIPs = 10.9.3.1/32, 192.168.0.0/16
```

##  Smartphone Configuration

### Key Generation
- Generate private/public keys of the smartphone
- Set the wireguard configuration in /etc/wireguard/wg0-phone.conf:

### Client Config — wg0-phone.conf
```text
PrivateKey = <PRIVATE_KEY_PHONE>
PublicKey = <PUBKEY_PARIS>
AllowedIPs = 10.9.3.0/24, 192.168.0.0/16, 10.9.2.0/24, 172.20.10.0/28
```

### QR Code Import

- Generate QR code using qrencode command
- Scan via WireGuard mobile app
- Activate interface wg0-iphone

##  Routing Configuration

### Announce OpenVPN routes (clients)
To join to the 192.168.1.0/24, 192.168.100.0/24, 172.20.10.0/28 and 10.9.2.0/24 networks, PC-nomade must route traffic through its WireGuard VPN tunnel. For doing this, these subnets must be announced to wireguard client via the directive `AllowedIPs=`. It specifies the subnets/host  whose traffic  that you want to route through your VPN tunnel. The rest of the traffic (not specified) will go via your local internet connection.

Add internal networks to AllowedIPs:
`AllowedIPs = 10.9.3.0/24, 192.168.0.0/16, 10.9.2.0/24, 172.20.10.0/28`

### Add routes for Tokyo/NY
Static routes have been added on Tokyo/NY to enable the Nomad client to reach:
- Paris-Montrouge
- Aubervilliers
- Tokyo
- New York

**On Auber**
- Add route for OpenVPN clients to WireGuard network via OpenVPN push:
`push "route 10.9.3.0 255.255.255.0"`

### Add route on Auber
- Add route to WireGuard network via OpenVPN route :
- `route 10.9.3.0 255.255.255.0`

##  Firewall & NAT Configuration

### Firewall Rules
Allow WireGuard port:
`ufw allow 49151/udp`

### NAT Rules
```text
# Add forwarding + masquerade:
PostUp   = iptables -A FORWARD -i %i -j ACCEPT ; iptables -A FORWARD -o %i -j ACCEPT ; iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT ; iptables -D FORWARD -o %i -j ACCEPT ; iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE
```
*Why NAT is Mandatory*
- Required for Internet access
- Required for reaching internal networks
- Required for multi‑site routing

## Launching WireGuard

### Server
```bash
wg-quick up wg0-paris
wg show
```

### Clients
```bash
wg-quick up wg0-nomade-pc
wg-quick up wg0-iphone
```

## 🧪 Connectivity Tests

### Nomad → Paris
- Ping `10.9.3.1` → OK
- Ping `192.168.1.197` → OK (after AllowedIPs update)

### Nomad → Auber

- Ping `192.168.1.160` → OK
- Ping `10.9.2.1` → OK

### Nomad → Tokyo
- Ping `172.20.10.3` → FAIL (initial)
- After routing fix → OK

###  Nomad → NY
- Same logic as Tokyo

## Wireshark Analysis

## Analysis of the routing : Traceroute
Expected path:
Nomad → Paris (`10.9.3.1`) → Auber (`192.168.100.210`) → Tokyo

"Est-ce que le ping Nomade vers Aubervilliers passe par Paris Montrouge ou non ?"  (Explique le cheminement du paquet selon l'état des tunnels).

## 🛠️ Troubleshooting 
### Common Issues
- Missing routes in AllowedIPs

- Auber missing route to `10.9.3.0/24`

- Tokyo/NY missing route to WireGuard

