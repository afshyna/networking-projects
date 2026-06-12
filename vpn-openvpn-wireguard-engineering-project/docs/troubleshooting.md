# 🛠️ **Fichier central** pour les problèmes GENERAUX (ex : conflits IP, pare-feu, etc.)  /  Troubleshooting & Lessons Learned
# Troubleshooting – Micro Projet VPN OpenVPN & WireGuard


STRUCTURE :
Issue/Symptômes: [Description courte du problème, ex: "Ping fails between Tokyo and Paris"]

Diagnostic Methods : [Quelle commande t'a permis d'isoler la panne ? ex: tcpdump -ni tun0 ou ip route get ...]

Causes possibles/Analyse : 

Solution(s): [Quelle modification as-tu apportée ? ex: "Ajout de la route dans le fichier ccd"]

Wireshark Analysis: [Lien vers la capture .pcap dans assets/captures-wireshark/ qui prouve que le problème est réglé].
       

################ 2. Problèmes de routage inter-sites
Tu dois inclure :
    Routes manquantes
    Mauvais iroute dans ccd/
    Sous‑réseaux non annoncés
    Asymétrie de routage
    Pas de push "route …"
    Mauvaise table de routage Linux
  
# -------------- TROUBLESHOOTING 1 
Issue  : Au sprint 0, le ping Tokyo → Paris-IP-LAN-privé ne passait pas. 

Analyse : 

🛠️ Solution : 
• Le serveur doit "poussé" la route du LAN au client Tokyo. En effet, sans le “push”, il n’y pas de route vers 192.168.1.0/24 depuis Tokyo.


# -------------- TROUBLESHOOTING 2 
Issue : Au sprint 0, Le ping Tokyo → Aubervillier (192.168.100.210) ne passait pas. 

Analyse : route manquante dans CCD. 

🛠️ Solution : 
• Activer le routage IP sur Montrouge : : permet de router le paquet depuis Tokyo vers le serveur de secours
•Pour ajouter une route sur Tokyo, Côté serveur (Paris) : on ajoute dans le fichier openvpn : 
push "route 192.168.100.0 255.255.255.0" 

•On ajouter une route statique sur le serveur Aubervilliers  pour lui dire : "Pour répondre à Tokyo, repasse par l'interface locale de Paris".
ajout de iroute 172.20.10.0/28.
 
# -------------- TROUBLESHOOTING 3
Issue : Au sprint 0, le ping 2. PING  depuis Paris Montrouge vers l’adresse Tokyo (172.20.10.3) ne passait pas!

🛠️ Solution : 
•Utilisez l’adresse VPN de Tokyo (10.9.1.2) pour communiquer.  Pour cela on ajoute une route vers 172.20.10.0 via le tunnel vpn sur Paris, en ajoutant la route dans le fichier de conf :

•On doit créer et activer les entrées ccd. 

# -------------- TROUBLESHOOTING 4 
# SPRINT 0: ING depuis la machine Site de Secours (192.168.100.210/192.168.1.160) vers Tokyo (172.20.10.3)  ne passe pas;

🛠️ Solution : 
1.Tu dois ajouter une route statique sur l'OS d'Aubervilliers pour lui dire : "Pour répondre à Tokyo, repasse par l'interface locale de Paris"

2.Une route vers le réseau 172.20.10.0 via le tunnel IP  est ajoutée (fait précédemment lors du ping du serveur paris vers 172.20.10.3 = tokyo)

3.Ajouter une iroute sur le serveur de paris pour indiquer à OpenVPN de router le paquet vers le réseau LAN de Tokyo.  (fait précédemment lors du ping du serveur paris vers 172.20.10.3 = tokyo)

# -------------- TROUBLESHOOTING 5 
Issue : Au sprint 0, depuis Tokyo une requete HTTP vers le serveur web de secours aubervillier wget http://192.168.100.210 ne passe pas


Analyse : 
OU FORWARD iptables bloqué
FORWARD policy DROP

🛠️ Solution : 
autoriser le forwarding VPN → LAN
Sur Paris :  iptables -A FORWARD -i tun0 -o enp0s8 -j ACCEPT

