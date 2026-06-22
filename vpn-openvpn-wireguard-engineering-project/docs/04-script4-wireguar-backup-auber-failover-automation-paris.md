# 🏁 Sprint 4 :  WireGuard Remote Access & site-to-site VPN with Backup Server & Automatic Failover

##  Sprint Objectives
- Add a secondary WireGuard server on Aubervilliers.
- Ensure network‑level high availability (HA) between Paris and Aubervilliers.
- Implement automatic network failover mechanisms when the primary VPN server (Paris) becomes unavailable.
- Simulate failure of the primary site & manage incidents on VPN servers
- Support dual connectivity: Nomad → Paris & Nomad → Auber
- Validate connectivity to all LANs

##  Infrastructure Overview
![Architecture Sprint 4](../diagrams/)

### Backup Site Role
- Aubervilliers acts as the secondary VPN hub.
- Must be reachable by both PC-nomade when Paris is down.
- LAN IP of Auber : `10.9.4.1/24`

###  Addressing plan 

**WireGuard Tunnel Networks**:
- Primary WireGuard subnet : `10.9.3.0/24`
      - Paris WireGuard server: `10.9.3.1` (UDP/49151)
      - Nomad PC: `10.9.3.100`
- Backup WireGuard tunnel subnet: `10.9.4.0/24`
      - Paris WireGuard server: `10.9.4.1` (UDP/49150)
      - Nomad PC: `10.9.4.100`

**Physical Networks**:
- Public/WAN IP Nomad PC : `a.b.c.d`
- Public/WAN IP Paris : `82.X.Y.Z`
- Backup OpenVPN tunnel subnet : `10.9.2.0/24`
- Paris & Auber LAN: `192.168.1.0/24`
- Inter-site Auber-Paris network: `192.168.100.0/24`
- Tokyo/NY LAN: `172.20.10.0/28`
- PC Nomade LAN: <LAN-pc-nomade>/24` (IP PC : <IP-LAN-pc-nomade>)

## 1. Wireguard Configuration

### 1.1. Backup (Auber) Server

- Generate private/public keys
 
- Configure wireguard configuration in `/etc/wireguard/wg0-auber.conf` :
```text
[Interface]
Address = 10.9.4.1                        # IP_VPN_SERVER
ListenPort = 49150                        # LISTENING_PORT
PrivateKey = <SERVER_AUBER_PRIVATE_KEY>

[Peer]
PublicKey = <CLIENT-NOMAD-PC_PUBLIC_KEY>
AllowedIPs = 10.9.3.100/32, <IP-LAN-pc-nomade>
```

### 1.3. Client Nomad PC 
Two interfaces are used:
- wg0-pc-paris.conf - Primary tunnel

- wg0-pc-auber.conf - Backup tunnel  
```text
[Interface]
Address = 10.9.4.100/32                      # IP_VPN_PC-NOMADE 
PrivateKey = <PRIVATE_KEY_PC>      

