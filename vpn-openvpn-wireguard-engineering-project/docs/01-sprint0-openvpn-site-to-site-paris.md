<h1> 🏁 Sprint 0: Deployment of the OpenVPN Central Hub (Paris) & Multi-Site Interconnection  </h1>

## Objectives of the sprint

The aim of this first sprint is to set up the basic infrastructure for the virtual private network by setting a VPN tunnel between Tokyo/NY clients and the primary site (Paris Montrouge).

- Deploy OpenVPN on  the primary server site (Paris Montrouge) 
- Connect Tokyo & New York clients to the central site  via an unsecured network (Internet)
- Check routing and inter-site communication
- 
### ⚙️ Technical Specifications
* **Protocol**: OpenVPN (VPN SSL/TLS) over UDP transport layer.
* **Security**: Strong authentication via public key infrastructure (X.509 PKI) and asymmetric encryption for key exchange (2048-bit Diffie-Hellman).
* **Addressing Architecture**:
  * **VPN Network (tun0)**: `10.9.1.0/24`
  * **Primary Site (Paris)**: VPN IP `10.9.1.1` | Physical LAN: `192.168.1.197` | Inter-site link: `192.168.100.200`
  * **Tokyo Site**: Fixed VPN IP `10.9.1.2` | Remote Local LAN: `172.20.10.0/28` (VM: `172.20.10.3`)
  * **New York Site**: Fixed VPN IP `10.9.1.3` | Remote Local LAN: `172.20.10.0/28` (VM: `172.20.10.4`)
  * **Backup Site (Aubervilliers)**: No active tunnel at this stage | Inter-site: `192.168.100.210`


## Topologies
- Paris Montrouge : ENP0S3 (WAN), ENP0S8 (LAN 192.168.100.200)
- Aubervillier : ENP0S3 (WAN), ENP0S8 (LAN 192.168.100.210)


## 🔐 2. Initialisation de la PKI (Infrastructure de Clé Publique)
La gestion de la sécurité s'effectue directement sur le serveur `srv-parismont` faisant office d'Autorité de Certification (CA) locale au sein du répertoire `/etc/ssl/openvpn`.

### Étape 1 : Préparation de l'environnement OpenSSL
```bash
# Création de l'arborescence de sécurité
mkdir -p /etc/ssl/openvpn/{certs,private,newcerts,crl}
cp /usr/lib/ssl/openssl.cnf /etc/ssl/openvpn/openssl-vpn.cnf

# Initialisation des registres de la CA
echo '01' > /etc/ssl/openvpn/serial
touch /etc/ssl/openvpn/index.txt



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
