<h1> Set Up OpenVPN Authentication using X.509 Certificates </h1>


<!--
Pour configurer un tunnel VPN IP SSL, on peut utiliser comme méthode d’authentification les certificats X.509 (SSL/TLS + certificat pour l’authentification et l’échange des clés). Ainsi, dans ce projet, nous allons utiliser des certificats digitales pour l’authentification et l’échange des clés. Nous établirons une session SSH entre les clients et les serveurs chacun avec des certificat numériques.

✔ Avantages
•	authentification forte 
•	chiffrement 
•	intégrité 
•	scalable (plusieurs sites) 
•	révocation possible 

La clé privée d'une entité est gardée secrète et sa clé publique est diffusée publiquement par l'intermédiaire de certificats.  
L'autorité de certification (CA) sera créer sur le srv-parismont. Les certificats et autres fichiers que nous allons générer par la suite devront être dans le répertoire /etc/ssl/openvpn. Sur ce serveur VPN nous allons générer les certificats et clefs nécessaires pour OpenVPN. 
1) On créé les répertoires /etc/ssl/openvpn, /etc/ssl/openvpn/certs, /etc/ssl/openvpn/private, /etc/ssl/openvpn/newcerts, /etc/ssl/openvpn/crl. 
2) Copier et renommer le fichier openssl.cnf par /etc/ssl/openvpn/openssl-vpn.cnf  
Remplacer le répertoire par défaut dans ce dernier par /etc/ssl/openvpn 
3) Dans le fichier de configuration /etc/ssl/openvpn/openssl.conf, nous modifions le chemin des 2 lignes « dir » par le chemin  /etc/ssl/openvpn.
Aussi, nous entrons la commande en mode root : 
# echo '01' > serial ; touch index.txt
-->

<h2> Review : Trust Hierarchy </h2>

Every server and client holds:

- CA Certificate (`cacert.pem`): The root of trust that validates the identity of the peer.
- Local Certificate (`<entity>.crt`): The unique identity card of the gateway.
- Private Key (`<entity>.key`): Used to sign authentication challenges.

Each server hold also the Diffie Hellman parameters (dh2048.pem) used for the encryption of the tunnel.  
    
<h2> Step 1 : Generate a certificate for the CA and self-sign it by the CA (ca-cert.pem) </h2>

<pre><code> openssl req -nodes -new -x509 -keyout private/cakey.pem -out cacert.pem -days 365 -config openssl-vpn.cnf  </code></pre>

 <h2> Step 2 : Create certificates & private key for each server and client </h2>
 
<h3> A) Certificate / private key  server Paris </h3>

- Generate the private key of the server (`serveur-parismont.key`) and its CSR (`serveur-parismont.csr`)
<pre><code>openssl req -nodes -new -keyout serveur-parismont.key -out serveur-parismont.csr -config openssl-vpn.cnf </code></pre>


- Sign the CSR certificate with the CA to generate the server Paris certificate (`serveur-parismont.crt`)
<pre><code>openssl ca -out serveur-parismont.crt -in serveur-parismont.csr -config openssl-vpn.cnf</code></pre>

<h3> B) Certificate / private key server Auber </h3>

- Generate the private key of the server (`serveur-auber.key`) and its CSR (`serveur-auber.csr`)
<pre><code>openssl req -nodes -new -keyout serveur-auber.key -out serveur-auber.csr -config openssl-vpn.cnf </code></pre>

- Sign the CSR certificate with the CA to generate the server Auber certificate (`serveur-auber.crt`)
<pre><code>openssl ca -out serveur-auber.crt -in serveur-auber.csr -config openssl-vpn.cnf</code></pre>


<h3> C) Certificate / private key client Tokyo </h3>

- Generate the private key of the server (`client-tokyo.key`) and its CSR (`client-tokyo.csr`)
<pre><code>openssl req -nodes -new -keyout client-tokyo.key -out client-tokyo.csr -config openssl-vpn.cnf </code></pre>

- Sign the CSR certificate with the CA to generate the client Tokyo certificate (`client-tokyo.crt`)
<pre><code>openssl ca -out client-tokyo.crt -in client-tokyo.csr -config openssl-vpn.cnf</code></pre>

<h3> D) Certificate / private key  client NY </h3>

- Generate the private key of the server (`client-NY.key`) and its CSR (`client-NY.csr`)
<pre><code>openssl req -nodes -new -keyout client-NY.key -out client-NY.csr -config openssl-vpn.cnf </code></pre>
- Sign the CSR certificate with the CA to generate the client NY certificate (`client-NY.crt`)
<pre><code>openssl ca -out client-NY.crt -in client-NY.csr -config openssl-vpn.cnf</code></pre>


<h2> Step 3 - Generate Diffie-Hellman parameters for tunnel encryption </h2>

<pre><code>openssl dhparam -out dh2048.pem 2048</code></pre>

The minimum bit must be 2048  sinon openvpn can't be up.
[Voir troubleshooting à faire dans le projet dans github]

This DH parameter will be used by servers when establishing a connection with clients.


<h2> Step 3 : Install the adequat certificates on the server and client </h2>

On each entity (servers & clients) : 
- Install CA certificate (`cacert.pem`) & entity certificate (`<entity>.crt`) / private key (`<entity>.key`) on `/etc/openvpn/tls/` </li>

On servers only : 
- Install DH parameters  on `/etc/openvpn/tls`
