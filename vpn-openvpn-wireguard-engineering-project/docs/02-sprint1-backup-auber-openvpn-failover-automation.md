# 🏁 Sprint 1 :  Secondary OpenVPN Backup Site Deployment & Automated Network Failover 

## Sprint Objective
- Deploy a secondary backup VPN server (Aubervilliers).
- Ensure network‑level high availability (HA) between Paris ↔ Tokyo/New York.
- Implement automatic network failover when the primary VPN server (Paris) becomes unavailable/goes offline.
- Simulate a failure of the primary site & Incident management on VPN servers
  
##  Infrastructure Overview

### Backup Site Role
- Aubervilliers acts as the secondary VPN hub.
- Must be reachable by both Tokyo and New York when Paris is down.
- LAN IP of Auber : `192.168.1.160`

### Tunnel Networks
- Primary tunnel: `10.9.1.0/24` (Paris)
- Backup tunnel: `10.9.2.0/24` (Auber)

## 1. Server Configuration on Aubervilliers site

To ensure that the Aubervilliers backup server can properly handle routing back to the client subnets, OpenVPN must map internal virtual endpoints using CDD.

### Routing Constraints & Why CCD is Required
By default, the backup server is unaware of the subnets behind the clients:
- Tokyo LAN → `172.20.10.0/28`
- New York LAN → `172.20.10.4/28`

OpenVPN must know which client owns which LAN, otherwise packets are dropped.
Reference: see Troubleshooting – Missing iroute in Sprint 0.

### CCD Files

1. Create CCD entries for both clients (Tokyo & NY).
2. Add iroute entries to map each remote LAN to the correct client.

> 📑 **Architectural Reference:** The mechanics of OpenVPN's internal routing engine, directory bindings, and the critical role of the `iroute` directive are detailed in the primary site's documentation.
See [Sprint 0: Paris Routing & CCD Configuration](01-sprint0-openvpn-site-to-site-paris.md#iroute-openvpn-internal-routing-table--static-vpn-ip-assignment-ccd).
   
## Port Forwarding for Backup VPN
Traffic coming from the public internet through the edge router (home/box router at Paris) is segregated using port-based forwarding:
* **Primary VPN Tunnel (Paris):** `88.162.141.79:32768 (UDP)` ➔ `192.168.1.197:1194`
* **Backup VPN Tunnel (Aubervilliers):** `88.162.141.79:32769 (UDP)` ➔ `192.168.1.160:1195`

Purpose : Allows remote clients to reach the backup VPN server when Paris is down.

## 2. Client Configuration for Multi‑Server Failover

### Configuration Enhancements
Add the following directives to the client configuration :

```text
# Primary Server VPN (Paris)
remote 88.162.141.79 32768

# Backup Server VPN (Auber)
remote 88.162.141.79 32769

# Connection Parameters for Fast Failover**
- resolv-retry infinite
- keepalive 5 30
```

### Behavior
- `resolv-retry infinite`: Forces the client to infinitely retry resolving and connecting.
- `keepalive 5 30`: Pings the server every 5 seconds. If no response is received within 30 seconds, the client considers the tunnel broken and immediately attempts a connection restart, triggering the switch to the next remote endpoint.

- Clients always try Paris first.
- If unreachable → automatically switch to Aubervilliers.

## 3. Routing Adjustments

To maintain symmetric routing and seamless traffic flow, routing adjustments are required on both primary and backup nodes.

### On Paris (Primary)
Manual routing table entries on Paris ensure cross-site visibility via the local connection link (enp0s8).

Add or verify routes

*Method 1 : add dynamically routes in the conf file :*
```text
# Route de secours vers le réseau LAN des clients VPN
route 172.20.10.0 255.255.255.240 192.168.100.210 100

# Route vers le tunnel VPN de secours
route 10.9.2.0 255.255.255.0 192.168.100.210
```

*Method 2 : add routes statically, in command line*
```bash
ip route add 10.9.2.0/24 via 192.168.100.210 dev enp0s8
ip route add 172.20.10.0/28 via 192.168.100.210 dev enp0s8 metric 100
```

### On Aubervilliers (Backup)
    Add routes to remote LANs via Paris when primary tunnel is UP.
    Add routes via backup tunnel when primary tunnel is DOWN.

**Why Auber Must Know 10.9.1.0/24**
- Required for return traffic when clients are still connected to Paris.
- See Troubleshooting – Return Path Issues.
    
## Automated Failover Script  on Backup Server (Aubervilliers)
 
**Purpose**
Automatically switch routing on Aubervilliers depending on tunnel availability.
When the primary tunnel drops, Aubervilliers must stop routing client traffic through Paris (enp0s8) and instead push it directly through its own backup tunnel (tun0).

**Logic**
- Ping Tokyo’s backup tunnel IP (`10.9.2.2`).
        - If reachable → use backup route.
        - If unreachable → use primary route.

**Script Summary**
- Located at `/usr/local/bin/failover.sh`
- Uses `ip route replace` to update routes dynamically.
- Executed every minute via Root Crontab :
```text
sudo crontab -e

* * * * * /usr/local/bin/failover.sh
```
(Note: For real-time 2-second quick execution, a daemon loop or a systemd timer is recommended over standard cron).

## 🧪 Testing Before Failover
### Ping Tests

    Tokyo → Paris (10.9.1.1 / 192.168.1.197)
    Tokyo → Auber (192.168.1.160 / 192.168.100.210)
    Paris → Tokyo (172.20.10.3 / 10.9.1.2)
    Auber → Tokyo (172.20.10.3 / 10.9.1.2)

### Expected Behavior

    All traffic still uses the primary tunnel (Paris).
    Backup tunnel (10.9.2.0/24) is not yet active.

## Failover Behavior - Incident management on VPN servers with the shutdown of Paris OpenVPN service

### When Paris Goes Down
    Clients switch to Auber via remote 32769.
    Auber updates its route to Tokyo/NY via 10.9.2.0/24.

    Traffic flows:
        Tokyo → Auber → Tokyo LAN
        NY → Auber → NY LAN

### When Paris Comes Back
    Clients reconnect to Paris (first remote).
    Auber restores the primary route.

## Troubleshooting (Sprint 1)
### Common Issues
    Backup tunnel unreachable
    Wrong route metrics
    Auber sending traffic toParis while Paris is down
    Missing CCD entries
    NAT misconfiguration

### References
    See Troubleshooting – Missing iroute
    See Troubleshooting – Return Path Problems
    See Troubleshooting – Failover Script


    
<!--

Dans les dossiers de conf : Fichier server-auber.conf configuré sur le sous-réseau 10.9.2.0/24.
Dans le README.md :
Section de validation de l'Opération 1 & 2 (Pings croisés vers l'infrastructure de secours).
Section Opération 3 : Preuves par curl / wget que les serveurs Web répondent également lorsque les clients interrogent l'IP du tunnel de secours (10.9.2.1).

