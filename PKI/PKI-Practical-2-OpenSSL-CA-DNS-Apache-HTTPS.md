# PKI Practical 2: Private CA with OpenSSL + HTTPS Website (BIND9 + Apache)

> **Subject:** Public Key Infrastructure
> **Goal:** Build a Root CA → Sub CA → Website certificate using **OpenSSL**, set up **DNS (BIND9)** for `www.boomshakalaka.in`, serve it over **HTTPS with Apache**, and make a Windows machine trust it.

---

## 1. Lab Layout

| Machine | Role | Details |
|---------|------|---------|
| **Ubuntu VM** | CA + DNS + Web server | IP `192.168.142.142`, user `pki` |
| **Windows 11 host** | Client / browser | Imports the CA and browses the site |

```
rootCA11  ──signs──►  subCA11  ──signs──►  www.boomshakalaka.in
(10 years)            (5 years)            (1 year)
```

**Final result:** the browser opens `https://www.boomshakalaka.in` with a 🔒 padlock.

---

## 2. Step 1: Create the Folder Structure

```bash
mkdir ~/pKI && cd ~/pKI
mkdir rootca subca web

# one set of folders per entity
for d in rootca subca web; do mkdir -p $d/certs $d/csr $d/private; done
```

| Folder | Holds |
|--------|-------|
| `certs/` | Issued certificates |
| `csr/` | Certificate Signing Requests |
| `private/` | Private keys (keep secret) |

---

## 3. Step 2: Root CA (self-signed)

```bash
cd ~/pKI/rootca

# 1. Private key
openssl genrsa -out private/rootCA11.key 2048

# 2. Self-signed certificate (valid 10 years)
openssl req -x509 -new -nodes \
  -key private/rootCA11.key \
  -sha256 -days 3650 \
  -out certs/rootCA11.crt
```

When prompted, enter:

| Prompt | Value |
|--------|-------|
| Country | `IN` |
| State | `MH` |
| Locality | `Pune` |
| Organization | `CDAC` |
| Org Unit | `ACTS` |
| Common Name | `rootCA11` |
| Email | your email |

> `-x509` makes a certificate directly (self-signed) instead of a CSR. `-nodes` means the key is saved without a passphrase (fine for a lab, **not** for production).

✅ `certs/rootCA11.crt` is your trust anchor.

---

## 4. Step 3: Sub CA (signed by Root CA)

### 3a. Key and CSR

```bash
cd ~/pKI/subca

openssl genrsa -out private/subCA11.key 2048

openssl req -new \
  -key private/subCA11.key \
  -out csr/subCA11.csr
```

Common Name = `subCA11` (rest same as above). The "challenge password" and "company name" extras can be left blank.

### 3b. Extension file for a CA

```bash
nano subca_ext.cnf
```

Paste:

```ini
basicConstraints=critical,CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
```

| Line | What it does |
|------|--------------|
| `CA:TRUE` | This certificate is a CA. |
| `pathlen:0` | It can only issue end-entity certs, not further CAs. |
| `keyCertSign, cRLSign` | Allowed to sign certificates and revocation lists. |
| `subjectKeyIdentifier` / `authorityKeyIdentifier` | Link the certificates together in the chain. |

Save with `Ctrl+O`, `Enter`, then exit with `Ctrl+X`.

### 3c. Sign the Sub CA with the Root CA

```bash
openssl x509 -req \
  -in csr/subCA11.csr \
  -CA ../rootca/certs/rootCA11.crt \
  -CAkey ../rootca/private/rootCA11.key \
  -CAcreateserial \
  -out certs/subCA11.crt \
  -days 1825 -sha256 \
  -extfile subca_ext.cnf
```

Expected output: `Certificate request self-signature ok` followed by `subject=...CN = subCA11...`

✅ `certs/subCA11.crt` is created (valid 5 years).

---

## 5. Step 4: Website Certificate (signed by Sub CA)

### 4a. Key and CSR

```bash
cd ~/pKI/web

openssl genrsa -out private/boomshakalaka.key 2048

openssl req -new \
  -key private/boomshakalaka.key \
  -out csr/boomshakalaka.csr
```

> ⚠️ **Common Name must be the website name:** `www.boomshakalaka.in`

### 4b. SSL extension file

```bash
nano server_ext.cnf
```

Paste:

```ini
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,nonRepudiation,keyEncipherment,keyAgreement
extendedKeyUsage=serverAuth,clientAuth,emailProtection
subjectAltName=@alt_names

[alt_names]
DNS.1=www.boomshakalaka.in
```

