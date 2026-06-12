# VPN Site-to-Site with OpenVPN  & Remote Access VPN with Wireguard

Micro-project reproducing a realistic enterprise VPN architecture.

##  Introduction

Pitch : Contexte de prestation de service pour interconnecter des agences distantes (Tokyo, New York) à un cœur de réseau résilient (Paris Montrouge, Aubervilliers) et sécuriser les accès des collaborateurs itinérants (Nomades).

<h3>  Project summary  </h3>

<h3> Technologies used:  </h3>
- OpenVPN (site-to-site) Robustesse/Routage complexe)
- WireGuard (remote access) (Performance Nomade
- TLS / X.509 PKI
- Linux Routing
- iptables
- Wireshark
- Apache2
- iptables (Sécurisation hardening).


##  Global Objectives  

**Objective 1. Build  Site-to-Site tunnels with OpenVPN**:
   - Connecter les agences **Tokyo** et **New York** aux sites centraux **Paris-Montrouge** et **Aubervilliers**.
   - Implement secure TLS authentication by using  **certificats SSL/TLS** 
   - Route traffic between remote agencies  / Configure **routes statiques** et **iroute** pour le routage entre réseaux locaux.
   - - Configure a disaster recovery site via a **Bascule automatique** vers Aubervilliers si Paris tombe.

**Objective 2. Deploy a remote access (nomade) VPN with Wireguard** :
   - Permettre à un **PC nomade** ou un **smartphone** de se connecter aux serveurs centraux.
   - Utiliser des **clés publiques/privées** pour une connexion légère et rapide.
   - Configurer le **NAT** et le **forwarding** pour accéder à Internet via le VPN.
     Implement VPN failover

##  Architecture 
Hybride On-Premise : Simulation réaliste derrière une Box Internet. Gestion du NAT/PAT, redirection de ports asymétriques (32768 -> 1194 et 32769 -> 1195).
### Schéma Global


## Directory Structure
Brief description of the main folders.

 Un fichier README.md par script, qui servira de Cahier de Recette / Rapport de Test pour valider les opérations.
openvpn-wireguard-site2site-nomad/

├── 00-documentation/          # Schémas, exigences, topologie

├── 01-setup-environment/     # Scripts pour VirtualBox/Oracle Cloud

├── 02-openvpn-site2site/     # Certificats + configs OpenVPN

├── 03-wireguard-nomad/       # Clés + configs WireGuard

├── 04-scripts/               # Failover, tests, monitoring

├── 05-tests-and-results/     # Résultats des tests (Wireshark, pings)

└── 06-extras/                # Sécurité avancée, optimisations

List of files provided in `deliverables/`: Word report, Wireshark traces, config files (SAMPLE), scripts.

## Reproducing the Environment
Quick steps to provision the VMs (reference to `infra/`), ports to forward (32768 -> 1194, 32769 -> 1194), basic connectivity tests.


## Procédure de déploiement (How-to)
<!--
Donne les commandes clés pour que quelqu'un puisse reproduire ton infrastructure :
    Activer le packet forwarding IP.
    Générer les configurations serveurs/clients.
    Lancer le script de pare-feu.
-->



## Security & Implémentation du Hardening Réseau
<!--
Reminder about not committing private keys and the procedure for obtaining certificates.

Explique précisément comment tu as sécurisé le Cas 3.
    Mise en place de la politique restrictive par défaut à DROP partout (INPUT & FORWARD).
    Présentation du script de "Défense en profondeur" (Whitelisting SSH port 22, ports OpenVPN, et ouverture complète mais cloisonnée de l'interface de liaison privée ens5).
-->


## Testing and Acceptance
Summary of tests performed (ping, traceroute, HTTP via tunnel), location of traces, and how to reproduce them.


<h2>  🛠 Troubleshooting & Debugging </h2>

A complete troubleshooting guide (routing issues, NAT, MTU, OpenVPN logs, WireGuard handshake, failover debugging, etc.) is available here:

➡️ [Troubleshooting Guide](docs/troubleshooting.md)



<h2> Achievements & Realizations : </h2>

- Designed and implemented a multi-site VPN infrastructure using OpenVPN (TLS/X.509)
- Connected multiple remote sites (Tokyo, New York, Paris, Aubervilliers)
- Implemented disaster recovery and VPN failover mechanisms
- Configured WireGuard remote-access VPN for nomad users
- Managed Linux routing, static routes, NAT and firewall policies
- Performed packet-level troubleshooting using Wireshark and tcpdump
- Validated connectivity through ICMP, HTTP and traceroute testing
- Simulated production incidents and recovery scenarios

## Contact
Author, date, project version.
