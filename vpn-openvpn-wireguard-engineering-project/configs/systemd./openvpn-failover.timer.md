``` text
## Location : /etc/systemd/system/openvpn-failover.timer

[Unit]
Description=Run OpenVPN Failover Script every 10 seconds

[Timer]
OnUnitActiveSec=10s
OnBootSec=10s
Unit=openvpn-failover.service

[Install]
WantedBy=timers.target
```
