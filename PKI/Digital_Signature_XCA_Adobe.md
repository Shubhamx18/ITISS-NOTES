# Digital Signature of a PDF on Windows

**Tools:** XCA and Adobe Acrobat
**Platform:** Windows (GUI only)

| Item | Value |
|---|---|
| Root CA | DITISS Root CA |
| Sub CA | DITISS Sub CA |
| Signer | shubham (shubham@cdac.in) |
| Files created | shubham.pfx, rootca.crt, document_signed.pdf |
| Working folder | C:\ditiss |

```
DITISS Root CA ──signs──► DITISS Sub CA ──signs──► shubham
```

---

# PART 1: XCA

## Step 1: Create the Database

1. Create a folder named **ditiss** in the **C:** drive.
2. Open **XCA**.
3. Click **File > New Database**.
4. Select the folder **C:\ditiss**.
5. Enter the name **ditiss** and click **Save**.
6. Leave the password empty and click **OK**.

---

## Step 2: Create the Root CA

### 2.1 Create the key

Go to the **Private Keys** tab and click **New Key**. Enter:

| Field | Value |
|---|---|
| Name | root |
| Type | RSA |
| Size | 4096 |

Click **Create**.

### 2.2 Create the certificate

Go to the **Certificates** tab and click **New Certificate**. Fill in each tab as shown.

**Source tab**

| Field | Value |
|---|---|
| Signing | Create a self signed certificate |
| Signature algorithm | SHA 256 |
| Template | [default] CA |

Click **Apply extensions**.

**Subject tab**

| Field | Value |
|---|---|
| Country | IN |
| Organisation | CDAC |
| Common Name | DITISS Root CA |
| Private key | root |

**Extensions tab**

| Field | Value |
|---|---|
| Type | Certification Authority |
| Time range | 10 years |

Click **Apply**.

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Certificate Sign, CRL Sign |

Click **OK**.

---

## Step 3: Create the Sub CA

### 3.1 Create the key

Go to the **Private Keys** tab and click **New Key**. Enter:

| Field | Value |
|---|---|
| Name | sub |
| Type | RSA |
| Size | 2048 |

Click **Create**.

### 3.2 Create the certificate

Go to the **Certificates** tab and click **New Certificate**. Fill in each tab as shown.

**Source tab**

| Field | Value |
|---|---|
| Signing | Use this Certificate for signing: DITISS Root CA |
| Signature algorithm | SHA 256 |
| Template | [default] CA |

Click **Apply extensions**.

**Subject tab**

| Field | Value |
|---|---|
| Country | IN |
| Organisation | CDAC |
| Common Name | DITISS Sub CA |
| Private key | sub |

**Extensions tab**

| Field | Value |
|---|---|
| Type | Certification Authority |
| Path length | 0 |
| Time range | 5 years |

Click **Apply**.

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Certificate Sign, CRL Sign |

Click **OK**.

---

## Step 4: Create the User Certificate

### 4.1 Create the key

Go to the **Private Keys** tab and click **New Key**. Enter:

| Field | Value |
|---|---|
| Name | shubham |
| Type | RSA |
| Size | 2048 |

Click **Create**.

### 4.2 Create the certificate

Go to the **Certificates** tab and click **New Certificate**. Fill in each tab as shown.

**Source tab**

| Field | Value |
|---|---|
| Signing | Use this Certificate for signing: DITISS Sub CA |
| Signature algorithm | SHA 256 |
| Template | [default] TLS_client |

Click **Apply extensions**.

**Subject tab**

| Field | Value |
|---|---|
| Country | IN |
| Organisation | CDAC |
| Common Name | shubham |
| Email address | shubham@cdac.in |
| Private key | shubham |

**Extensions tab**

| Field | Value |
|---|---|
| Type | End Entity |
| Time range | 1 year |
| Subject alternative name | email:shubham@cdac.in |

Click **Apply** for the time range.

**Key usage tab**

| Field | Value |
|---|---|
| Key usage | Digital Signature, Non Repudiation |
| Extended key usage | E-mail Protection (and Document Signing, if listed) |
| Untick | TLS Web Server Authentication |

Click **OK**.

> **Note:** Apply the template first, then type the subject alternative name. Applying the template again can erase it.

---

## Step 5: Export the Files

### 5.1 Export the user ID

Go to the **Certificates** tab, select **shubham** and click **Export**. Enter:

| Field | Value |
|---|---|
| Format | PKCS #12 with Certificate chain |
| File name | C:\ditiss\shubham.pfx |
| Password | Set a password and remember it |

Click **OK**.

### 5.2 Export the Root CA

Select **DITISS Root CA** and click **Export**. Enter:

| Field | Value |
|---|---|
| Format | PEM (.crt) |
| File name | C:\ditiss\rootca.crt |

Click **OK**.

---

# PART 2: Adobe Acrobat

## Step 1: Trust the Root CA

1. Open **Adobe Acrobat**.
2. Click **Menu > Preferences** (or press **Ctrl + K**).
3. Click **Signatures** in the left list.
4. Next to **Identities & Trusted Certificates**, click **More…**
5. Click **Trusted Certificates** in the left pane.
6. Click **Import**.
7. Click **Browse…**, select **C:\ditiss\rootca.crt** and click **Open**.
8. Select **DITISS Root CA** in the Contacts box.
9. Open the **Trust** tab and tick **Use this certificate as a trusted root**.
10. Click **OK**, then **Import**, then **OK**.

> **Note:** If there is no Trust tab, select **DITISS Root CA**, click **Edit Trust**, tick **Use this certificate as a trusted root** and click **OK**.

---

## Step 2: Add the Digital ID

1. In the same window, click **Digital IDs** in the left pane.
2. Click **Add ID** (the **+** icon).
3. Select **My existing digital ID from: A file** and click **Next**.
4. Click **Browse…** and select **C:\ditiss\shubham.pfx**.
5. Enter the password and click **Next**.
6. Click **Done**.
7. Confirm **shubham** is listed, then click **Close** and **OK**.

> **Note:** If the file is not listed, change the file type filter to **All files**.

---

## Step 3: Sign the PDF

1. Open the PDF you want to sign.
2. In **Find text or tools**, type **certificate** and click **Use a certificate**.
3. Click **Digitally sign**.
4. Click **OK** on the message.
5. **Drag a rectangle** where the signature should appear.
6. Under **Sign with a Digital ID**, select **shubham** and click **Continue**.
7. Check the preview and click **Sign**.
8. Save the file as **document_signed.pdf**.
9. Enter the password if asked.

---

## Step 4: Verify the Signature

1. Open **document_signed.pdf**.
2. Check that the top bar says **Signed and all signatures are valid**.
3. Click the signature, then click **Signature Properties** and **Show Signer's Certificate**.
4. Confirm the certificate path:

```
DITISS Root CA
  └─ DITISS Sub CA
       └─ shubham
```

| Result in Adobe | Meaning | Fix |
|---|---|---|
| Green tick, all signatures valid | Working | None |
| Yellow warning, identity unknown | Root CA not trusted | Repeat Step 1 of Part 2 |
| Red cross, document modified | File changed after signing | Sign again |

---

## Step 5: Tamper Test

1. Edit **document_signed.pdf** (add text or a page).
2. Reopen it.
3. The signature should now show as **invalid**.
