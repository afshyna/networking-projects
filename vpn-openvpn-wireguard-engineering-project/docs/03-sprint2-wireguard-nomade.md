<h1> 🏁 Sprint 2 : WireGuard Remote Access VPN with VPN connection from nomade host (PC) to the central site (VPN server Paris)c </h1>


## Sprint Objective

- Configurer l’accès distant via WireGuard.


## Configurations

### Générer les Clés :
```bash
# cd 03-wireguard-nomad/keys
# umask 077
# wg genkey | tee server-parismont-privatekey | wg pubkey > server-parismont-publickey
```

## Lancement du service WireGuard :
```bash
# wg-quick up wg0-paris  # Sur le serveur
# wg-quick up wg0-paris-client  # Sur le client
```

##  Configurer la Bascule Automatique
Pour OpenVPN :
```bash
cd 04-scripts/failover
chmod +x openvpn-failover.sh
sudo crontab -e
```
Ajoutez :
```
* * * * * /chemin/vers/openvpn-wireguard-site2site-nomad/04-scripts/failover/bascule.sh
```
Pour WireGuard :

```bash
chmod +x wireguard-failover.sh
sudo crontab -e
```

Ajoutez :
```
* * * * * /chemin/vers/openvpn-wireguard-site2site-nomad/04-scripts/failover/failover_wireguard.sh
```




<!--
Ce dossier montre ton ouverture vers des technologies modernes et performantes (WireGuard) et tes compétences en scripting.
Dans le dossier scripts/ : Dépose ton fameux script failover_wireguard.sh qui modifie la métrique de la route automatiquement lors d'une perte de ping, ainsi que la ligne de ta crontab (* * * * * /chemin/failover_wireguard.sh).

Dans le README.md :

Opération 1 : Documente la topologie WireGuard (PC Nomade & Smartphone). Ajoute tes rapports de ping Nomade -> Paris, Nomade -> Auber et Nomade -> Tokyo.

Question d'architecture clé : Réponds textuellement à la question de ton énoncé : "Est-ce que le ping Nomade vers Aubervilliers passe par Paris Montrouge ou non ?" 
(Explique le cheminement du paquet selon l'état des tunnels).

Opération 2 (Bonus) : Explique la logique de ton script de bascule automatique pour activer le tunnel de secours d'Aubervilliers quand Paris est injoignable.

      
📁 Contenu

    Configs WireGuard serveur Paris + Aubervillier

    Configs clients (PC + smartphone)

    Tests ICMP

    Tests traceroute

    Analyse du routage nomade

    Bonus : bascule automatique vers Aubervillier si Paris tombe
    
procédure de génération de clés (wg genkey)
format des fichiers .conf
commandes pour activer l’interface
exemple d’ajout d’un client nomade.
-->
