# 🏁 Sprint 4 :  Secondary Wireguard Backup Site Deployment & Automated Network Failover 

##  Sprint Objective
- Deploy a secondary backup Wireguard VPN server (Aubervilliers).
- Ensure network‑level high availability (HA) between ...
- Implement automatic network failover when the primary VPN server (Paris) becomes unavailable.
- Simulate a failure of the primary site & Incident management on VPN servers
- Support dual connectivity:
      - Nomad → Paris
      - Nomad → Auber
   
##  Infrastructure Overview
### Backup Site Role
- Aubervilliers acts as the secondary VPN hub.
- Must be reachable by both PC-nomade when Paris is down.
- LAN IP of Auber : `10.9.4.1/24`

### Tunnel Networks
- Primary : `10.9.3.0/24` 
- Backup tunnel: `10.9.4.0/24` 

## Key Generation & Server Configuration

### Auber Server
- Generate private/public keys
- Configure /etc/wireguard/wg0-auber.conf
- Define peer: nomad PC
- Set endpoint: `88.162.141.79:49150`

### Config client - Connection with Auber Server   
- PrivateKey = <PRIVATE_KEY_PC>
- PublicKey = <PUBKEY_AUBER>
- Endpoint = 88.162.141.79:49150
- AllowedIPs = 10.9.4.0/24, 192.168.1.0/24, 192.168.100.0/24, 10.9.2.0/24, 172.20.10.0/28



##  Configurer la Bascule Automatique

##  Routing Configuration on Paris
Add route to WireGuard network:
ip route add 10.9.4.0/24 via 192.168.100.210 dev enp0s8

### WireGuard
Explique la logique de ton script de bascule automatique pour activer le tunnel de secours d'Aubervilliers quand Paris est injoignable.

```bash
chmod +x wireguard_failover_bascule.sh
sudo crontab -e
```