Organize-le par opérations :
Opération 1 & 2 : Comptes rendus des Pings. 
Explique le cas technique spécifique : Pourquoi le ping depuis Tokyo vers l'interface ETH2 d'Aubervilliers (192.168.100.210) a nécessité l'activation du forwarding IP et l'ajout de routes spécifiques ou la modification des règles par défaut d'Oracle Cloud.

Opération 3 (Recette technique) : Insère les captures ou les logs textuels des traceroute croisés (NY <-> Tokyo) et les captures de tes requêtes HTTP Apache/Nginx (curl http://10.9.1.1).

Contenu :
Configs OpenVPN Aubervillier
Tests ICMP Tokyo/NewYork ↔ Aubervillier
Tests HTTP
Analyse du routage inter-sites

Decrire: 
Aubervilliers
réseau 10.9.2.0/24
double tunnel
-->

<!-- SIMULATION PANNES OPENVPN PARIS
Ce dossier est purement axé sur la Cyber-résilience et la gestion des pannes.

Décris le scénario d'attaque ou de panne : Simulation d'un crash de l'infrastructure principale via pkill openvpn sur Paris Montrouge.

 Analyse d'impact (Validation Opérations 1, 2, 3) : Documente le comportement des clients. Montre via tes traces Wireshark comment le trafic bascule vers le serveur d'Aubervilliers (10.9.2.1) pour maintenir l'accès aux ressources et aux requêtes HTTP, prouvant l'efficacité de ton plan de secours (PRA).



## Contenu
Commande pkill openvpn
Tests ICMP/HTTP/Traceroute pendant la panne
Analyse du basculement vers Aubervillier
Captures Wireshark montrant :
absence de réponses
reroutage
timeouts ICMP



Tu expliques :
Primary Site
Paris

Backup Site
Aubervilliers

Clients:
- Tokyo
- New York

Puis :
pkill openvpn
Simulation de panne.
-->



