# Digital Signature of a PDF using XCA and Adobe Acrobat

## Overview

**Goal:** Build a PKI in XCA (Root CA → Sub CA), issue a signing certificate to a user, load it into Adobe Acrobat, sign a PDF, and verify the signature.

| Item | Value |
|---|---|
| CA chain | DITISS Root CA → DITISS Sub CA |
| Signer | Alice (`alice@cdac.in`) |
| Files produced | `alice.p12`, `root.crt`, `document_signed.pdf` |

```
DITISS Root CA ──signs──► DITISS Sub CA ──signs──► Alice (user certificate)
   (10 years)                (5 years)                  (1 year)

alice.p12 ──imported into──► Adobe ──signs──► document_signed.pdf
```

**Why a user certificate?** A server certificate is meant for TLS. Adobe needs a certificate whose key usage allows **signing** (Digital Signature, Non Repudiation).

## Which OS for Which Tool

| Part | Tool | OS |
|---|---|---|
| **Part 1: Build the PKI** | XCA | **Linux** |
| **Part 2: Sign and verify the PDF** | Adobe Acrobat / Reader | **Windows** |

```
LINUX (XCA):
  1. Database ➜ 2. Root CA ➜ 3. Sub CA ➜ 4. Alice cert ➜ 5. Export

WINDOWS (Adobe):
  1. Trust root ➜ 2. Add Digital ID ➜ 3. Sign PDF ➜ 4. Verify
```

---

# PART 1: LINUX (XCA)

**Goal:** Create the Root CA, Sub CA and Alice's certificate, then export `alice.p12` and `root.crt`.

---

## Step 1: Install XCA and Create the Database

**1.1 Install and start XCA**

```bash
sudo apt install -y xca
mkdir -p ~/testxca
xca            # or start it from the application menu
```

**1.2 Create the database**

1. Go to **File > New Database**.
2. Choose the folder `~/testxca`.
3. Name it `ditiss`.
4. Leave the password empty.

**XCA tabs you will use**

| Tab | Used for |
|---|---|
| Private Keys | Keys created for the CAs and users |
| Certificates | Root CA, Sub CA and user certificates |
| Revocation lists | CRLs (not needed here) |

> Every certificate is created in the same dialog, with the tabs **Source**, **Subject**, **Extensions** and **Key usage**.

---

## Step 2: Create the Root CA

**2.1 Create the Root key**

Go to **Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `root` |
| Type | RSA |
| Size | 4096 |

Click **Create**.

**2.2 Create the self-signed Root certificate**

Go to **Certificates** tab → **New Certificate**, then fill each tab:

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

**Why these settings?**

| Setting | Reason |
|---|---|
| Self signed | The root is the trust anchor, so it signs itself. |
| Certification Authority | Marks the certificate as a CA (`CA:TRUE`). |
| Certificate Sign, CRL Sign | The root may sign certificates and revocation lists. |

---

## Step 3: Create the Sub CA

**3.1 Create the Sub CA key**

Go to **Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `sub` |
| Type | RSA |
| Size | 2048 |

Click **Create**.

**3.2 Create the Sub CA certificate signed by the Root CA**

Go to **Certificates** tab → **New Certificate**, then fill each tab:

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

**Why these settings?**

| Setting | Reason |
|---|---|
| Use this Certificate for signing | The Root CA signs the Sub CA, which builds the chain. |
| Path length 0 | The Sub CA can issue only end-entity certificates, not further CAs. |

> In the Certificates tab the Sub CA now appears under the Root CA. The tree is the chain.

---

## Step 4: Create the Signing Certificate for Alice

**4.1 Create a key for Alice**

Go to **Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `alice` |
| Type | RSA |
| Size | 2048 |

Click **Create**. This key creates the signature, so it must stay private.

**4.2 Create the user certificate signed by the Sub CA**

Go to **Certificates** tab → **New Certificate**, then fill each tab:

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

**Why these settings?**

| Setting | Reason |
|---|---|
| Digital Signature | Allows the key to create signatures. Adobe checks this. |
| Non Repudiation | The signer cannot later deny signing. |
| End Entity | Alice is not a CA and cannot issue certificates. |
| E-mail Protection | Extended usage that Adobe accepts for signing. |

> **Tip:** Apply the template *before* typing the subject alternative name, because re-applying a template can overwrite it.

---

## Step 5: Export Files from XCA

**5.1 Export Alice's Digital ID**

