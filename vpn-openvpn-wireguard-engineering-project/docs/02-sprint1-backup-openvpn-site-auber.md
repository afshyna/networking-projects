<h1> 🏁 Sprint 1 :  Setting a VPN tunnel between Tokyo/NY clients &  the backup site VPN Server Aubervilier (10.9.2.1) </h1>

## Objectif

Mettre en place le site de secours
- Mettre en place une haute disponibilité côté réseau

<!--
        
Dans les dossiers de conf : Fichier server-auber.conf configuré sur le sous-réseau 10.9.2.0/24.
Dans le README.md :
Section de validation de l'Opération 1 & 2 (Pings croisés vers l'infrastructure de secours).
Section Opération 3 : Preuves par curl / wget que les serveurs Web répondent également lorsque les clients interrogent l'IP du tunnel de secours (10.9.2.1).



Organize-le par opérations :
Opération 1 & 2 : Comptes rendus des Pings. 
Explique le cas technique spécifique : Pourquoi le ping depuis Tokyo vers l'interface ETH2 d'Aubervilliers (192.168.100.210) a nécessité l'activation du forwarding IP et l'ajout de routes spécifiques ou la modification des règles par défaut d'Oracle Cloud.

Opération 3 (Recette technique) : Insère les captures ou les logs textuels des traceroute croisés (NY <-> Tokyo) et les captures de tes requêtes HTTP Apache/Nginx (curl http://10.9.1.1).


Contenu :
Configs OpenVPN Aubervillier
Tests ICMP Tokyo/NewYork ↔ Aubervillier
Tests HTTP
Analyse du routage inter-sites

Decrire: 
Aubervilliers
réseau 10.9.2.0/24
double tunnel
-->
