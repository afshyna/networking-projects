# 🏁 Sprint 2 :  Secondary OpenVPN Backup Site Deployment & Automated Network Failover 

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

## 1. OpenVPN Configuration

Only the directives relevant to the architecture are documented here:

### Backup VPN Server (Auber) - Key OpenVPN Directives
- `server 10.9.9.0 255.255.255.0` - Defines the backup VPN tunnel network, that will be used by server/client(s)

- `client-config-dir /etc/openvpn/ccd` - Enables per-client static IP assignment and iroute.
[View more details in the "Static VPN IP Assignment (CCD)" part](###CDD) 

- `client-to-client` - Allows VPN clients to communicate with each other.

- `port 1195` - server listenning port

- `ca`, `cert`, `key`, - `dh`, - `tls-server` : TLS authentication

 - `push ...`,  `route add...`
[View more details about the routing directives](####3.-Routing-Configuration-&-Adjustements 

### Client Configuration for Multi‑Server Failover - Key OpenVPN Directives

On both clients, add a 2nd directives with remote, for the VPN connection with the backup server

```text
# Backup Server VPN (Auber)
remote 88.162.141.79 32769
```

## 3. Routing Configuration & Adjustements

### CCD
OpenVPN must know which client owns which LAN, otherwise packets are dropped.
To ensure that the Aubervilliers backup server can properly handle routing back to the client subnets, OpenVPN must map internal virtual endpoints using CDD.

> 📑 **Architectural Reference:** The mechanics of OpenVPN's internal routing engine, directory bindings, and the critical role of the `iroute` directive are detailed in the primary site's documentation.
See [Sprint 0: Paris Routing & CCD Configuration](01-sprint0-openvpn-site-to-site-paris.md#iroute-openvpn-internal-routing-table--static-vpn-ip-assignment-ccd).

###  Backup Server Push Routes  (OpenVPN file configuration)
Clients (Tokyo/NY) will dynamically receive these routes when connecting to the backup VPN server.

```text
push "route 192.168.1.0 255.255.255.0"
push "route 192.168.100.0 255.255.255.0"
```

### Backup Server route  (OpenVPN file configuration)
- Declare a dynamic route on Paris to instruct it  to reach the Tokyo/NY LAN network by routing via the VPN tunnel: 
`route 172.20.10.0 255.255.255.240`

- Declare also a dynamic route on Paris to instruct it  to reach the primary VPN subnet by routing via its internal interface with Paris, when the Paris tunnel VPN will be UP againt
`route 10.9.1.0 255.255.255.0 192.168.100.200`

### Primary Server Route (OpenVPN file configuration)
- On Paris, make an adjustment on the dynamic route to the LAN network of Tokyo (configured in Step 1) by adding the VPN as gateway and assigning the route  metric 10.
`route 172.20.10.0 255.255.255.240` --> `route 172.20.10.0 255.255.255.240  vpn_gateway 10`

- Moreover, add a new route to the backup VPN subnet with its internal interface with Auber as gateway.
  `route 10.9.2.0/24 via 192.168.100.210 dev enp0s8`

### On Aubervilliers (Backup)
- Add routes to remote LANs via Paris when primary tunnel is UP.
- Add routes via backup tunnel when primary tunnel is DOWN.

See [4. Automated Failover Script on Backup Server (Aubervilliers)](##-Automated-Failover-Script-on-Backup-Server-(Aubervilliers)).

**Why Auber Must Know 10.9.1.0/24**
- Required for return traffic when clients are still connected to Paris.
- See Troubleshooting – Return Path Issues.

### Paris Server  (primary)

### CCD Files

1. Create CCD entries for both clients (Tokyo & NY).
2. Add iroute entries to map each remote LAN to the correct client.


## Port Forwarding for Backup VPN
Traffic coming from the public internet through the edge router (home/box router at Paris) is segregated using port-based forwarding:
* **Primary VPN Tunnel (Paris):** `88.162.141.79:32768 (UDP)` ➔ `192.168.1.197:1194`
* **Backup VPN Tunnel (Aubervilliers):** `88.162.141.79:32769 (UDP)` ➔ `192.168.1.160:1195`

Purpose : Allows remote clients to reach the backup VPN server when Paris is down.

### Behavior
- `resolv-retry infinite`: Forces the client to infinitely retry resolving and connecting.
- `keepalive 5 30`: Pings the server every 5 seconds. If no response is received within 30 seconds, the client considers the tunnel broken and immediately attempts a connection restart, triggering the switch to the next remote endpoint.

- Clients always try Paris first.
- If unreachable → automatically switch to Aubervilliers.

## 4. Automated Failover Script  on Backup Server (Aubervilliers)
 
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


<!--
## 🧪 Testing Before Failover
### Ping Tests
    Tokyo → Paris (10.9.1.1 / 192.168.1.197)
    Tokyo → Auber (192.168.1.160 / 192.168.100.210)
    Paris → Tokyo (172.20.10.3 / 10.9.1.2)
    Auber → Tokyo (172.20.10.3 / 10.9.1.2)
-->
### Expected Behavior

- All traffic still uses the primary tunnel (Paris).
- Backup tunnel (10.9.2.0/24) is not yet active.

## 5. Failover Simulation - Incident management on VPN servers with the shutdown of Paris OpenVPN service

To stop the Paris primary server, terminate the OpenVPN active processes, shut down the system, and prevent any unexpected reboots:

```console
# Kill du processus OpenVPN:
pkill openvpn

# Arrêt du service:
systemctl stop openvpn@server-parismont

# Désactivation du redémarrage automatique:
systemctl disable openvpn@server-parismont
```
---

### Analyse Post-Panne : Impacts Système & Réseau
As soon as the main tunnel 10.9.1.0/24 is disconnected, the following network and system changes are triggered transparently.

**Dynamic Behaviour of VPN Clients (Tokyo / NY)**
- Route Loss: The virtual IP addresses associated with the main tunnel (10.9.1.1 & 10.9.1.2) are immediately flushed from the local tun0 interface.
- Retry & Failover Algorithm: - The client detects a timeout on port 1194.
  - The multi-remote implementation of the client configuration file is executed.
  - Clients switch to the Aubervilliers failover server (Port 1195).
  - After approximately 60 seconds, the failover tunnel is established: a new virtual IP from the 10.9.2.0/24 range is assigned to the tun0 interface.

📊 Progressive Changes to Routing Tables
- VPN Clients: The default gateway for the 10.9.1.X tunnel has been replaced by the IP address of the 10.9.2.X failover interface. Clients switch to Auber (10.9.2.1) via port remote 32769.

- Paris Server: Complete disappearance of dynamic routes linked to the main tunnel (10.9.1.0/24). Manually injected routes remain present.

- Aubervilliers Server: The backup tunnel 10.9.2.0/24 is fully active so auber updates its route to Tokyo/NY via 10.9.2.0/24.
💡 Advanced behaviour in Aubervilliers: As soon as the failover tunnel becomes active, the monitoring script (run via crontab) detects the client’s presence. The route to the branch’s LAN subnet (e.g. 172.20.10.0/28) is dynamically rewritten to pass through its own VPN tunnel: 172.20.10.0/28 via 10.9.2.1 metric 20.


##  Validation des flux - Vérification des routes

Clients VPN
Avant :
192.168.100.0/24 via 10.9.1.1

Après :
192.168.100.0/24 via 10.9.2.1

Serveur Paris
Le réseau 10.9.1.0/2 a disparu.
Les routes statiques restent présentes.

Serveur Aubervilliers
Toutes les routes restent présentes.

Après exécution du sript :
172.20.10.0/28 via 10.9.2.2 remplace 172.20.10.0/28 via 192.168.100.200


### When Paris Comes Back
    Clients reconnect to Paris (first remote).
    Auber restores the primary route.

### Validation Opération 1 - Analyse du basculement vers Aubervillier

Tokyo → Aubervilliers
192.168.1.160	✅
192.168.100.210	✅
10.9.2.1	✅
Le trafic passe désormais par le tunnel VPN de secours.

Tokyo → Paris
192.168.100.200	✅
Analyse
Paris reste joignable via le lien local entre les deux serveurs.

Aubervilliers → Tokyo
172.20.10.3	✅
10.9.1.2	❌
Explication
Le réseau VPN principal n'existe plus.

Paris → Tokyo
172.20.10.3	✅
10.9.1.2	❌
Explication
Le tunnel 10.9.1.0/24 est arrêté.

## Troubleshooting
Temps de bascule supérieur à 1 minute

Cause
Valeurs keepalive trop élevées.

Solution
keepalive 5 30

---

Route vers Tokyo toujours via Paris

Cause
Route statique devenue invalide après panne.

Solution
Script de failover dynamique.

---
Clients reconnectés mais réseau inaccessible

Cause
Routes non poussées par le serveur de secours.

Solution
Ajout des directives : push "route ..."

<!-- Autre troubleshooting possible
Backup tunnel unreachable
Wrong route metrics

### References
    See Troubleshooting – Missing iroute
    See Troubleshooting – Return Path Problems
    See Troubleshooting – Failover Script

-->
    
<!--
Dans le README.md :
Section de validation de l'Opération 1 & 2 (Pings croisés vers l'infrastructure de secours).

Organize-le par opérations :
Opération 1 & 2 : Comptes rendus des Pings. 
Explique le cas technique spécifique : Pourquoi le ping depuis Tokyo vers l'interface ETH2 d'Aubervilliers (192.168.100.210) a nécessité l'activation du forwarding IP et l'ajout de routes spécifiques ou la modification des règles par défaut d'Oracle Cloud.

Opération 3 (Recette technique) : Insère les captures ou les logs textuels des traceroute croisés (NY <-> Tokyo) et les captures de tes requêtes HTTP Apache/Nginx (curl http://10.9.1.1).
Section Opération 3 : Preuves par curl / wget que les serveurs Web répondent également lorsque les clients interrogent l'IP du tunnel de secours (10.9.2.1).


<!-- SIMULATION PANNES OPENVPN PARIS
Ce dossier est purement axé sur la Cyber-résilience et la gestion des pannes.

Décris le scénario d'attaque ou de panne : Simulation d'un crash de l'infrastructure principale via pkill openvpn sur Paris Montrouge.

 Analyse d'impact (Validation Opérations 1, 2, 3) : Documente le comportement des clients. Montre via tes traces Wireshark comment le trafic bascule vers le serveur d'Aubervilliers (10.9.2.1) pour maintenir l'accès aux ressources et aux requêtes HTTP, prouvant l'efficacité de ton plan de secours (PRA).

## Contenu
Captures Wireshark montrant :
absence de réponses
reroutage
timeouts ICMP
-->