| Line | What it does |
|------|--------------|
| `CA:FALSE` | End-entity only, can't issue certificates. |
| `serverAuth` | Valid for a TLS web server. |
| `subjectAltName` | Modern browsers check the **SAN**, not just the Common Name. This is mandatory. |

### 4c. Sign with the Sub CA

```bash
openssl x509 -req \
  -in csr/boomshakalaka.csr \
  -CA ../subca/certs/subCA11.crt \
  -CAkey ../subca/private/subCA11.key \
  -CAcreateserial \
  -out certs/boomshakalaka.crt \
  -days 365 -sha256 \
  -extfile server_ext.cnf
```

> Keep the output filename **consistent** (`boomshakalaka.crt`). The original notes mixed `boomshkalaka` and `boomshakalaka`, which causes "file not found" errors.

### 4d. Build the full chain file

Order matters: **server → sub CA → root CA**.

```bash
cat certs/boomshakalaka.crt \
    ../subca/certs/subCA11.crt \
    ../rootca/certs/rootCA11.crt > certs/fullchain.crt

ls certs/
```

You should see `boomshakalaka.crt` and `fullchain.crt`.

### 4e. Verify the chain (recommended)

```bash
openssl verify \
  -CAfile ../rootca/certs/rootCA11.crt \
  -untrusted ../subca/certs/subCA11.crt \
  certs/boomshakalaka.crt
```

Expected: `certs/boomshakalaka.crt: OK`

---

## 6. Step 5: Configure DNS with BIND9

> Skip the install if BIND9 is already installed.

### 5a. Install

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt install bind9 dnsutils -y
sudo su          # work as root for /etc/bind
cd /etc/bind/
```

### 5b. Create the zone file

```bash
cp db.local db.boomshakalaka.local
nano db.boomshakalaka.local
```

Contents:

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
@    IN  AAAA  ::1
ns   IN  A     192.168.142.142
www  IN  A     192.168.142.142
```

> Added a `www` record. The original only had `@` and `ns`, but the site is `www.boomshakalaka.in`, so `www` needs an A record too.

### 5c. Declare the zone

```bash
nano named.conf.local
```

Add:

```
zone "boomshakalaka.in" {
    type master;
    file "/etc/bind/db.boomshakalaka.local";
};
```

### 5d. Forwarders

```bash
nano named.conf.options
```

Inside `options { ... }` set:

```
forwarders {
    192.168.142.142;
};
```

### 5e. Check and restart

```bash
named-checkconf
named-checkzone boomshakalaka.in /etc/bind/db.boomshakalaka.local
systemctl restart bind9.service      # on Ubuntu the unit may be "named"
```

### 5f. Test

```bash
dig @192.168.142.142 www.boomshakalaka.in
```

You should get `192.168.142.142` in the ANSWER section.

---

## 7. Step 6: Configure Apache HTTPS

### 6a. Copy files to a certs folder

```bash
cd ~
mkdir -p certs && rm -rf certs/*        # clear old content first

cp pKI/rootca/certs/rootCA11.crt        certs/
cp pKI/web/certs/fullchain.crt          certs/
cp pKI/web/private/boomshakalaka.key    certs/

ls certs/
# boomshakalaka.key  fullchain.crt  rootCA11.crt
```

### 6b. Create the virtual host

```bash
sudo su
cd /etc/apache2/sites-available/
nano boomshakalaka-ssl.conf
```

Contents:

```apache
<VirtualHost *:443>
    ServerName www.boomshakalaka.in
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /home/pki/certs/fullchain.crt
    SSLCertificateKeyFile /home/pki/certs/boomshakalaka.key
    SSLCACertificateFile  /home/pki/certs/rootCA11.crt
</VirtualHost>
```

> Use `ServerName www.boomshakalaka.in` (with `www`) so it matches the certificate's name.

### 6c. Enable and restart

```bash
a2enmod ssl
a2ensite boomshakalaka-ssl
apache2ctl configtest         # should say: Syntax OK
systemctl reload apache2
systemctl restart apache2
```

### 6d. Add a test page

```bash
echo "<h1>Welcome to boomshakalaka.in</h1>" > /var/www/html/index.html
```

---

## 8. Step 7: Move Certificates to Windows (WinSCP)

1. Open **WinSCP** → New Site:
   - File protocol: **SFTP**
   - Host name: `192.168.142.142`
   - Port: `22`
   - User name: `pki` and your password
