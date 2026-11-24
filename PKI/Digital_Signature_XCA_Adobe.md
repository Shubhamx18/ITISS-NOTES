# Digital Signature of a PDF using XCA and Adobe Acrobat

## 1. Overview

**Goal:** Issue a signing certificate from your own CA in XCA, load it into Adobe Acrobat, sign a PDF, and verify the signature.

| Item | Value |
|---|---|
| Tool 1 | XCA (certificate and key management) |
| Tool 2 | Adobe Acrobat / Acrobat Reader |
| CA chain | DITISS Root CA → DITISS Sub CA (already created in XCA) |
| Signer | Alice (`alice@cdac.in`) |
| Files produced | `alice.p12`, `root.crt`, `document_signed.pdf` |

```
DITISS Root CA ──signs──► DITISS Sub CA ──signs──► Alice (user certificate)

alice.p12 ──imported into──► Adobe ──signs──► document_signed.pdf
```

**Why a user certificate?** The server certificate is meant for TLS. Adobe needs a certificate whose key usage allows **signing** (Digital Signature, Non Repudiation).

**Prerequisite:** Root CA and Sub CA exist in the XCA database `ditiss` (XCA steps 1 and 2 of the PKI lab).

---

## 2. Workflow

| Part | Task | Tool |
|---|---|---|
| A | Create the signing certificate | XCA |
| B | Export `alice.p12` and `root.crt` | XCA |
| C | Trust the Root CA | Adobe |
| D | Add the Digital ID | Adobe |
| E | Sign the PDF | Adobe |
| F | Verify the signature | Adobe |

---

## 3. Part A: Create the Signing Certificate (XCA)

### Step 1: Open the database

`xca` → **File > Open Database** → `~/testxca/ditiss`

### Step 2: Create a key for Alice

**Private Keys** tab → **New Key**

| Field | Value |
|---|---|
| Name | `alice` |
| Type | RSA |
| Size | 2048 |

Click **Create**. This key creates the signature, so it must stay private.

### Step 3: Create the certificate

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

In the Certificates tab, Alice now appears under DITISS Sub CA, which sits under DITISS Root CA. The tree is the chain.

---

## 4. Part B: Export from XCA

### Step 4: Export Alice's Digital ID

**Certificates** tab → select **Alice** → **Export**

| Field | Value |
|---|---|
| Format | PKCS #12 with Certificate chain |
| File name | `alice.p12` |
| Password | Set one (required in Adobe) |

A `.p12` file holds the private key, the certificate and the chain, protected by a password. Adobe needs the private key to sign.

### Step 5: Export the Root CA certificate

**Certificates** tab → select **DITISS Root CA** → **Export**

| Field | Value |
|---|---|
| Format | PEM (`.crt`) |
| File name | `root.crt` |

This file has only the public certificate. It is used to make Adobe trust your CA.

### Step 6: Copy to the Adobe machine

Copy `alice.p12` and `root.crt` to the machine with Adobe (WinSCP or shared folder), if it is not the same machine.

---

## 5. Part C: Trust the Root CA in Adobe

Do this before signing. Otherwise Adobe shows a yellow warning: *signer's identity is unknown*.

### Step 7: Import the Root CA and mark it trusted

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

## 6. Part D: Add the Digital ID in Adobe

### Step 8: Import `alice.p12`

1. **Edit > Preferences > Signatures > Identities & Trusted Certificates > More…**
2. Left pane: **Digital IDs** → click **Add ID** (the `+` icon).
3. Select **My existing digital ID from: A file** → **Next**.
4. **Browse** → select `alice.p12`.
5. Enter the `.p12` password → **Next**.
6. Click **Done**. Alice now appears under Digital IDs.

---

## 7. Part E: Sign the PDF

### Step 9: Sign the document

1. Open the PDF.
2. **Tools > Use a Certificate** (Reader: **All tools > Use a certificate**).
3. Click **Digitally Sign**.
4. Click **OK** on the message, then **drag a rectangle** where the signature should appear.
5. In **Sign with a Digital ID**, choose **Alice** → **Continue**.
6. Check the preview → **Sign**.
7. Save as `document_signed.pdf` and enter the `.p12` password if asked.

How it works: Adobe takes a **hash** of the PDF, encrypts the hash with **Alice's private key**, and embeds the result with Alice's certificate.

---

## 8. Part F: Verify the Signature

### Step 10: Check validity

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
| Yellow warning, identity unknown | Root CA not trusted. Repeat Step 7. |
| Red cross, document modified | File changed after signing, so the hash no longer matches. |

### Step 11: Tamper test

Edit the signed PDF (add text or a page) and reopen it. The signature becomes **invalid**.

| Property | Shown by |
|---|---|
| Integrity | The hash changes when the document changes. |
| Authentication | The certificate chain leads to a trusted CA. |
| Non-repudiation | Only Alice's private key could create the signature. |
