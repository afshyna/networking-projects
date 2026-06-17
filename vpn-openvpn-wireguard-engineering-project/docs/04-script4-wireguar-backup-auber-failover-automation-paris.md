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

##  Configurer la Bascule Automatique
### WireGuard
```bash
chmod +x wireguard_failover_bascule.sh
sudo crontab -e
```


