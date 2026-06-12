<h1> 🏁 Sprint 0: VPN tunnel between Tokyo/NY clients & the central site VPN Server Paris (10.9.1.1) </h1>

## Objectives
- Deploy OpenVPN on  the central site (Paris Server)
- Connect Tokyo & New York clients to the central site 
- Check routing and inter-site communication

## Topologies
- Paris Montrouge : ENP0S3 (WAN), ENP0S8 (LAN 192.168.100.200)
- Aubervillier : ENP0S3 (WAN), ENP0S8 (LAN 192.168.100.210)

<!--
Tableau d'adressage IP : Récapitule les interfaces (ens3 Internet, ens5 Liaison Spéciale 192.168.100.0/24) pour Paris et Auber.
-->

## Configurations appliquées

## Lancement des services OpenVPN
Démarrer OpenVPN :
```bash
# systemctl start openvpn@server-paris
# systemctl start openvpn@server-auber
# systemctl start openvpn@client-tokyo
```






## Validation  / Connectivity 
<!-- Copie-colle le résultat du ping réussi sur la liaison inter-serveurs (192.168.100.200 <-> 192.168.100.210) et les pings des clients vers internet.-->

- Ping Paris VPN IP  ↔ → Tokyo/New York
- Ping Tokyo LAN → 10.9.1.1
- Ping New York LAN → 10.9.1.1
- HTTP connectivity  via tunnel

## Captures Wireshark
➡️ [Capture-wireshark-connectivity-script0](assets/wireshark)


<!--
expliquer la topologie locale
IPs des interfaces
commandes pour démarrer le serveur
emplacement des logs
commandes pour ajouter un client
exemples de iptables et sysctl

Tunnel Network
10.9.1.0/24
-->



<!-- 
<h2> Issues encountered  </h2>

Puis tu racontes :
problème de routage
problème FORWARD UFW
problème retour ICMP
problème push route
-->
