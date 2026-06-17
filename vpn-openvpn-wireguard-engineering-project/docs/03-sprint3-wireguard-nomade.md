<h1> 🏁 Sprint 3 : WireGuard Remote Access VPN with VPN connection from nomade host (PC) to the central site (VPN server Paris) </h1>

##  Sprint Objective

- Configurer l’accès distant via WireGuard.
- Deploy a modern, lightweight WireGuard VPN for remote users (nomad PC + smartphone).
- Allow secure access to internal networks (Paris, Auber, Tokyo, NY).
- Integrate WireGuard into the existing multi‑site OpenVPN architecture.

##  Architecture Overview

### WireGuard Tunnel Network
- WireGuard subnet: 10.9.3.0/2
- Paris server: 10.9.3.1 (UDP/49151)
- Auber server: 10.9.3.2 (UDP/49150)
- Nomad PC: 10.9.3.100
- Iphone : 10.9.3.200

### Physical Networks
- Paris LAN: 192.168.1.0/24
- Auber LAN: 192.168.100.0/24
- Tokyo/NY LAN: 172.20.10.0/28

### Remote Access Concept
A “nomad client” is an external device (4G/5G, Wi‑Fi public, home network) with no direct access to Paris or Auber.
All access must go through WireGuard.

## Key Generation & Server Configuration

### Générer les Clés :
```bash
cd 03-wireguard-nomad/keys
umask 077
wg genkey | tee server-parismont-privatekey | wg pubkey > server-parismont-publickey
```

### Paris Server

- Generate private/public keys
- Configure /etc/wireguard/wg0-paris.conf
- Define peer: nomad PC
- Set endpoint: 88.162.141.79:49151

### Auber Server

- Generate private/public keys
- Configure /etc/wireguard/wg0-paris.conf
- Define peer: nomad PC
- Set endpoint: 88.162.141.79:49150

## Nomad PC Configuration

### Key Generation

- Generate private/public keys on the PC.

### Config client  - Connection with Paris Server  
- PrivateKey = <PRIVATE_KEY_PC>
- PublicKey = <PUBKEY_PARIS>
- Endpoint = 88.162.141.79:49151
- AllowedIPs = 10.9.3.0/24, 192.168.1.0/24, 192.168.100.0/24, 10.9.2.0/24, 172.20.10.0/28

### Config client - Connection with Auber Server   
- PrivateKey = <PRIVATE_KEY_PC>
- PublicKey = <PUBKEY_AUBER>
- Endpoint = 88.162.141.79:49150
- AllowedIPs = 10.9.3.0/24, 192.168.1.0/24, 192.168.100.0/24, 10.9.2.0/24, 172.20.10.0/28

##  Smartphone Configuration

### Key Generation

- Generate keys on the phone.

### Client Config — wg0-phone.conf
- PrivateKey = <PRIVATE_KEY_PHONE>
- PublicKey = <PUBKEY_PARIS>
- AllowedIPs = 10.9.3.0/24, 192.168.1.0/24, 192.168.100.0/24, 10.9.2.0/24, 172.20.10.0/28

### QR Code Import

- Generate QR code using qrencode command
- Scan via WireGuard mobile app
- Activate interface wg0-iphone

##  Routing Configuration

### On Nomad PC

Add internal networks to AllowedIPs:
AllowedIPs = 10.9.3.0/24, 192.168.0.0/16, 10.9.2.0/24, 172.20.10.0/28

### On Auber

Add route to WireGuard network:
ip route add 10.9.3.0/24 via 192.168.100.200 dev enp0s8

### On Tokyo & NY

Add route to WireGuard network via OpenVPN push:
push "route 10.9.3.0 255.255.255.0"

##  Firewall & NAT Configuration
### Firewall Rules

Allow WireGuard port:
ufw allow 49151/udp

### NAT Rules

Add forwarding + masquerade:
PostUp   = iptables -A FORWARD -i %i -j ACCEPT ; iptables -A FORWARD -o %i -j ACCEPT ; iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT ; iptables -D FORWARD -o %i -j ACCEPT ; iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE

### Why NAT is Mandatory

- Required for Internet access

- Required for reaching internal networks

- Required for multi‑site routing

## Launching WireGuard

## Lancement du service WireGuard :


### Server
```bash
wg-quick up wg0-paris
wg-quick up wg0-auber
wg show
```

### Client
```bash
wg-quick up wg0-nomade-pc
wg-quick up wg0-iphone
```

## 🧪 Connectivity Tests

### Nomad → Paris
- Ping 10.9.3.1 → OK
- Ping 192.168.1.197 → OK (after AllowedIPs update)

### Nomad → Auber

- Ping 192.168.1.160 → OK
- Ping 10.9.2.1 → OK

### Nomad → Tokyo
- Ping 172.20.10.3 → FAIL (initial)
- After routing fix → OK

###  Nomad → NY
- Same logic as Tokyo

## Traceroute
Expected path:
Nomad → Paris (10.9.3.1) → Auber (192.168.100.210) → Tokyo

"Est-ce que le ping Nomade vers Aubervilliers passe par Paris Montrouge ou non ?"  (Explique le cheminement du paquet selon l'état des tunnels).


## 🛠️ Troubleshooting 
### Common Issues
- Missing routes in AllowedIPs

- Auber missing route to 10.9.3.0/24

- Tokyo/NY missing route to WireGuard

## Opération 2 (Bonus) 

Explique la logique de ton script de bascule automatique pour activer le tunnel de secours d'Aubervilliers quand Paris est injoignable.

      
📁 Contenu

    Configs WireGuard serveur Paris + Aubervillier

    Configs clients (PC + smartphone)

    Tests ICMP

    Tests traceroute

    Analyse du routage nomade

    Bonus : bascule automatique vers Aubervillier si Paris tombe
    
procédure de génération de clés (wg genkey)




format des fichiers .conf
commandes pour activer l’interface
exemple d’ajout d’un client nomade.
-->
