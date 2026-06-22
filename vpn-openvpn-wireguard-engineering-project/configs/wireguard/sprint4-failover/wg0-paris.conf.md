```text
[Interface]
PrivateKey=EHd4AzPJUVZLIiYXrTTyIJNGZOPYafGOmivS/TPZHW0=
Address=10.9.3.1/24
ListenPort=49151

# Rules Execution when VPN is launched
PostUp = iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE ; ip route del 10.9.4.0/24 via 192.168.100.210 dev enp0s8;ip route del <LAN-client-pc-nomade> via 192.168.100.210 dev enp0s8 metric 10 

# Rules Execution when VPN is stoped
PostDown = iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o enp0s3 -j MASQUERADE ; ip route add 10.9.4.0/24 via 192.168.100.210 dev enp0s8;ip route add <LAN-client-pc-nomade> via 192.168.100.210 dev enp0s8 metric 10 

[Peer]
PublicKey=PGls9AinXfS5IdeNqjo13gQI40lYISgFKdSFN/d7yFM=
AllowedIPs=10.9.3.100/32,<LAN-client-pc-nomade>
```