Go to **Certificates** tab → select **Alice** → **Export**

| Field | Value |
|---|---|
| Format | PKCS #12 with Certificate chain |
| File name | `alice.p12` |
| Password | Set one (required in Adobe) |

A `.p12` file holds the private key, the certificate and the chain, protected by a password. Adobe needs the private key to sign.

**5.2 Export the Root CA certificate**

Go to **Certificates** tab → select **DITISS Root CA** → **Export**

| Field | Value |
|---|---|
| Format | PEM (`.crt`) |
| File name | `root.crt` |

This file has only the public certificate. It is used to make Adobe trust your CA.

**Linux part is done.** You now have `alice.p12` and `root.crt`.

---

# PART 2: WINDOWS (Adobe Acrobat)

**Goal:** Trust the Root CA, add Alice's Digital ID, sign the PDF and verify it.

**Files needed:** `alice.p12` and `root.crt`.

---

## Step 1: Trust the Root CA in Adobe

Do this **before** signing. Otherwise Adobe shows a yellow warning: *signer's identity is unknown*.

1. Open Adobe Acrobat.
2. Go to **Edit > Preferences > Signatures**.
3. Under **Identities & Trusted Certificates**, click **More…**
4. In the left pane, select **Trusted Certificates** → **Import**.
5. Click **Browse** → select `root.crt` → **Open**.
6. Select **DITISS Root CA** in the list → **Import**.
7. Back in the list, select **DITISS Root CA** → **Edit Trust**.
8. Tick **Use this certificate as a trusted root** → **OK**.

> Trust flows down: if the root is trusted, the Sub CA and Alice's certificate are trusted too.

---

## Step 2: Add Alice's Digital ID in Adobe

1. Go to **Edit > Preferences > Signatures > Identities & Trusted Certificates > More…**
2. In the left pane, select **Digital IDs** → click **Add ID** (the `+` icon).
3. Select **My existing digital ID from: A file** → **Next**.
4. Click **Browse** → select `alice.p12`.
5. Enter the `.p12` password → **Next**.
6. Click **Done**. Alice now appears under Digital IDs.

---

## Step 3: Sign the PDF

1. Open the PDF.
2. Go to **Tools > Use a Certificate** (Reader: **All tools > Use a certificate**).
3. Click **Digitally Sign**.
4. Click **OK** on the message, then **drag a rectangle** where the signature should appear.
5. In **Sign with a Digital ID**, choose **Alice** → **Continue**.
6. Check the preview → **Sign**.
7. Save as `document_signed.pdf` and enter the `.p12` password if asked.

**How it works:** Adobe takes a **hash** of the PDF, encrypts the hash with **Alice's private key**, and embeds the result with Alice's certificate.

---

## Step 4: Verify the Signature

**4.1 Check validity**

1. Open `document_signed.pdf`. The top bar should say **"Signed and all signatures are valid"** with a green tick.
2. Open the **Signature panel** → right-click the signature → **Show Signature Properties**.
3. Click **Show Signer's Certificate** and check the path:

```
DITISS Root CA
  └─ DITISS Sub CA
       └─ Alice
```

**What the result means**

| Result in Adobe | Meaning |
|---|---|
| Green tick | Document unchanged, and the certificate chains to a trusted root. |
| Yellow warning, identity unknown | Root CA not trusted. Repeat Windows Step 1. |
| Red cross, document modified | File changed after signing, so the hash no longer matches. |

**4.2 Tamper test**

Edit the signed PDF (add text or a page) and reopen it. The signature becomes **invalid**.

| Property | Shown by |
|---|---|
| Integrity | The hash changes when the document changes. |
| Authentication | The certificate chain leads to a trusted CA. |
| Non-repudiation | Only Alice's private key could create the signature. |

---

## Final Checklist

**Linux (XCA)**
- [ ] Database `ditiss` created
- [ ] Root CA created (4096-bit, 10 years)
- [ ] Sub CA created (2048-bit, 5 years, path length 0)
- [ ] Alice certificate created (Digital Signature + Non Repudiation)
- [ ] `alice.p12` and `root.crt` exported

**Windows (Adobe)**
- [ ] Root CA imported and marked as trusted
- [ ] `alice.p12` added as a Digital ID
- [ ] PDF signed and saved as `document_signed.pdf`
- [ ] Signature shows green tick, chain is Root → Sub → Alice
- [ ] Tamper test shows invalid signature
