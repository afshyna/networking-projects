# 🏁 Sprint 4 :  Secondary Wireguard Backup Site Deployment & Automated Network Failover 

##  Sprint Objectives
- Deploy a secondary backup Wireguard VPN server (Aubervilliers).
- Ensure network‑level high availability (HA) between ...
- Implement automatic network failover when the primary VPN server (Paris) becomes unavailable.
- Simulate a failure of the primary site & Incident management on VPN servers
- Support dual connectivity:
      - Nomad → Paris
      - Nomad → Auber
- Set up mobile VPN access enabling a remote user to test the network’s behaviour in the event of a failure at the main site.
   
##  Infrastructure Overview
### Backup Site Role
- Aubervilliers acts as the secondary VPN hub.
- Must be reachable by both PC-nomade when Paris is down.
- LAN IP of Auber : `10.9.4.1/24`

### Tunnel Networks
- Primary : `10.9.3.0/24` 
- Backup tunnel: `10.9.4.0/24` 

## Wireguard Configuration

### Backup (Auber) Server

- Generate private/public keys
 
- Configure wireguard configuration in `/etc/wireguard/wg0-auber.conf` :
```text
[Interface]
Address = 10.9.4.1                        # IP_VPN_SERVER
ListenPort = 49150                        # LISTENING_PORT
PrivateKey = <SERVER_AUBER_PRIVATE_KEY>

[Peer]
PublicKey = <CLIENT-NOMAD-PC_PUBLIC_KEY>
AllowedIPs = 10.9.3.100/32
```

### Client Nomad PC 
- Configure wireguard configuration in `/etc/wireguard/wg0-pc-auber.conf` for a new connection to the Auber server, in addition to wg configuration with Paris server :
```text
[Interface]
Address = 10.9.4.100/32                      # IP_VPN_PC-NOMADE 
PrivateKey = <PRIVATE_KEY_PC>      

[Peer]
PublicKey = <PUBKEY_AUBER>
Endpoint = 88.162.141.79:49150               # <PUBLIC_IP_AUBER>:<LISTENING_PORT>
AllowedIPs = 10.9.4.0/24, 10.9.2.0/24, 192.168.0.0/16, 172.20.10.0/28
```

##  Automatic Failover Configuration with the Backup (Auber) server

##  Routing
Add route to WireGuard network on Paris:
```console
ip route add 10.9.4.0/24 via 192.168.100.210 dev enp0s8
```



### Script 
Explique la logique de ton script de bascule automatique pour activer le tunnel de secours d'Aubervilliers quand Paris est injoignable.

- Located at `/usr/local/bin/`
- Executed every 10 seconds via `System Timers`

*Full script file is available in the root folder scripts/.*

**Script Purpose**

This script ensures automatic switching between the primary Wireguard VPN (Paris) and the backup Wireguard VPN (Aubervilliers). It continuously checks the status of the primary tunnel (if it is shut or not) and activates or deactivates the backup tunnel accordingly.

**Script Logic** : 

The script is based on two tests:
- Testing the reachability of the primary VPN server (Paris) by pinging the tunnel’s IP address `10.9.3.1`.
- Checking the status of the backup Wireguard service (Auber) by verifying the presence of UDP port `49150` in netstat.
    
Based on these results, the script decides:
- to stop the backup VPN if the primary VPN is up
- to start the backup VPN if the primary VPN is down

### Automatic execution

A systemd timer is used for executing of the script automatically (every 10s).

1) Creation of two files:

- a file for service, that runs the script once :  `/etc/systemd/system/wireguard-failover.service`

- a file for timer (with the same name) that will trigger the service every 10 seconds :  `/etc/systemd/system/wireguard-failover.timer`

*Both systemd files are available in the folder configs/systemd/.*

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


