```config
[Interface]
PrivateKey=0L+CfEf3z24Yq0UYerWn0v0gz9ucOp5M1tKotP98/VA=
Address=10.9.4.1/24
ListenPort=49150
PostUp = iptables -t nat -A POSTROUTING -s 10.9.4.0/24 -o enp0s3 -j MASQUERADE;ip route del 10.177.104.0/24 via 192.168.100.200 dev enp0s8 metric 10
PostDown = iptables -t nat -D POSTROUTING -s 10.9.4.0/24 -o enp0s3 -j MASQUERADE;ip route add 10.177.104.0/24 via 192.168.100.200 dev enp0s8 metric 10

[Peer]
PublicKey=PGls9AinXfS5IdeNqjo13gQI40lYISgFKdSFN/d7yFM=
AllowedIPs=10.9.4.100/32,10.177.104.0/24
```