# -------------- TROUBLESHOOTING 6
Issue : Au sprint 1, il y a conflit de routes identiques lorsqu'on test le serveur auber uniquement.
LOrsqu'on veut tester le serveur auber uniquement, on oublie pas de retirer les routes statiques configurés sur auber au sprint 0 pour tester le serveur paris, car sinon il y aura un 

⚠️ Attention à la "Guerre des Tunnels"
Comme mes clients ont 2 tunnels ouverts, quand je ping  192.168.100.210 depuis Tokyo :
1.	Linux regarde sa table.
2.	Il voit 2 routes identiques.
3.	Il choisit souvent la première (souvent tun0).

🛠️ Solution : 
Conseil pour la recette : Comme je veux tester spécifiquement le Sprint 1 (Auber), je vais couper temporairement le tunnel vers Paris sur le client => Cela forcera le trafic à passer par tun1 (Auber) et tu pourras valider que tes configurations iroute sur le serveur de secours sont correctes.
 + supprimer toutes les routes ajoutées manuellement (comme celles sur auber):
@srv-aub:/etc/openvpn/ccd$ sudo ip route del 10.9.1.0/24 via 192.168.100.200 dev enp0s8  
@srv-aub:/etc/openvpn/ccd$ sudo ip route del 172.20.10.0/28 via 192.168.100.200 dev enp0s8


# -------------- TROUBLESHOOTING 7
Issue : Au sprint 4, le Ping de nomade vers Aubervillier (192.168.X.Y : 192.168.100.210/192.168.1.160) ne passe pas

Analyse : PC nomade n’a pas de route vers les réseaux 192.168.X.Y. WireGuard ne route pas les réseaux physiques par défaut. Il ne transporte que les réseaux déclarés dans AllowedIPs.

🛠️ Solution : 
- Depuis le fichier de conf wg0.conf de pc-nomade (client), on ajoute le réseau 192.168.0.0/26 dans « Allowed IPs »  AllowedIPs=10.9.3.1, 192.168.0.0/16
- J’ajoute une route depuis auber vers le réseau de wireguard

# -------------- TROUBLESHOOTING 8 
Issue : Au sprint 4, le ping de nomade vers Aubervilliers (10.9.2.1) passe pas

Problème/Analyse: PC nomade n’a pas de route vers le réseau VPN de secours 10.9.2.0/24


🛠️Solution : 
Depuis le fichier de conf wg0.conf de pc-nomade (client), on ajoute l’IP VPN de secours côté auber dans « Allowed IPs »  AllowedIPs=10.9.3.1, 192.168.0.0/16, 10.9.2.0/24

# -------------- TROUBLESHOOTING 9 
Issue : Au sprint 4, le ping de nomade vers Tokyo (172.20.10.3)   passe pas

Problème: 
-PC nomade n’a pas de route vers les réseaux 172.20.X.Y ; WireGuard ne transporte pas les réseaux LAN des clients.
-Tokyo n’a pas de route vers le réseau de wireguard

🛠️Solution : 
-Depuis le fichier de conf wg0.conf de pc-nomade (client), on ajoute le réseau 172.20.10.0/28 dans « Allowed IPs » 
-J’ajoute une route depuis Tokyo vers le réseau de wireguard 
oMéthode  1 : on la rajoute en ligne de commande depuis tokyo
oMéthode2 : on rajoute la route directement dans le fichier de conf openvpn d’auber pour qu’elle soit automatiquement ajoutée au prochain reboot de openvpn




## 1. Problèmes de connectivité VPN?


# -------------- TROUBLESHOOTING 10 
Issue : Au sprint 2, LOrsqu'on doit stoppe le service openvpn côte serveur paris, service redevient up peu de temps après 
 l'interface tun0 réaparrait avec son IP virtuelle ; 

🛠️ Solution : 
 on  désactive le service pour empêcher tout redémarrage automatique : 
sudo systemctl disable openvpn@server-parimont 



## 3. Problèmes NAT / Firewall ?
- Symptômes
- Vérifications iptables / ufw
- Solutions

## 4. Problèmes liés aux certificats ?
- Symptômes
- Vérifications
- Solutions

## 6. Problèmes de failover?
- Symptômes
- Analyse du script
- Solutions

## 7. Analyse Wireshark?
- Filtres utilisés
- Ce que tu as observé
- Comment tu as trouvé la cause

