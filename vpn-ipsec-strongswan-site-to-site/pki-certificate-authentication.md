<h1> How to Set Up site-to-site IPsec Authentication using X.509 Certificates ? </h1>

<h2> Step 1 : Create a CA certificat  </h2>

On a Linux machine (GW-A for example) :

<ul>
<li>Generate the CA private key (ca_key.pem)  
<pre><code>ipsec pki --gen --type rsa --size 4096 --outform pem > ca-key.pem</code></pre>
</li>

<li>Self-sign the CA certificate (ca-cert.pem)  
<pre><code>ipsec pki --self --ca --lifetime 3650 \
--in ca-key.pem \
--type rsa \
--dn "C=FR, O=My Org, CN=IPsec VPN Root CA" \
--outform pem > ca-cert.pem</code></pre>
</li>
</ul>

 <h2> Step 2 : Create certificates for both gateways </h2>
 
<h3> A) Certificate  GW-A </h3>
<ul>
<li>Generate the private key of GW-A (gwA-key.pem)  
<pre><code>ipsec pki --gen --type rsa --size 4096 --outform pem > gwA-key.pem</code></pre>
</li>

<li>Generate CSR + sign with CA  
<pre><code>ipsec pki --pub --in gwA-key.pem --type rsa | \
ipsec pki --issue \
--lifetime 1825 \
--cacert ca-cert.pem \
--cakey ca-key.pem \
--dn "C=FR, O=My Org, CN=gwA.vpn.local" \
--san gwA.vpn.local \
--flag serverAuth \
--flag ikeIntermediate \
--outform pem > gwA-cert.pem</code></pre>
</li>
</ul>

<h3> B) Certificate GW-B </h3>
<ul>
<li>Generate the private key of GW-B (gwB-key.pem)  
<pre><code>ipsec pki --gen --type rsa --size 4096 --outform pem > gwB-key.pem</code></pre>
</li>

<li>Generate CSR + sign with CA  
<pre><code>ipsec pki --pub --in gwB-key.pem --type rsa | \
ipsec pki --issue \
--lifetime 1825 \
--cacert ca-cert.pem \
--cakey ca-key.pem \
--dn "C=FR, O=My Org, CN=gwB.vpn.local" \
--san gwB.vpn.local \
--flag serverAuth \
--flag ikeIntermediate \
--outform pem > gwB-cert.pem</code></pre>
</li>
</ul>

<h2> Step 3 : Install the certificates </h2>

On GW-A :
<ul>
<li>Install CA certificate  
<pre><code>cp ca-cert.pem /etc/ipsec.d/cacerts/</code></pre>
</li>
<li>Install GW-A certificate  
<pre><code>cp gwA-cert.pem /etc/ipsec.d/certs/</code></pre>
</li>
<li>Install GW-A private key  
<pre><code>cp gwA-key.pem /etc/ipsec.d/private/</code></pre>
</li>
</ul>

On GW-B: (use scp to copy certificates from GW-A to GW-B)
<ul>
<li>Install CA certificate  
<pre><code>cp ca-cert.pem /etc/ipsec.d/cacerts/</code></pre>
</li>
<li>Install GW-B certificate  
<pre><code>cp gwB-cert.pem /etc/ipsec.d/certs/</code></pre>
</li>
<li>Install GW-B private key  
<pre><code>cp gwB-key.pem /etc/ipsec.d/private/</code></pre>
</li>
</ul>
