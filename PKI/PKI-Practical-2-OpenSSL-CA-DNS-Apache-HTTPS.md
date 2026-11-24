# PKI Practical 2: Private CA + HTTPS Website (Trimmed)

**Goal:** Build Root CA → Sub CA → Website certificate with OpenSSL, set up DNS with BIND9, serve `https://www.boomshakalaka.in` with Apache, and make Windows trust it.

| Machine | Role |
|---|---|
| Ubuntu VM (`192.168.142.142`, user `pki`) | CA + DNS + Web server |
| Windows 11 | Client / browser |

```
rootCA11 ──signs──► subCA11 ──signs──► www.boomshakalaka.in
(10 years)          (5 years)          (1 year)
```

---

## Step 1: Folder structure

```bash
mkdir -p ~/pKI/{rootca,subca,web}/{certs,csr,private}
```

- `certs/` holds issued certificates.
- `csr/` holds Certificate Signing Requests.
- `private/` holds private keys (keep secret).

---

## Step 2: Root CA (self-signed)

```bash
cd ~/pKI/rootca
openssl genrsa -out private/rootCA11.key 2048
openssl req -x509 -new -nodes -key private/rootCA11.key \
  -sha256 -days 3650 -out certs/rootCA11.crt
```

Enter: Country `IN`, State `MH`, Locality `Pune`, Org `CDAC`, OU `ACTS`, **Common Name `rootCA11`**. Email can be blank.

- `-x509` creates a certificate directly (self-signed) instead of a CSR.
- `-nodes` saves the key without a passphrase (fine for a lab, not for production).

`rootCA11.crt` is the trust anchor.

---

## Step 3: Sub CA (signed by Root CA)

```bash
cd ~/pKI/subca
openssl genrsa -out private/subCA11.key 2048
openssl req -new -key private/subCA11.key -out csr/subCA11.csr   # CN = subCA11
```

Create `subca_ext.cnf`:

```ini
basicConstraints=critical,CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
```

| Line | Purpose |
|---|---|
| `CA:TRUE` | This certificate is a CA. |
| `pathlen:0` | It can only issue end-entity certificates, not further CAs. |
| `keyCertSign, cRLSign` | Allowed to sign certificates and revocation lists. |
| `subjectKeyIdentifier` / `authorityKeyIdentifier` | Link the certificates together in the chain. |

Sign it with the Root CA:

```bash
openssl x509 -req -in csr/subCA11.csr \
  -CA ../rootca/certs/rootCA11.crt \
  -CAkey ../rootca/private/rootCA11.key \
  -CAcreateserial -out certs/subCA11.crt \
  -days 1825 -sha256 -extfile subca_ext.cnf
```

`-CAcreateserial` creates a `.srl` file that tracks serial numbers of issued certificates.

---

## Step 4: Website certificate (signed by Sub CA)

```bash
cd ~/pKI/web
openssl genrsa -out private/boomshakalaka.key 2048
openssl req -new -key private/boomshakalaka.key -out csr/boomshakalaka.csr
```

**Common Name must be the website name:** `www.boomshakalaka.in`

Create `server_ext.cnf`:

```ini
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=www.boomshakalaka.in
```

| Line | Purpose |
|---|---|
| `CA:FALSE` | End-entity only, cannot issue certificates. |
| `serverAuth` | Valid for a TLS web server. |
| `subjectAltName` | Modern browsers check the SAN, not just the Common Name. Mandatory. |

Sign with the Sub CA:

```bash
openssl x509 -req -in csr/boomshakalaka.csr \
  -CA ../subca/certs/subCA11.crt \
  -CAkey ../subca/private/subCA11.key \
  -CAcreateserial -out certs/boomshakalaka.crt \
  -days 365 -sha256 -extfile server_ext.cnf
```

Build the full chain (order matters: **server → sub CA → root CA**). Apache must send the intermediate certificate so clients can build the path to a trusted root.

```bash
cat certs/boomshakalaka.crt ../subca/certs/subCA11.crt \
    ../rootca/certs/rootCA11.crt > certs/fullchain.crt
```