2. Click **Login**.
3. In the right pane open `/home/pki/certs/`.
4. Drag and drop `rootCA11.crt`, `fullchain.crt` and `boomshakalaka.key` into a Windows folder.

> You only strictly need `rootCA11.crt` on Windows, because the browser has to trust the **Root CA**. Never copy private keys around casually in real life.

---

## 9. Step 8: Trust the CA on Windows

1. Press `Win + R`, type `certmgr.msc`, press **Enter**.
2. Expand **Trusted Root Certification Authorities**.
3. Right-click **Certificates → All Tasks → Import…**.
4. In the wizard, browse to `rootCA11.crt`. Choose **Place all certificates in the following store → Trusted Root Certification Authorities**.
5. Click **Next → Finish**, then confirm the security warning.
6. You should see: **"The import was successful."**

(Optional) Also import `subCA11.crt` into **Intermediate Certification Authorities**.

> If the notes say "Import personal certificate", that only applies to client or email certificates. For a **website**, trusting the Root CA is what matters.

---

## 10. Step 9: Edit the Windows hosts File

Needed because Windows doesn't use your Ubuntu DNS unless you point it there.

1. Open **Notepad as Administrator** (right-click → *Run as administrator*).
2. **File → Open** → go to `C:\Windows\System32\drivers\etc\`.
3. Change the file filter from *Text Documents* to **All Files**, then open **hosts**.
4. Add this line at the end:

```
192.168.142.142    www.boomshakalaka.in
```

5. Save and close.

> Alternative: set the Windows adapter's DNS server to `192.168.142.142` to use the BIND9 server instead.

---

## 11. Step 10: Test in the Browser

1. Open Chrome or Edge (a private window is fine).
2. Go to **https://www.boomshakalaka.in**
3. Expected: **🔒 padlock** and the page *"Welcome to boomshakalaka.in"*.
4. Click the padlock → **Certificate** → **Certification Path**. It should show:

```
rootCA11
  └─ subCA11
       └─ www.boomshakalaka.in
```

---

## 12. Troubleshooting

| Problem | Likely cause and fix |
|---------|---------------------|
| `NET::ERR_CERT_AUTHORITY_INVALID` | Root CA not imported into the *Trusted Root* store. Re-import and restart the browser. |
| `NET::ERR_CERT_COMMON_NAME_INVALID` | Missing or wrong `subjectAltName`. Recreate the certificate with the correct SAN. |
| Site not reachable | Check the `hosts` entry, `ping 192.168.142.142`, and that Apache is running. |
| Apache won't start | Run `apache2ctl configtest`. Usually a wrong file path or key mismatch. |
| Key and certificate mismatch | Compare the two hashes below; they must be identical. |
| `named` fails | Run `named-checkconf` and `named-checkzone`. Usually a missing `;` or `.` in the zone file. |
| Port 443 blocked | `sudo ufw allow 443/tcp` |

Key/cert match check:

```bash
openssl x509 -noout -modulus -in boomshakalaka.crt | openssl md5
openssl rsa  -noout -modulus -in boomshakalaka.key | openssl md5
```

---

## 13. Command Cheat Sheet

| Task | Command |
|------|---------|
| Generate RSA key | `openssl genrsa -out key.key 2048` |
| Self-signed certificate | `openssl req -x509 -new -nodes -key k.key -sha256 -days 3650 -out c.crt` |
| Create CSR | `openssl req -new -key k.key -out r.csr` |
| Sign a CSR | `openssl x509 -req -in r.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out c.crt -days N -sha256 -extfile ext.cnf` |
| View a certificate | `openssl x509 -in c.crt -text -noout` |
| Verify chain | `openssl verify -CAfile root.crt -untrusted sub.crt leaf.crt` |

---

## 14. Viva / Exam Points

- **CSR vs certificate:** A CSR is a *request* (public key + identity). A certificate is the CSR *signed by a CA*.
- **Why the full chain file?** The server must send the intermediate certificate so clients can build the path up to a trusted root.
- **Why trust the root only?** Trust flows down. If the root is trusted, everything it (and its sub CA) signs is trusted.
- **`pathlen:0` meaning:** the Sub CA can't create further sub CAs.
- **Why SAN?** Browsers have deprecated matching on Common Name alone.
- **`-CAcreateserial`:** creates a `.srl` file that tracks serial numbers of issued certificates.
- **Self-signed vs CA-signed:** A self-signed certificate is trusted only if manually installed, which is why we import the Root CA.
