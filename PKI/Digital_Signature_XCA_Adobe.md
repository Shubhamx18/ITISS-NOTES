# Digital Signature of a PDF using XCA and Adobe Acrobat

## 1. Overview

**Goal:** Build a PKI in XCA (Root CA → Sub CA), issue a signing certificate to a user, load it into Adobe Acrobat, sign a PDF, and verify the signature.

| Item | Value |
|---|---|
| Tool 1 | XCA (certificate and key management) |
| Tool 2 | Adobe Acrobat / Acrobat Reader |
| CA chain | DITISS Root CA → DITISS Sub CA |
| Signer | Alice (`alice@cdac.in`) |
| Files produced | `alice.p12`, `root.crt`, `document_signed.pdf` |

```
DITISS Root CA ──signs──► DITISS Sub CA ──signs──► Alice (user certificate)
   (10 years)                (5 years)                  (1 year)

alice.p12 ──imported into──► Adobe ──signs──► document_signed.pdf
```

**Why a user certificate?** The server certificate is meant for TLS. Adobe needs a certificate whose key usage allows **signing** (Digital Signature, Non Repudiation).

---

## 2. Workflow

| Stage | Parts | Tasks | Tool |
|---|---|---|---|
| 1. Build the PKI | A to E | Database → Root CA → Sub CA → Alice certificate → Export | XCA |
| 2. Sign the PDF | F to I | Trust root → Add Digital ID → Sign → Verify | Adobe |

```
XCA:    Database ➜ Root CA ➜ Sub CA ➜ Alice cert ➜ Export (alice.p12, root.crt)
Adobe:  Trust root ➜ Add Digital ID ➜ Sign PDF ➜ Verify
```

---

## 3. Part A: Install XCA and Create the Database

### Step 1: Install and start XCA

```bash
sudo apt install -y xca
mkdir -p ~/testxca
xca            # or start it from the application menu
```

### Step 2: Create the database

**File > New Database** → choose `~/testxca` → name it `ditiss` → leave the password empty.

| Tab | Used for |
|---|---|
| Private Keys | Keys created for the CAs and users |
| Certificates | Root CA, Sub CA and user certificates |
| Revocation lists | CRLs (not needed here) |

Every certificate is created in the same dialog, with the tabs **Source**, **Subject**, **Extensions** and **Key usage**.

---

## 4. Part B: Create the Root CA

### Step 3: Create the Root key

**Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `root` |
| Type | RSA |
| Size | 4096 |

Click **Create**.

### Step 4: Create the self-signed Root certificate

**Certificates** tab → **New Certificate**, then fill each tab:

**Source tab**

| Field | Value |
|---|---|
| Signing | **Create a self signed certificate** |
| Signature algorithm | SHA 256 |
| Template | `[default] CA` → click **Apply extensions** |

**Subject tab**

| Field | Value |
|---|---|
| Country | `IN` |
| Organisation | `CDAC` |
| Common Name | `DITISS Root CA` |
| Private key | `root` |

**Extensions tab**

| Field | Value |
|---|---|
| Type | Certification Authority |
| Time range | 10 years → click **Apply** |

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Certificate Sign, CRL Sign |

Click **OK**.

| Setting | Why it is needed |
|---|---|
| Self signed | The root is the trust anchor, so it signs itself. |
| Certification Authority | Marks the certificate as a CA (`CA:TRUE`). |
| Certificate Sign, CRL Sign | The root may sign certificates and revocation lists. |

---

## 5. Part C: Create the Sub CA

### Step 5: Create the Sub CA key

**Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `sub` |
| Type | RSA |
| Size | 2048 |

Click **Create**.

### Step 6: Create the Sub CA certificate signed by the Root CA

**Certificates** tab → **New Certificate**, then fill each tab:

**Source tab**

| Field | Value |
|---|---|
| Signing | Use this Certificate for signing: **DITISS Root CA** |
| Signature algorithm | SHA 256 |
| Template | `[default] CA` → click **Apply extensions** |

**Subject tab**

| Field | Value |
|---|---|
| Country | `IN` |
| Organisation | `CDAC` |
| Common Name | `DITISS Sub CA` |
| Private key | `sub` |

**Extensions tab**

| Field | Value |
|---|---|
| Type | Certification Authority |
| Path length | 0 |
| Time range | 5 years → click **Apply** |

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Certificate Sign, CRL Sign |

Click **OK**.

| Setting | Why it is needed |
|---|---|
| Use this Certificate for signing | The Root CA signs the Sub CA, which builds the chain. |
| Path length 0 | The Sub CA can issue only end-entity certificates, not further CAs. |

In the Certificates tab the Sub CA now appears under the Root CA. The tree is the chain.

---

## 6. Part D: Create the Signing Certificate

### Step 7: Create a key for Alice

**Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `alice` |
| Type | RSA |
| Size | 2048 |

Click **Create**. This key creates the signature, so it must stay private.

### Step 8: Create the user certificate signed by the Sub CA

