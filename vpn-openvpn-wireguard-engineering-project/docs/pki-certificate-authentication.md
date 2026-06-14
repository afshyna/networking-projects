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
-->

<h2> PKI Concept : Trust Hierarchy </h2>

Every server and client holds:

- CA Certificate (`cacert.pem`): The root of trust that validates the identity of the peer.
- Local Certificate (`<entity>.crt`): The unique identity card of the gateway.
- Private Key (`<entity>.key`): Used to sign authentication challenges.

Each server hold also the Diffie Hellman parameters (`dh2048.pem`) used for the encryption of the tunnel.  

<h2> Step 0.5 - Setting up the OpenSSL environment </h2>

```bash
# Creating the security tree
mkdir -p /etc/ssl/openvpn/{certs,private,newcerts,crl}

# Initialising the CA registers
echo '01' > /etc/ssl/openvpn/serial
touch /etc/ssl/openvpn/index.txt
```
Technical note: The `openssl-vpn.cnf` file has been edited to change the variable `dir = /etc/ssl/openvpn` in order to isolate our CA.


<h2> Step 1 - Generation of a self-signed certificate   </h2>
    
Generate a certificate for the CA and self-sign it.
<pre><code> openssl req -nodes -new -x509 -keyout cakey.pem -out cacert.pem -days 365 -config openssl-vpn.cnf  </code></pre>

- CA identity fields (Paramètres renseignés) : `C=FR, ST=IDF, L=Paris, O=MyVPN-Project, OU=IT-Security, CN=myvpn-ca`

 <h2> Step 2 - Generation and signing of certificate requests Servers and Clients  </h2>

1) Generate the private key of the entity (`<entity>.key`) and its Certificate Signing Requests/CSR (`<entity>.csr`)
2) Sign the CSR by the CA (`<entity>.crt`)

<h3> Certificate / private key  server Paris </h3>

<pre><code>openssl req -nodes -new -keyout serveur-parismont.key -out serveur-parismont.csr -config openssl-vpn.cnf 
openssl ca -out serveur-parismont.crt -in serveur-parismont.csr -config openssl-vpn.cnf</code></pre>


<h3> Certificate / private key server Auber </h3>

<pre><code>openssl req -nodes -new -keyout serveur-auber.key -out serveur-auber.csr -config openssl-vpn.cnf
openssl ca -out serveur-auber.crt -in serveur-auber.csr -config openssl-vpn.cnf</code></pre>


<h3> Certificate / private key client Tokyo </h3>

<pre><code>openssl req -nodes -new -keyout client-tokyo.key -out client-tokyo.csr -config openssl-vpn.cnf
openssl ca -out client-tokyo.crt -in client-tokyo.csr -config openssl-vpn.cnf</code></pre>

<h3> Certificate / private key  client NY </h3>

<pre><code>openssl req -nodes -new -keyout client-NY.key -out client-NY.csr -config openssl-vpn.cnf 
openssl ca -out client-NY.crt -in client-NY.csr -config openssl-vpn.cnf</code></pre>

<h2> Step 3 - Generation of Diffie-Hellman parameters </h2>

<pre><code>openssl dhparam -out dh2048.pem 2048</code></pre>

The minimum bit must be 2048  sinon openvpn can't be up.
[Voir troubleshooting à faire dans le projet dans github]

This DH parameter will be used by servers for establishing a secure key exchange with clients during the SSL/TLS connection.

<h2> Step 3 - Install the adequat certificates on the server and client </h2>

On each entity (servers & clients) : 
- Install CA certificate (`cacert.pem`), entity certificate (`<entity>.crt`) and private key (`<entity>.key`) on `/etc/openvpn/tls/` </li>

On servers only : 
- Install DH parameters  on `/etc/openvpn/tls`
