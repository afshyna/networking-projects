```text
## Path : /etc/systemd/system/openvpn-failover.service

[Unit]
Description=OpenVPN Failover Script - Switch between Paris VPN & Auber VPN according to the Paris VPN state (shut or active)

[Service]
Type=oneshot
ExecStart=/usr/local/bin/openvpn-failover.sh
```