**Certificates** tab → **New Certificate**, then fill each tab:

**Source tab**

| Field | Value |
|---|---|
| Signing | Use this Certificate for signing: **DITISS Sub CA** |
| Signature algorithm | SHA 256 |
| Template | `[default] TLS_client` → click **Apply extensions** |

**Subject tab**

| Field | Value |
|---|---|
| Country | `IN` |
| Organisation | `CDAC` |
| Common Name | `Alice` |
| Email address | `alice@cdac.in` |
| Private key | `alice` |

**Extensions tab**

| Field | Value |
|---|---|
| Type | End Entity |
| Time range | 1 year → click **Apply** |
| Subject alternative name | `email:alice@cdac.in` |

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Digital Signature, Non Repudiation |
| Extended key usage | E-mail Protection (and Document Signing, if listed) |
| Untick | TLS Web Server Authentication |

Click **OK**.

| Setting | Why it is needed |
|---|---|
| Digital Signature | Allows the key to create signatures. Adobe checks this. |
| Non Repudiation | The signer cannot later deny signing. |
| End Entity | Alice is not a CA and cannot issue certificates. |
| E-mail Protection | Extended usage that Adobe accepts for signing. |

Apply the template before typing the subject alternative name, because re-applying a template can overwrite it.

---

## 7. Part E: Export from XCA

### Step 9: Export Alice's Digital ID

**Certificates** tab → select **Alice** → **Export**

| Field | Value |
|---|---|
| Format | PKCS #12 with Certificate chain |
| File name | `alice.p12` |
| Password | Set one (required in Adobe) |

A `.p12` file holds the private key, the certificate and the chain, protected by a password. Adobe needs the private key to sign.

### Step 10: Export the Root CA certificate

**Certificates** tab → select **DITISS Root CA** → **Export**

| Field | Value |
|---|---|
| Format | PEM (`.crt`) |
| File name | `root.crt` |

This file has only the public certificate. It is used to make Adobe trust your CA.

### Step 11: Copy to the Adobe machine

Copy `alice.p12` and `root.crt` to the machine with Adobe (WinSCP or shared folder), if it is not the same machine.

---

## 8. Part F: Trust the Root CA in Adobe

Do this before signing. Otherwise Adobe shows a yellow warning: *signer's identity is unknown*.

### Step 12: Import the Root CA and mark it trusted

1. Open Adobe Acrobat.
2. **Edit > Preferences > Signatures**.
3. Under **Identities & Trusted Certificates**, click **More…**
4. Left pane: **Trusted Certificates** → **Import**.
5. **Browse** → select `root.crt` → **Open**.
6. Select **DITISS Root CA** in the list → **Import**.
7. Back in the list, select **DITISS Root CA** → **Edit Trust**.
8. Tick **Use this certificate as a trusted root** → **OK**.

Trust flows down: if the root is trusted, the Sub CA and Alice's certificate are trusted too.

---

## 9. Part G: Add the Digital ID in Adobe

### Step 13: Import `alice.p12`

1. **Edit > Preferences > Signatures > Identities & Trusted Certificates > More…**
2. Left pane: **Digital IDs** → click **Add ID** (the `+` icon).
3. Select **My existing digital ID from: A file** → **Next**.
4. **Browse** → select `alice.p12`.
5. Enter the `.p12` password → **Next**.
6. Click **Done**. Alice now appears under Digital IDs.

---

## 10. Part H: Sign the PDF

### Step 14: Sign the document

1. Open the PDF.
2. **Tools > Use a Certificate** (Reader: **All tools > Use a certificate**).
3. Click **Digitally Sign**.
4. Click **OK** on the message, then **drag a rectangle** where the signature should appear.
5. In **Sign with a Digital ID**, choose **Alice** → **Continue**.
6. Check the preview → **Sign**.
7. Save as `document_signed.pdf` and enter the `.p12` password if asked.

How it works: Adobe takes a **hash** of the PDF, encrypts the hash with **Alice's private key**, and embeds the result with Alice's certificate.

---

## 11. Part I: Verify the Signature

### Step 15: Check validity

1. Open `document_signed.pdf`. The top bar should say **"Signed and all signatures are valid"** with a green tick.
2. Open the **Signature panel** → right-click the signature → **Show Signature Properties**.
3. Click **Show Signer's Certificate** and check the path:

```
DITISS Root CA
  └─ DITISS Sub CA
       └─ Alice
```

| Result in Adobe | Meaning |
|---|---|
| Green tick | Document unchanged, and the certificate chains to a trusted root. |
| Yellow warning, identity unknown | Root CA not trusted. Repeat Step 12. |
| Red cross, document modified | File changed after signing, so the hash no longer matches. |

### Step 16: Tamper test

Edit the signed PDF (add text or a page) and reopen it. The signature becomes **invalid**.

| Property | Shown by |
|---|---|
| Integrity | The hash changes when the document changes. |
| Authentication | The certificate chain leads to a trusted CA. |
| Non-repudiation | Only Alice's private key could create the signature. |
