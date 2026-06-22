# Location: /etc/systemd/system/
[Unit]
Description=Wireguard Failover Script - Shut the backup Auber VPN according to the Paris VPN state

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wg-failover-auber.sh