[Peer]
PublicKey = <PUBKEY_AUBER>
Endpoint = 82.X.Y.Z:49150               # <PUBLIC_IP_AUBER>:<LISTENING_PORT>
AllowedIPs = 10.9.4.0/24, 10.9.2.0/24, 192.168.0.0/16, 172.20.10.0/28
```

## 2. Routing Configuration

### Nomad PC
WireGuard uses AllowedIPs as routing table.
```text
# wg-pc-paris.conf - This allows access to: Paris LAN, Inter-server LAN, OpenVPN backup tunnel, Tokyo LAN.
AllowedIPs = 10.9.3.0/24,192.168.0.0/16,172.20.10.0/28,10.9.2.0/24
```

```text
# wg-pc-auber.conf - This allows access to: Paris LAN, Inter-server LAN, OpenVPN backup tunnel, Tokyo LAN.
AllowedIPs = 10.9.4.0/24,192.168.0.0/16,172.20.10.0/28,10.9.2.0/24
```


### Paris routes
Paris is not directly connected to the backup WireGuard network.


### Auber routes

Aubern, when it doesn't act as a server wireguard, initially reaches WireGuard clients through Paris via a static IP route  (Sprint 3): 
```console
ip route add 10.9.3.0/24 via 192.168.100.200 dev enp0s8 
```
When backup VPN becomes active:
- addition of dynamic routes (10.9.4.0/24 subnet & LAN PC nomadic) via 10.9.4.0/24, implemented through "AllowedIPs" :
```text
AllowedIPs = 10.9.3.100, <LAN-pc-nomade>
```

- Removal of obsolete static routes, implemented through: PostUp / PostDown. 
```text
PostUp = ip route del <LAN-pc-nomade> via 192.168.100.210 dev enp0s8 dev metric 10
PostDown = ip route add <LAN-pc-nomade> via 192.168.100.210 dev enp0s8 metric 10
```
Note : Given that a route to this same network is automatically added when the Auber server reboots, the route injected/delete via the Paris gw, must have a higher metric than the dynamic route, so that the latter remains the preferred route.

### OpenVPN routes

Tokyo and New York must know the WireGuard network so this route needs to be pushed from  the current active OpenVPN server (Auber):
```text
push "route 10.9.4.0 255.255.255.0"
```

## 3. Firewall & NAT

### Firewall Rule
Allow incoming WireGuard traffic on Auber :
`ufw allow 49150/udp`

### Port Forwarding (Paris router)**
Rule applied: `From everywhere on Internet connecting to external port UDP/49150 ➔ to 192.168.1.160 on internal port 49150`

### IP forwarding
Kernel : Activation of `net.ipv4.ip_forward`.

### Iptables Rules (NAT)
```text
# Auber server conf 
PostUp = iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE
```

```text
# Wireguard Client conf 
PostUp = iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o wlp6s0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o wlp6s0 -j MASQUERADE
```

## 4. Automatic Failover

Objective :Switch automatically to the backup WireGuard server when Paris becomes unreachable and switch to Paris when primary tunnel becomes available again.

*Full script file is available in the root folder scripts/.*

### Nomad script  
File : /usr/local/bin/wg-failover-pc.sh

**Logic**:
Ensuite automatic switching between the primary Wireguard VPN (Paris) and the backup Wireguard VPN (Aubervilliers). It continuously checks the status of the primary tunnel and activates or deactivates the primary and backup tunnel accordingly.

### Auber script
File:/usr/local/bin/wg-failover-auber.sh

**Purpose**:
The script is based on two tests:
- Testing the reachability of the primary VPN server (Paris) by pinging the tunnel’s IP address `10.9.3.1`.
- Checking the status of the backup Wireguard service (Auber) by verifying the presence of listening server UDP port `49150` in netstat.

  
Based on these results, the script decides:
- Start backup server (if not up already) if Paris is down.
- Stop backup server (if up already) when Paris returns. 


### Automatic execution
- Automatic execution of scrupts every 10 seconds using `Systemd Timers`

- **Services Files** : that runs the script once
      - wg-failover-pc.service
      - wg-failover-auber.service

- **Timers** : trigger the service every 10 seconds
      - wg-failover-pc.timer
      - wg-failover-auber.timer

*Both systemd files are available in the folder configs/wireguard/systemd/.*

2) Reload the `systemd`
```console
systemctl daemon-reload
```

3) start your `timer` or enable it by default
```console
systemctl start wireguard-failover.timer
systemctl enable --now wireguard-failover.timer
```


### Expected Behavior before the failover
- All traffic still uses the primary tunnel (Paris), that works initially.
- Backup tunnel (10.9.4.0/24) is not yet active.

## 6. Paris server failover Simulation & Incident management on VPN servers 

To stop the Paris primary server, shutdown the system service: 
```console
wg-quick down wg0-paris      
```

### Post-Failure Analysis: System and Network Impacts
As soon as the main tunnel `10.9.3.0/24` is disconnected, the following network and system changes are triggered transparently.

**Dynamic Behaviour of the VPN Client (PC nomad)  & Auber Backup Server**
- Route Loss: The virtual IP addresses associated with the main tunnel (`10.9.3.1` & `10.9.3.2`) are immediately flushed from the local wg0-X interface.
<!-- 
- Retry & Failover Algorithm:
  - The client detects a timeout on port 1194.
  - the client re-try the connection to the Paris server (port `1194`).
  - Once again, a timeout is detect.
[Reconnexion Attempt Tokyo -> Paris & timeout detected](../assets/verifs/sprint2/log-tokyo-attempt-reconnexion-tokyo-paris.png)
  - The multi-remote implementation of the client configuration file is executed. Now, the client try to connect to the backup auber openvpn server  (Port `1195`) and the connection is establised.

  [Log Tokyo - Connexion Successful Tokyo -> Backup Server](../assets/verifs/sprint2/log-tokyo-attempt-connexion-tokyo-auber-successful.png)
  [Log Auber - Connexion Successful Tokyo -> Backup Server](../assets/verifs/sprint2/log-auber-attempt-connexion-tokyo-auber-successful.png)

After approximately 1 minutes, the failover tunnel is established: a new virtual IP from the `10.9.2.0/24` range is assigned to the tun0 interface.
-->

## 7. Flow validation & Route verification - Progressive Changes to Routing Tables 

**Server Paris**
Complete disappearance of dynamic routes linked to the main tunnel (`10.9.3.0/24`).
- The `10.9.3.0/24` network and the subnets to the distant LAN of PC () via the Paris VPN tunnel have disappeared.

[Routing Table Paris Before failover](../assets/verifs/sprint4/)
[Routing Table Paris After failover](../assets/verifs/sprint4/) 
 
**VPN Client**
 The default gateway for the `10.9.3.X` tunnel has been replaced by the IP address of the `10.9.4.X` failover interface. Clients switch to Auber (`10.9.4.1`) via port remote `49150`.
- Before : `192.168.100.0/24 via 10.9.3.1` | `192.168.1.0/24 via 10.9.3.1` | `172.20.10.0/28 via 10.9.3.1`
- After : `192.168.100.0/24 via 10.9.4.1` | `192.168.1.0/24 via 10.9.4.1`  | `172.20.10.0/28 via 10.9.4.1`

[Routing Table VPN PC-nomad Before failover](../assets/verifs/sprint4/)
[Routing Table VPN PC-nomad After failover](../assets/verifs/sprint4/)

  
**Server Aubervilliers**
- As soon as the primary tunnel is shutdown, the monitoring script (run via `Systemd timers`) detects it and launch the Auber server Wireguard service. The backup tunnel `10.9.4.0/24` became fully active
- A second route to the private remote LAN (e.g. `172.20.10.0/28`) is dynamically injected to pass through its own VPN tunnel: `172.20.10.0/28 via 10.9.2.1`.
- The routes to the Auber/Paris LAN subnet (e.g. `192.168.x.y/16`) via its own VPN tunnel are dynamically injected to the VPN clients.

[Routing Table Auber Before failover](../assets/verifs/sprint4/)
[Routing Table Auber After failover](../assets/verifs/sprint4/)


## 8. Validation & Connectivity ✅  
- Ping OK = Tokyo → Aubervilliers (`192.168.1.160`, `192.168.100.210`, `10.9.2.1`) 
  
- Ping OK = Tokyo → Paris (`192.168.100.200`,`192.168.100.197` )

- Ping OK = Aubervilliers → Tokyo (`172.20.10.10`, `10.9.2.2`)

- Ping OK  = Paris → Tokyo(`172.20.10.9`, `10.9.2.2`)


