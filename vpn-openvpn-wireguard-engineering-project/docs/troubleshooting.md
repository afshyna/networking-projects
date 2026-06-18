# 🛠️  Troubleshooting (Difficulties encountered) & Solutions

This is a central file for general problems (ex : conflits IP, pare-feu, etc.). 

For each problem, it describe the **issue**, the **diagnostic method** ued, the possible **cause** & finally the **solution** to resolve it with a proof capture.

<!--
STRUCTURE :
Issue/Symptômes: [Description courte du problème, ex: "Ping fails between Tokyo and Paris"]
Diagnostic Methods : [Quelle commande t'a permis d'isoler la panne ? ex: tcpdump -ni tun0 ou ip route get ...]
Causes possibles/Analyse : 
Solution(s): [Quelle modification as-tu apportée ? ex: "Ajout de la route dans le fichier ccd"]
Wireshark Analysis: [Lien vers la capture .pcap dans assets/captures-wireshark/ qui prouve que le problème est réglé].
-->



## II. Problèmes de connectivité VPN?


### Troubleshooting 10 
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