Verify the chain (expected: `OK`):

```bash
openssl verify -CAfile ../rootca/certs/rootCA11.crt \
  -untrusted ../subca/certs/subCA11.crt certs/boomshakalaka.crt
```

---

## Step 5: DNS with BIND9

```bash
sudo apt update && sudo apt install bind9 dnsutils -y
sudo su
cd /etc/bind/
cp db.local db.boomshakalaka.local
nano db.boomshakalaka.local
```

Zone file contents:

```dns
$TTL    604800
@   IN  SOA boomshakalaka.in. root.boomshakalaka.in. (
            2          ; Serial
            604800     ; Refresh
            86400      ; Retry
            2419200    ; Expire
            604800 )   ; Negative Cache TTL
;
@    IN  NS    ns.boomshakalaka.in.
@    IN  A     192.168.142.142
ns   IN  A     192.168.142.142
www  IN  A     192.168.142.142
```

The `www` A record is required because the site is `www.boomshakalaka.in`.

Declare the zone in `named.conf.local`:

```
zone "boomshakalaka.in" {
    type master;
    file "/etc/bind/db.boomshakalaka.local";
};
```

Check, restart, test:

```bash
named-checkconf
named-checkzone boomshakalaka.in /etc/bind/db.boomshakalaka.local
systemctl restart bind9        # unit may be named "named" on Ubuntu
dig @192.168.142.142 www.boomshakalaka.in
```

The ANSWER section should show `192.168.142.142`.

---

## Step 6: Apache HTTPS

Copy the needed files to a folder Apache can read:

```bash
mkdir -p ~/certs
cp ~/pKI/rootca/certs/rootCA11.crt     ~/certs/
cp ~/pKI/web/certs/fullchain.crt       ~/certs/
cp ~/pKI/web/private/boomshakalaka.key ~/certs/
```

Create `/etc/apache2/sites-available/boomshakalaka-ssl.conf`:

```apache
<VirtualHost *:443>
    ServerName www.boomshakalaka.in
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /home/pki/certs/fullchain.crt
    SSLCertificateKeyFile /home/pki/certs/boomshakalaka.key
</VirtualHost>
```

- `ServerName` must match the certificate name (with `www`).
- `SSLCertificateFile` points to the full chain so the intermediate is sent.

Enable and test:

```bash
a2enmod ssl
a2ensite boomshakalaka-ssl
apache2ctl configtest          # Syntax OK
systemctl restart apache2
echo "<h1>Welcome to boomshakalaka.in</h1>" > /var/www/html/index.html
```

---

## Step 7: Get the Root CA to Windows

Using WinSCP (SFTP, host `192.168.142.142`, port `22`, user `pki`), download `/home/pki/certs/rootCA11.crt`.

Only the Root CA is needed on Windows, because the browser must trust the root. Never copy private keys around casually.

---

## Step 8: Trust the Root CA on Windows

1. `Win + R` → `certmgr.msc` → Enter.
2. Right-click **Trusted Root Certification Authorities → Certificates → All Tasks → Import…**
3. Select `rootCA11.crt` and choose **Place all certificates in the following store → Trusted Root Certification Authorities**.
4. Finish and confirm the warning. You should see "The import was successful."

Trust flows down: if the root is trusted, everything it (and the sub CA) signs is trusted.

---

## Step 9: Edit the Windows hosts file

Windows does not use the Ubuntu DNS by default, so map the name manually.

1. Open Notepad **as Administrator**.
2. Open `C:\Windows\System32\drivers\etc\hosts` (set the file filter to *All Files*).
3. Add at the end and save:

```
192.168.142.142    www.boomshakalaka.in
```

---

## Step 10: Test

Open Chrome or Edge and go to **https://www.boomshakalaka.in**.

Expected: 🔒 padlock and the page "Welcome to boomshakalaka.in". The certificate path should show `rootCA11 → subCA11 → www.boomshakalaka.in`.
