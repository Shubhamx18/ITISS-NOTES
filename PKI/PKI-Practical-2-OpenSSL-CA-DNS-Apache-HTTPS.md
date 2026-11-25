# PKI Practical 2: Private CA + HTTPS Website (Ubuntu server, Windows client)

**Goal:** Build a Root CA → Sub CA → Website certificate with OpenSSL, set up DNS with BIND9, serve `https://www.boomshakalaka.in` with Apache, and make a **Windows 11** machine trust it.

---

## Contents

1. [Lab setup](#lab-setup)
2. [Step 1: Folder structure](#step-1-folder-structure)
3. [Step 2: Root CA](#step-2-root-ca-self-signed)
4. [Step 3: Sub CA](#step-3-sub-ca-signed-by-root-ca)
5. [Step 4: Website certificate](#step-4-website-certificate-signed-by-sub-ca)
6. [Step 5: DNS with BIND9](#step-5-dns-with-bind9)
7. [Step 6: Apache HTTPS](#step-6-apache-https)
8. [Step 7: Copy the Root CA to Windows](#step-7-copy-the-root-ca-to-windows)
9. [Step 8: Trust the Root CA on Windows](#step-8-trust-the-root-ca-on-windows)
10. [Step 9: Point Windows at the website](#step-9-point-windows-at-the-website)
11. [Step 10: Test on Windows](#step-10-test-on-windows)
12. [Troubleshooting](#troubleshooting)
13. [Cleanup](#cleanup)
14. [Quick reference](#quick-reference)

---

## Lab setup

| Machine | OS | Role | Notes |
|---|---|---|---|
| `PG-ITISS23` | Ubuntu (VM) | CA + DNS + Web server | IP `192.168.142.142`, working as `root` |
| Windows PC | Windows 11 | Client / browser | Must reach the VM over the network |

```
rootCA11 ──signs──► subCA11 ──signs──► www.boomshakalaka.in
(10 years)          (5 years)          (1 year)
```

> **Before you start**
> - Run `ip a` on Ubuntu and confirm the VM IP. If it is not `192.168.142.142`, replace that IP everywhere below.
> - You are logged in as **root**, so `~` means `/root`, not `/home/shubham`. All paths below use `/root`.
> - Directory names are **case-sensitive**: it is `~/pKI` (capital K, capital I).
> - Run every command from the folder shown in its step. Most errors come from running a command in the wrong folder.
> - **Each certificate must have a different Common Name** (`rootCA11`, `subCA11`, `www.boomshakalaka.in`). If two certificates share the same subject, verification fails.

---

## Step 1: Folder structure

**On Ubuntu**

```bash
mkdir -p ~/pKI/{rootca,subca,web}/{certs,csr,private}
chmod 700 ~/pKI/{rootca,subca,web}/private
ls -R ~/pKI
```

| Folder | Holds |
|---|---|
| `certs/` | Issued certificates |
| `csr/` | Certificate Signing Requests |
| `private/` | Private keys (keep secret) |

> `ls` without `-R` in `/home/shubham` will not show this folder, because it lives in `/root/pKI`.

---

## Step 2: Root CA (self-signed)

**On Ubuntu**

```bash
cd ~/pKI/rootca

openssl genrsa -out private/rootCA11.key 2048

openssl req -x509 -new -nodes -key private/rootCA11.key \
  -sha256 -days 3650 -out certs/rootCA11.crt \
  -subj "/C=IN/ST=MH/L=Pune/O=CDAC/OU=ACTS/CN=rootCA11" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -addext "subjectKeyIdentifier=hash"
```

| Option | Meaning |
|---|---|
| `-x509` | Creates a certificate directly (self-signed) instead of a CSR. |
| `-nodes` | Saves the key without a passphrase (fine for a lab, not for production). |
| `-subj` | Supplies the subject, so there are no prompts to mistype. CN is `rootCA11`. |
| `-addext` | Marks it as a CA that may sign certificates. |

Verify:

```bash
openssl x509 -in certs/rootCA11.crt -noout -subject -issuer -dates
```

Subject and Issuer must both show `CN = rootCA11`.

`rootCA11.crt` is the **trust anchor**. This is the only file Windows will need.

---

## Step 3: Sub CA (signed by Root CA)

**On Ubuntu**

```bash
cd ~/pKI/subca

openssl genrsa -out private/subCA11.key 2048

openssl req -new -key private/subCA11.key -out csr/subCA11.csr \
  -subj "/C=IN/ST=MH/L=Pune/O=CDAC/OU=ACTS/CN=subCA11"
```

Create the extension file `subca_ext.cnf` (run this inside `~/pKI/subca`):

```bash
cat > subca_ext.cnf <<'EOF'
basicConstraints=critical,CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF
```

| Line | Purpose |
|---|---|
| `CA:TRUE` | This certificate is a CA. |
| `pathlen:0` | It can issue end-entity certificates only, not further CAs. |
| `keyCertSign, cRLSign` | Allowed to sign certificates and revocation lists. |
| `subjectKeyIdentifier` / `authorityKeyIdentifier` | Link the certificates together in the chain. |

Check the files exist, then sign with the Root CA:

```bash
ls csr/subCA11.csr subca_ext.cnf ../rootca/certs/rootCA11.crt ../rootca/private/rootCA11.key

openssl x509 -req -in csr/subCA11.csr \
  -CA ../rootca/certs/rootCA11.crt \
  -CAkey ../rootca/private/rootCA11.key \
  -CAcreateserial -out certs/subCA11.crt \
  -days 1825 -sha256 -extfile subca_ext.cnf
```

`-CAcreateserial` creates `rootCA11.srl` next to the root certificate (in `~/pKI/rootca/certs/`). It tracks the serial numbers of issued certificates.

Verify (expected: `certs/subCA11.crt: OK`):

```bash
openssl verify -CAfile ../rootca/certs/rootCA11.crt certs/subCA11.crt
openssl x509 -in certs/subCA11.crt -noout -subject -issuer
```

Subject must be `CN = subCA11` and Issuer must be `CN = rootCA11`.

---

## Step 4: Website certificate (signed by Sub CA)

**On Ubuntu**

```bash
cd ~/pKI/web

openssl genrsa -out private/boomshakalaka.key 2048

openssl req -new -key private/boomshakalaka.key -out csr/boomshakalaka.csr \
  -subj "/C=IN/ST=MH/L=Pune/O=CDAC/OU=ACTS/CN=www.boomshakalaka.in"
```

> **Common Name must be the website name:** `www.boomshakalaka.in`

Create the extension file `server_ext.cnf` (run this inside `~/pKI/web`):

```bash
cat > server_ext.cnf <<'EOF'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
subjectAltName=@alt_names

[alt_names]
DNS.1=www.boomshakalaka.in
EOF
```

| Line | Purpose |
|---|---|
| `CA:FALSE` | End-entity only, cannot issue certificates. |
| `serverAuth` | Valid for a TLS web server. |
| `subjectAltName` | Chrome and Edge on Windows check the SAN, not just the Common Name. **Mandatory.** |
| `authorityKeyIdentifier` | Links the website certificate to `subCA11`. |

Pre-flight check. All five files must be listed with no error:

```bash
ls csr/boomshakalaka.csr server_ext.cnf \
   ../subca/certs/subCA11.crt ../subca/private/subCA11.key
```

Sign with the Sub CA:

```bash
openssl x509 -req -in csr/boomshakalaka.csr \
  -CA ../subca/certs/subCA11.crt \
  -CAkey ../subca/private/subCA11.key \
  -CAcreateserial -out certs/boomshakalaka.crt \
  -days 365 -sha256 -extfile server_ext.cnf
```

A successful run prints `Certificate request self-signature ok` and `subject=...CN = www.boomshakalaka.in`. The serial file `subCA11.srl` is created in `~/pKI/subca/certs/`.

Build the chain file. Order matters: **server → sub CA**. Apache must send the intermediate certificate so the client can build a path to the trusted root. The root is not sent, because Windows already trusts it.

```bash
cat certs/boomshakalaka.crt ../subca/certs/subCA11.crt > certs/fullchain.crt
```

Verify the chain (expected: `certs/boomshakalaka.crt: OK`):

```bash
openssl verify -CAfile ../rootca/certs/rootCA11.crt \
  -untrusted ../subca/certs/subCA11.crt \
  -purpose sslserver -verify_hostname www.boomshakalaka.in \
  certs/boomshakalaka.crt
```

Confirm the SAN and issuer:

```bash
openssl x509 -in certs/boomshakalaka.crt -noout -subject -issuer -dates -ext subjectAltName
```

Expected: `Issuer: CN = subCA11` and `DNS:www.boomshakalaka.in`.

---

## Step 5: DNS with BIND9

**On Ubuntu**

```bash
apt update && apt install bind9 dnsutils -y
```

Create the zone file:

```bash
cat > /etc/bind/db.boomshakalaka.local <<'EOF'
$TTL    604800
@   IN  SOA ns.boomshakalaka.in. root.boomshakalaka.in. (
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
EOF
```

The `www` A record is required because the site is `www.boomshakalaka.in`.

Declare the zone (appends to `/etc/bind/named.conf.local`):

```bash
cat >> /etc/bind/named.conf.local <<'EOF'
zone "boomshakalaka.in" {
    type master;
    file "/etc/bind/db.boomshakalaka.local";
};
EOF
```

Check, restart, test:

```bash
named-checkconf
named-checkzone boomshakalaka.in /etc/bind/db.boomshakalaka.local
systemctl restart bind9        # unit may be named "named" on Ubuntu
systemctl status bind9 --no-pager
dig @192.168.142.142 www.boomshakalaka.in
```

`named-checkzone` must print `OK`, and the ANSWER section of `dig` must show `192.168.142.142`.

---

## Step 6: Apache HTTPS

**On Ubuntu**

Install Apache and copy the needed files to a system folder that Apache can always read:

```bash
apt install apache2 -y

mkdir -p /etc/ssl/boomshakalaka
cp ~/pKI/web/certs/fullchain.crt       /etc/ssl/boomshakalaka/
cp ~/pKI/web/private/boomshakalaka.key /etc/ssl/boomshakalaka/
chown root:root /etc/ssl/boomshakalaka/*
chmod 644 /etc/ssl/boomshakalaka/fullchain.crt
chmod 600 /etc/ssl/boomshakalaka/boomshakalaka.key
```

Create the virtual host file:

```bash
cat > /etc/apache2/sites-available/boomshakalaka-ssl.conf <<'EOF'
<VirtualHost *:443>
    ServerName www.boomshakalaka.in
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /etc/ssl/boomshakalaka/fullchain.crt
    SSLCertificateKeyFile /etc/ssl/boomshakalaka/boomshakalaka.key
</VirtualHost>
EOF
```

- `ServerName` must match the certificate name (with `www`).
- `SSLCertificateFile` points to the chain file (server + sub CA) so the intermediate is sent.
- The key is stored in `/etc/ssl/boomshakalaka/` with mode `600`. Apache reads it at startup as root.

Create the page, enable the site, test, and restart:

```bash
echo "<h1>Welcome to boomshakalaka.in</h1>" > /var/www/html/index.html

a2enmod ssl
a2ensite boomshakalaka-ssl
apache2ctl configtest          # Syntax OK
systemctl restart apache2
ss -tlnp | grep 443            # Apache must be listening on port 443
```

Test locally on Ubuntu before touching Windows:

```bash
openssl s_client -connect 192.168.142.142:443 -servername www.boomshakalaka.in \
  -CAfile ~/pKI/rootca/certs/rootCA11.crt </dev/null 2>/dev/null | grep -E "subject|issuer|Verify return code"
```

Expected: `Verify return code: 0 (ok)`.

If `ufw` is active, allow HTTPS and DNS so Windows can reach them:

```bash
ufw allow 443/tcp
ufw allow 53
```

---

## Step 7: Copy the Root CA to Windows

Only the **Root CA certificate** goes to Windows. Never copy private keys around casually.

### 7.1 Make the file readable by your normal user (Ubuntu)

SSH as `root` is often disabled, so stage the file for the `shubham` user:

```bash
cp ~/pKI/rootca/certs/rootCA11.crt /home/shubham/
chown shubham:shubham /home/shubham/rootCA11.crt
```

### 7.2 Download it on Windows

**Option A: PowerShell (built-in OpenSSH client)**

```powershell
scp shubham@192.168.142.142:/home/shubham/rootCA11.crt $env:USERPROFILE\Downloads\
```

**Option B: WinSCP**

1. Protocol `SFTP`, host `192.168.142.142`, port `22`, user `shubham`.
2. Download `/home/shubham/rootCA11.crt` to `Downloads`.

### 7.3 Check the file arrived

```powershell
Get-Item $env:USERPROFILE\Downloads\rootCA11.crt
certutil -dump $env:USERPROFILE\Downloads\rootCA11.crt
```

The dump should show `Subject: CN=rootCA11` and `Issuer: CN=rootCA11` (self-signed).

---

## Step 8: Trust the Root CA on Windows

Trust flows down: if the root is trusted, everything it (and the sub CA) signs is trusted.

### Option A: Certificate Manager (GUI)

1. Press `Win + R`, type `certmgr.msc`, press Enter.
2. Right-click **Trusted Root Certification Authorities → Certificates → All Tasks → Import…**
3. Click **Next**, browse to `rootCA11.crt` (set the file filter to *All Files* if it is hidden).
4. Choose **Place all certificates in the following store → Trusted Root Certification Authorities**.
5. Finish and confirm the security warning with **Yes**. You should see "The import was successful."

> `certmgr.msc` installs for the **current user** only. That is enough for Chrome and Edge.

### Option B: PowerShell (run as Administrator)

```powershell
Import-Certificate -FilePath "$env:USERPROFILE\Downloads\rootCA11.crt" `
  -CertStoreLocation Cert:\LocalMachine\Root
```

### Option C: certutil (run as Administrator)

```powershell
certutil -addstore -f "Root" "$env:USERPROFILE\Downloads\rootCA11.crt"
```

### Verify it was installed

```powershell
Get-ChildItem Cert:\LocalMachine\Root | Where-Object Subject -like "*rootCA11*"
# for the per-user store (Option A):
Get-ChildItem Cert:\CurrentUser\Root  | Where-Object Subject -like "*rootCA11*"
```

### Firefox only

Firefox uses its own certificate store and ignores Windows. Either import `rootCA11.crt` under **Settings → Privacy & Security → Certificates → View Certificates → Authorities → Import** (tick *Trust this CA to identify websites*), or set `security.enterprise_roots.enabled` to `true` in `about:config`.

---

## Step 9: Point Windows at the website

Windows does not use the Ubuntu DNS server by default, so give it the name → IP mapping.

### Option A: hosts file (simplest, recommended)

Open **PowerShell as Administrator** and run:

```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "192.168.142.142    www.boomshakalaka.in"
ipconfig /flushdns
```

Or edit manually: open Notepad **as Administrator**, open `C:\Windows\System32\drivers\etc\hosts` (file filter: *All Files*), add this line at the end, and save:

```
192.168.142.142    www.boomshakalaka.in
```

### Option B: use the BIND9 server as Windows DNS (tests the DNS setup properly)

1. `Win + R` → `ncpa.cpl` → right-click your adapter → **Properties**.
2. Select **Internet Protocol Version 4 (TCP/IPv4) → Properties**.
3. Choose **Use the following DNS server addresses** and set Preferred DNS to `192.168.142.142`.
4. Run `ipconfig /flushdns`.

> With Option B, only the `boomshakalaka.in` zone is answered by the VM. Normal internet browsing will fail unless BIND is also configured with forwarders. Revert to automatic DNS after the practical.

### Check name resolution

```powershell
nslookup www.boomshakalaka.in                      # uses Windows DNS settings
nslookup www.boomshakalaka.in 192.168.142.142      # asks the BIND9 server directly
ping www.boomshakalaka.in
```

> `nslookup` ignores the hosts file. If you used Option A, `ping` and the browser will work even when plain `nslookup` fails.

---

## Step 10: Test on Windows

### Network check

```powershell
Test-NetConnection www.boomshakalaka.in -Port 443
```

`TcpTestSucceeded : True` means the port is reachable.

### Command-line TLS check

```powershell
curl.exe -v https://www.boomshakalaka.in
```

Expected: `SSL certificate verify ok` and the HTML `<h1>Welcome to boomshakalaka.in</h1>`.

### Browser check

Open Chrome or Edge and go to **https://www.boomshakalaka.in**. Fully restart the browser first if it was already open.

Expected:

- 🔒 padlock, no warning page
- Page text: **Welcome to boomshakalaka.in**
- Click the padlock → **Connection is secure → Certificate is valid**. The **Certification Path** tab should show:

```
rootCA11
 └─ subCA11
     └─ www.boomshakalaka.in
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `ls` does not show `pKI` | Logged in as root, so folder is in `/root` | `ls -R ~/pKI` |
| `No such file or directory` during signing | Wrong current folder, or `.cnf` / `.csr` / key file missing | `cd` to the folder shown in the step and run the `ls` pre-flight check |
| `Error loading extension section` / `can't open extfile` | `.cnf` file missing or written in the wrong folder | Re-create it with the `cat > ... <<'EOF'` command inside the correct folder |
| `error 18 ... self-signed certificate` or `error 20 ... unable to get local issuer certificate` on verify | Two certificates share the same subject, or the wrong CA file was used | Use a different CN for each certificate; re-run Steps 2 to 4 |
| `NET::ERR_CERT_AUTHORITY_INVALID` | Root CA not trusted, or imported to the wrong store | Redo Step 8; confirm it is under **Trusted Root Certification Authorities** |
| `NET::ERR_CERT_COMMON_NAME_INVALID` | SAN missing or wrong | Re-check `server_ext.cnf`, re-sign, rebuild `fullchain.crt`, restart Apache |
| `ERR_NAME_NOT_RESOLVED` | No hosts entry or wrong DNS | Redo Step 9; run `ipconfig /flushdns` |
| Browser shows chain error only on some clients | Intermediate not sent | `SSLCertificateFile` must point to `fullchain.crt` |
| `ERR_CONNECTION_TIMED_OUT` / refused | Firewall or Apache not listening | `ufw allow 443/tcp`; `ss -tlnp \| grep 443` on Ubuntu |
| Apache fails to start after editing | Syntax or path error | `apache2ctl configtest`; `journalctl -xeu apache2 --no-pager \| tail` |
| Browser keeps old warning | Cached result | Close **all** browser windows and reopen |
| `curl.exe` says `CRYPT_E_NO_REVOCATION_CHECK` | Windows cannot check revocation (no CRL) | Use `curl.exe --ssl-no-revoke -v https://www.boomshakalaka.in` |
| Firefox still warns | Firefox has its own store | See "Firefox only" in Step 8 |
| `openssl verify` fails | Wrong file order or wrong CA files | Re-run the Step 4 verify with the exact paths shown |

Useful Ubuntu-side checks:

```bash
openssl x509 -in ~/pKI/web/certs/boomshakalaka.crt -noout -subject -issuer -dates -ext subjectAltName
openssl s_client -connect www.boomshakalaka.in:443 -servername www.boomshakalaka.in -showcerts </dev/null
```

> If you change anything in Steps 2 to 4 after Apache is set up, copy the new `fullchain.crt` to `/etc/ssl/boomshakalaka/` and run `systemctl restart apache2`.

---

## Cleanup

Remove the lab trust from Windows when done:

```powershell
# Administrator PowerShell: remove the root from the machine store
Get-ChildItem Cert:\LocalMachine\Root | Where-Object Subject -like "*rootCA11*" | Remove-Item

# Remove the hosts entry (edit the file as Administrator and delete the line), then:
ipconfig /flushdns
```

If you used the GUI import, delete it in `certmgr.msc` under **Trusted Root Certification Authorities → Certificates → rootCA11**.

---

## Quick reference

| File | Location (Ubuntu) | Goes to |
|---|---|---|
| `rootCA11.key` | `~/pKI/rootca/private/` | Stays private, never copied |
| `rootCA11.crt` | `~/pKI/rootca/certs/` | **Windows** (trusted root) |
| `subCA11.key` | `~/pKI/subca/private/` | Stays private, never copied |
| `subCA11.crt` | `~/pKI/subca/certs/` | Included in `fullchain.crt` |
| `boomshakalaka.key` | `~/pKI/web/private/` | Apache only (`/etc/ssl/boomshakalaka/`) |
| `fullchain.crt` | `~/pKI/web/certs/` | Apache (`SSLCertificateFile`) |
