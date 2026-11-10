# AWS Assignment 8

## Q1. Create EC2 Instance and Connect

1. EC2 Dashboard → **Launch instance**
2. Name: `basic-ec2`
3. AMI: **Ubuntu**
4. Instance type: `t3.micro`
5. Key pair → **Create new key pair** → download the `.pem` file
6. Network settings → **Create security group** → allow **SSH (22)** from **My IP**
7. Click **Launch instance**
8. Select instance → **Connect** → **EC2 Instance Connect** → **Connect**

---

## Q2. Create S3 Bucket and Upload File

1. S3 → **Create bucket**
2. Name: `my-basic-bucket-001` (must be globally unique)
3. Open the bucket → **Upload** → add `index.html` → **Upload**
4. Click the file → copy **Object URL**
5. Make it public (if needed):
   - Bucket → **Permissions** → **Block public access** → Edit → untick → Save
   - Bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-basic-bucket-001/*"
    }
  ]
}
```

6. Open the Object URL in the browser

---

## Q3. Create VPC with Public Subnet

1. VPC → **Create VPC** → **VPC only**
   - Name: `my-vpc`
   - CIDR: `10.0.0.0/16`
2. **Subnets** → Create subnet
   - VPC: `my-vpc`
   - Name: `public-subnet`
   - CIDR: `10.0.1.0/24`
3. **Internet gateways** → Create
   - Name: `my-igw`
   - Actions → **Attach to VPC** → `my-vpc`
4. **Route tables** → Create
   - Name: `public-rt`, VPC: `my-vpc`
   - Routes → Edit → Add route: `0.0.0.0/0` → **Internet Gateway** → `my-igw`
   - Subnet associations → Edit → select `public-subnet`
5. Subnet `public-subnet` → Actions → **Edit subnet settings** → enable **Auto-assign public IPv4 address**

---

## Q4. Launch EC2 Inside Your VPC

1. EC2 → **Launch instance**
2. Name: `vpc-ec2`
3. AMI: Ubuntu, Type: `t3.micro`, use the existing key pair
4. Network settings → **Edit**
   - VPC: `my-vpc`
   - Subnet: `public-subnet`
   - Auto-assign public IP: **Enable**
5. Security group (new):
   - SSH (22) → My IP
   - HTTP (80) → `0.0.0.0/0`
6. Launch → Connect using **EC2 Instance Connect**

---

## Q5. Attach IAM Role to EC2 and Access S3

1. IAM → **Roles** → **Create role**
   - Trusted entity: **AWS service**, Use case: **EC2**
   - Policy: `AmazonS3FullAccess`
   - Name: `EC2-S3-Role`
2. EC2 → select instance → **Actions** → **Security** → **Modify IAM role** → choose `EC2-S3-Role` → **Update IAM role**
3. Connect to the EC2 terminal.

Install AWS CLI v2 (if missing):

```bash
sudo apt update
sudo apt install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

Verify:

```bash
aws s3 ls
aws sts get-caller-identity
```

---

## Q6. Create Private Subnet + EC2 (No Internet)

1. VPC → **Subnets** → Create subnet
   - VPC: `my-vpc`
   - Name: `private-subnet`
   - CIDR: `10.0.2.0/24`
2. **Route tables** → Create
   - Name: `private-rt`, VPC: `my-vpc`
   - Do **not** add any Internet Gateway route
   - Subnet associations → Edit → select `private-subnet`
3. EC2 → **Launch instance**
   - Name: `private-ec2`
   - VPC: `my-vpc`, Subnet: `private-subnet`
   - Auto-assign public IP: **Disable**
   - Security group `private-sg`: SSH (22) from `10.0.0.0/16`
   - Use the same key pair

---

## Q7. Create Bastion Host (Jump Server)

1. EC2 → **Launch instance**
   - Name: `bastion-host`
   - VPC: `my-vpc`, Subnet: `public-subnet`
   - Auto-assign public IP: **Enable**
   - Security group `bastion-sg`: SSH (22) from My IP
   - Use the same key pair
2. EC2 → **Security Groups** → `private-sg` → **Edit inbound rules**
   - Delete the `10.0.0.0/16` SSH rule
   - Add: SSH (22), Source: **Custom** → select `bastion-sg` (security group, not an IP)

---

## Q8. Verify Private Access via Bastion

1. Copy the key from your local machine to the bastion:

```bash
scp -i key.pem key.pem ubuntu@<bastion-public-ip>:~/
```

2. Connect to the bastion (EC2 Instance Connect or SSH):

```bash
ssh -i key.pem ubuntu@<bastion-public-ip>
```

3. From the bastion:

```bash
chmod 400 key.pem
ssh -i key.pem ubuntu@<private-ec2-private-ip>
```

Alternative without copying the key (agent forwarding):

```bash
ssh-add key.pem
ssh -A ubuntu@<bastion-public-ip>
ssh ubuntu@<private-ec2-private-ip>
```

**Observation:**
- `private-ec2` has no public IP
- It is reachable only through the bastion host

---

## Q9. Create Two IAM Users (Access vs No Access)

**User1**
1. IAM → **Users** → **Create user**
2. Name: `s3-user-allowed`
3. Enable **console access** (set a password)
4. Permissions → **Attach policies directly** → `AmazonS3FullAccess`
5. Create user

**User2**
1. IAM → **Users** → **Create user**
2. Name: `s3-user-denied`
3. Enable **console access** (set a password)
4. Do **not** attach any policy
5. Create user

---

## Q10. Test S3 Access (Permission Check)

Use an incognito window and the console sign-in link: `https://<account-id>.signin.aws.amazon.com/console`

**Login as `s3-user-allowed`**
1. S3 → open a bucket → **Upload** a file
2. Result: **Success**

**Login as `s3-user-denied`**
1. S3 → try to list buckets or upload a file
2. Result: **Access Denied**

---

## Cleanup

```bash
aws s3 rb s3://my-basic-bucket-001 --force
```

- Terminate: `basic-ec2`, `vpc-ec2`, `private-ec2`, `bastion-host`
- Delete: route tables, subnets, `my-igw` (detach first), `my-vpc`
- Delete IAM role `EC2-S3-Role` and users `s3-user-allowed`, `s3-user-denied`
