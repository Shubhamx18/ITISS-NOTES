# PKI Practical 1: Digitally Sign and Encrypt Email (XCA + Thunderbird)

> **Subject:** Public Key Infrastructure | **Sessions:** 14 & 15
> **Goal:** Build a 3-level PKI (Root CA → Sub CA → Email certificate) in **XCA**, then use that certificate in **Thunderbird** to digitally sign and encrypt email with **S/MIME**.

---

## 1. Concept in 60 seconds

```
 root-ca  (self-signed, trust anchor)
    │ signs
    ▼
 sub-ca   (intermediate CA)
    │ signs
    ▼
 EMAIL-CERT  (end-entity, used by Thunderbird)
```

| Term | Meaning |
|------|---------|
| **Root CA** | Top of the trust chain. Signs itself (self-signed). |
| **Sub CA** | Intermediate CA signed by Root. Keeps the Root key safe and offline in real life. |
| **End Entity** | The final certificate (a person, a server). It cannot sign other certificates. |
| **S/MIME** | Standard for signing and encrypting email using X.509 certificates. |
| **Signing** | Uses your **private key**. Proves the mail is from you and unchanged. |
| **Encryption** | Uses the **recipient's public key**. Only the recipient's private key can open it. |
| **PKCS#12 (.pfx)** | One file holding your certificate, the whole chain and your private key, password protected. |

---

## 2. Requirements

- **XCA** (X Certificate and Key management) installed
- **Thunderbird** with a working email account (Gmail, etc.)
- Your own email address (used in the certificate)

---

## 3. Step 1: Create the Root CA

1. Open **XCA** → **File → New Database** (give it a name and password).
2. Go to the **Certificates** tab → click **New Certificate**.
3. **Source** tab:
   - Signing: select **Create a self signed certificate**
   - Signature algorithm: **SHA256**
   - Template: **[default] CA**
   - Click **Apply all**
4. **Subject** tab:

   | Field | Value |
   |-------|-------|
   | Internal name | `root-ca` |
   | countryName | `IN` |
   | stateOrProvinceName | `MH` |
   | localityName | `PUNE` |
   | organizationName | `CDAC` |
   | organizationalUnitName | `ACTS` |
   | commonName | `root-ca` |

   Click **Generate a new key** → name `root-ca`, type **RSA**, size **2048 bit** → **Create**.
5. **Extensions** tab: Type = **Certification Authority**, Time range = **10 Years** → click **Apply**.
6. Click **OK**.

✅ Root CA created.

---

## 4. Step 2: Create the Sub CA

Same wizard, but with a few changes.

1. **Certificates** tab → **New Certificate**.
2. **Source** tab:
   - Signing: select **Use this Certificate for signing** → choose **root-ca**
   - Template: **[default] CA** → **Apply all**
3. **Subject** tab: fill the details (Internal name and commonName = `sub-ca`, same C/ST/L/O/OU as above) → **Generate a new key** (RSA 2048).
4. **Extensions** tab: Type = **Certification Authority**, Time range = **5 Years** → **Apply**.
5. Click **OK**.

✅ Sub CA created and signed by root-ca.

> The Sub CA must be shorter-lived than the Root CA, because a child cannot outlive its issuer.

---

## 5. Step 3: Create the Email Protection (S/MIME) Certificate

1. **Certificates** tab → **New Certificate**.
2. **Source** tab:
   - Signing: **Use this Certificate for signing** → choose **sub-ca**
   - Template: **[default] Empty template** → **Apply all**
3. **Subject** tab:

   | Field | Value |
   |-------|-------|
   | Internal name | `EMAIL-CERT` |
   | countryName | `IN` |
   | stateOrProvinceName | `MH` |
   | localityName | `PUNE` |
   | organizationName | `CDAC` |
   | organizationalUnitName | `ACTS` |
   | commonName | `your-email@gmail.com` |
   | emailAddress | `your-email@gmail.com` |

   Click **Generate a new key** (RSA 2048). The email address must exactly match the account in Thunderbird.
