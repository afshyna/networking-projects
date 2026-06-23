```config
[Interface]
PrivateKey=QK7A/vOMbonV4EDDezE9+e4itF9Q5tM7/j5e+lNmklM=
Address=10.9.3.100/24
ListenPort=39500
PostUp = iptables -t nat -A POSTROUTING -s 10.9.3.0/24 -o wlp6s0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 10.9.3.0/24 -o wlp6s0 -j MASQUERADE

[Peer]
PublicKey=G0dyr1btf5qCk7B1y3WajBzCLc8X6+07tE8z0ecQ3XQ=
Endpoint=82.67.214.64:49151
AllowedIPs=10.9.3.0/24,192.168.0.0/16,10.9.2.0/24,172.20.10.0/28
PersistentKeepalive = 25
```