4. **Extensions** tab: Type = **End Entity**, Time range = **365 Days** → **Apply**.
5. **Key usage** tab:
   - X509v3 Key Usage: ✔ **Digital Signature**, ✔ **Non Repudiation**, ✔ **Key Encipherment**
   - X509v3 Extended Key Usage: ✔ **E-mail Protection**
6. **Netscape** tab: Cert Type = **S/MIME**.
7. Click **OK**.

✅ Email certificate created.

---

## 6. Step 4: Export the Certificate (PKCS#12 chain)

1. In XCA, select **EMAIL-CERT** → click **Export**.
2. Export format: **PKCS #12 chain (\*.pfx)**.
3. Choose a filename, e.g. `your-email@gmail.com.pfx`, and click **OK**.
4. Set a strong **password**. You will need it for the import.

> The "chain" option bundles EMAIL-CERT + sub-ca + root-ca + the private key together.

---

## 7. Step 5: Import the Certificate into Thunderbird

1. Open Thunderbird and log in to your account.
2. Go to **Settings → Privacy & Security**.
3. Scroll to **Certificates** → click **Manage Certificates**.
4. Open the **Your Certificates** tab → click **Import…**.
5. Select the `.pfx` file and enter the password.
6. The certificate should now be listed under **CDAC**, along with its expiry date.

**Trust the CA (recommended):** in the same window open the **Authorities** tab → **Import…** → import the `root-ca` certificate → tick **Trust this CA to identify email users**. Without this, Thunderbird may show the signature as *untrusted*.

---

## 8. Step 6: Configure Signing and Encryption

1. **Settings → Privacy & Security → Email End-To-End Encryption → Account Settings** (or **Account Settings → End-To-End Encryption**).
2. Under **S/MIME**:
   - **Personal certificate for digital signing** → **Select…** → choose your certificate
   - **Personal certificate for encryption** → **Select…** → choose the same certificate
3. Under **Default settings for sending messages**:
   - ✔ **Enable encryption for new messages**
   - ✔ **Sign unencrypted messages**

> **About OpenPGP:** Thunderbird also offers an OpenPGP option ("Create a new OpenPGP key"). That is a **different system** that does not use your X.509 certificate. For this practical (S/MIME), make sure **S/MIME** is selected in the Encrypt dropdown, not OpenPGP.

---

## 9. Step 7: Test It

1. Click **Write** and send a mail **to yourself** (you need your own public certificate to encrypt for yourself).
2. In the compose window open the **Security** menu (or the Encrypt dropdown) and select:
   - ✔ **S/MIME**
   - ✔ **Encrypt**
   - ✔ **Digitally Sign**
3. Send, then open the received mail.
4. Click the **Message Security** icon and check:
   - 🟢 **Good Digital Signature**
   - 🔒 **Message Is Encrypted**

> To send an encrypted mail to **someone else**, you first need *their* public certificate (get a signed mail from them, then it appears under **People**).

---

## 10. Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| Certificate not offered for selection | Email in the cert must match the account email, and Key Usage / E-mail Protection must be ticked. |
| Signature shows as untrusted | Import `root-ca` into **Authorities** and trust it for email. |
| Cannot encrypt for recipient | You don't have their public certificate yet. |
| Import fails | Wrong `.pfx` password, or export was not "PKCS#12 chain". |
| Certificate expired | Email cert was issued for 365 days. Recreate it. |

---

## 11. Viva / Exam Points

- **Why a Sub CA?** The Root key stays offline and protected. If the Sub CA is compromised, only it is revoked, not the whole PKI.
- **Why "End Entity"?** It marks the certificate as not a CA (`CA:FALSE`), so it can't issue other certificates.
- **Which key signs and which encrypts?** Signing uses the sender's private key. Encryption uses the receiver's public key.
- **Why Non-Repudiation?** The signer cannot later deny having signed the message.
- **What does the .pfx contain?** Certificate, chain and private key, protected by a password.
