<div align="center">

#  iptables Lab Guide

**Linux Firewall · Netfilter · SPI · NAT · GeoIP · Fail2ban**

![Course](https://img.shields.io/badge/Course-Network%20Defense%20%26%20Countermeasures-blue)
![Program](https://img.shields.io/badge/PGCP--ITISS-ACTS%20Pune-orange)
![Labs](https://img.shields.io/badge/Labs-2%20to%206-green)
![Platform](https://img.shields.io/badge/Platform-Linux-black?logo=linux&logoColor=white)

</div>

---

##  Contents

| # | Lab | Topics |
|---|---|---|
| 1 | [Overview](#-overview) | Netfilter, iptables, syntax |
| 2 | [Lab 2](#-lab-2--core-concepts) | Rule processing, default policy, tables, INPUT/OUTPUT/FORWARD |
| 3 | [Lab 3](#-lab-3--internals-targets-spi-ipv6) | Verification, internals, targets, SPI firewall, IPv6 |
| 4 | [Lab 4](#-lab-4--advanced-iptables) | Modules, GeoIP blocking |
| 5 | [Lab 5](#-lab-5--access-control--internet-sharing) | Access control, Internet sharing |
| 6 | [Lab 6](#-lab-6--port-forwarding--fail2ban) | Port forwarding, Fail2ban |
| 7 | [Cheat Sheet](#-cheat-sheet) | Quick commands, common mistakes |
| 8 | [Viva](#-viva-questions) | Likely questions and answers |

>  **Lab safety:** Use a VM and run as root. Over SSH, add the SSH `ACCEPT` rule **before** setting any `DROP` policy, or you will lock yourself out.

---

##  Overview

| Component | Role |
|---|---|
| **Netfilter** | Kernel framework that provides packet hooks |
| **iptables / ip6tables** | User-space tools that define rules for IPv4 / IPv6 |
| **nf_conntrack** | Kernel connection tracking (enables stateful filtering) |
| **Xtables-Addons** | Extra matches and targets (GeoIP, TARPIT, etc.) |

```
iptables [-t table] <command> <chain> [matches] -j <target>
```

<details>
<summary><b>Commands and matches</b></summary>

| Command | Meaning | Match | Meaning |
|---|---|---|---|
| `-A` | Append rule | `-p` | Protocol |
| `-I [n]` | Insert at position n | `-s` / `-d` | Source / destination IP |
| `-D` | Delete rule | `--sport` / `--dport` | Source / destination port |
| `-L` | List rules | `-i` / `-o` | In / out interface |
| `-F` | Flush chain | `!` | Negate a match |
| `-X` | Delete user chain | | |
| `-Z` | Zero counters | | |
| `-P` | Set default policy | | |
| `-N` | New user chain | | |

</details>

---

##  Lab 2: Core Concepts

### Rule processing

1. Packet enters a **chain** in a **table**.
2. Rules are checked **top to bottom**.
3. The **first match** decides the outcome (its **target**).
4. If nothing matches, the chain's **default policy** applies.

```bash
iptables -A INPUT -p tcp --dport 22 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT    # never reached
iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT  # fix: insert at top
iptables -L -n -v --line-numbers                 # view rules
```

> **Order matters:** put specific rules before general ones.

### Default policy

```bash
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

| Approach | Policy | Result |
|---|---|---|
| Whitelist | Default `DROP` + explicit allows | Secure |
| Blacklist | Default `ACCEPT` + explicit blocks | Easy but risky |

Only `ACCEPT` and `DROP` are valid policies.

### Predefined tables

| Table | Purpose | Chains |
|---|---|---|
| **filter** *(default)* | Allow / block | INPUT, FORWARD, OUTPUT |
| **nat** | SNAT, DNAT, MASQUERADE, REDIRECT | PREROUTING, OUTPUT, POSTROUTING |
| **mangle** | Edit headers (TOS, TTL, MARK) | All five |
| **raw** | Skip connection tracking | PREROUTING, OUTPUT |
| **security** | SELinux marking | INPUT, FORWARD, OUTPUT |

> INPUT, OUTPUT and FORWARD are **chains**, not tables.

### INPUT, OUTPUT, FORWARD

| Chain | Handles | Example |
|---|---|---|
| **INPUT** | Traffic **to** this host | Incoming SSH |
| **OUTPUT** | Traffic **from** this host | You running `curl` |
| **FORWARD** | Traffic **through** this host | Router / gateway |

```bash
# INPUT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP         # block ping
iptables -A INPUT -p tcp --dport 22 -j ACCEPT                      # allow SSH
iptables -A INPUT -p tcp --dport 80 -j REJECT                      # reject HTTP
iptables -A INPUT -s 192.168.1.50 -j DROP                          # block an IP

# OUTPUT
iptables -A OUTPUT -d 8.8.8.8 -j DROP                              # block destination
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j DROP     # block web

# FORWARD
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

```
                 ┌─> INPUT ─> local process ─> OUTPUT ─┐
Packet in ─> PREROUTING ─> routing ─┤                   ├─> POSTROUTING ─> out
                 └─> FORWARD ──────────────────────────┘
```

---

##  Lab 3: Internals, Targets, SPI, IPv6

### Verifying netfilter

```bash
iptables -V                                  # shows (nf_tables) or (legacy)
lsmod | grep -E 'ip_tables|nf_conntrack|nf_tables'
cat /proc/net/ip_tables_names                # loaded tables (legacy backend)
cat /proc/net/ip_tables_matches              # available matches
cat /proc/net/ip_tables_targets              # available targets
conntrack -L                                 # live tracked connections
iptables-save                                # dump full ruleset
```

### Internal working

1. Packet enters the kernel stack.
2. Netfilter **hooks** fire: `PREROUTING → INPUT / FORWARD → OUTPUT → POSTROUTING`.
3. Tables run in order: **raw → mangle → nat → filter → security**.
4. Each rule = **matches** + **target** + **counters**.
5. `iptables` only sends rules to the kernel. They live in memory and are **lost on reboot** unless saved.

### Targets

| Target | Terminates? | Behaviour |
|---|---|---|
| **ACCEPT** | ✅ | Allow packet |
| **DROP** | ✅ | Discard silently (sender times out) |
| **REJECT** | ✅ | Discard and send an error back |
| **LOG** | ❌ | Log, then continue to next rule |
| **RETURN** | ✅ | Leave current chain |
| **SNAT / DNAT / MASQUERADE / REDIRECT** | ✅ | Address translation (nat table) |

```bash
iptables -A INPUT -p tcp --dport 80 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --dport 23 -j LOG --log-prefix "TELNET: "
iptables -A INPUT -p tcp --dport 23 -j DROP
journalctl -k -f                             # watch logs
```

### SPI (Stateful Packet Inspection) firewall

SPI tracks each connection's **state**, so only *new* connections need explicit rules. Replies are allowed automatically.

| State | Meaning |
|---|---|
| `NEW` | First packet of a connection |
| `ESTABLISHED` | Part of a known two-way connection |
| `RELATED` | New connection tied to an existing one (FTP data, ICMP errors) |
| `INVALID` | Malformed or unknown |
| `UNTRACKED` | Marked `NOTRACK` in raw table |

#### Standard installation

```bash
# Debian / Ubuntu
apt install iptables iptables-persistent

# RHEL / Rocky
dnf install iptables-services
systemctl disable --now firewalld && systemctl enable --now iptables
```

#### Ruleset (`fw.sh`)

```bash
#!/bin/bash
iptables -F; iptables -X; iptables -t nat -F; iptables -t mangle -F

iptables -A INPUT -p tcp --dport 22 -j ACCEPT          # SSH first (avoid lock-out)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/second -j ACCEPT
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPT-DROP: "
```

#### Save and test

```bash
netfilter-persistent save                    # Debian/Ubuntu → /etc/iptables/rules.v4
service iptables save                        # RHEL family
iptables-save > rules.v4                     # manual
iptables-restore < rules.v4
nmap -p 22,80,443,3306 <server-ip>           # from another host
```

### IPv6 rule management

> IPv4 rules **do not** protect IPv6. Use `ip6tables`.

| IPv4 | IPv6 |
|---|---|
| `iptables` | `ip6tables` |
| `iptables-save` | `ip6tables-save` |
| `-p icmp` | `-p ipv6-icmp` |
| `net.ipv4.ip_forward` | `net.ipv6.conf.all.forwarding` |
| `rules.v4` | `rules.v6` |

```bash
ip6tables -L -n -v
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp -j ACCEPT    # required for neighbour discovery
ip6tables-save > /etc/iptables/rules.v6
```

> Never block all ICMPv6. IPv6 depends on it.

---

## ⚙️ Lab 4: Advanced iptables

### Loading modules

```bash
lsmod | grep -E 'nf_|xt_|ipt_'               # loaded modules
modinfo xt_conntrack                         # module details
modprobe nf_conntrack_ftp                    # load (e.g. FTP helper)
modprobe -r xt_limit                         # unload
echo "nf_conntrack_ftp" >> /etc/modules-load.d/netfilter.conf   # load at boot
```

| Module | Use | Example |
|---|---|---|
| `conntrack` | Connection state | `-m conntrack --ctstate NEW` |
| `multiport` | Many ports | `-m multiport --dports 80,443` |
| `limit` | Rate limit | `-m limit --limit 5/min` |
| `connlimit` | Connections per IP | `-m connlimit --connlimit-above 20` |
| `recent` | Track recent hits | brute-force defence |
| `iprange` | IP range | `--src-range 10.0.0.10-10.0.0.50` |
| `mac` | MAC address | `--mac-source AA:BB:CC:DD:EE:FF` |
| `time` | Time / weekday | `--timestart 09:00 --timestop 18:00` |
| `string` | Payload content | `--string "word" --algo bm` |
| `owner` | Local user (OUTPUT) | `--uid-owner 1001` |

**SSH brute-force guard** (4 attempts in 60 s are dropped):

```bash
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
```

**User-defined chain:**

```bash
iptables -N WEB_RULES
iptables -A WEB_RULES -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -j WEB_RULES
```

### GeoIP blocking with Xtables-Addons

```bash
# 1. Install
apt install xtables-addons-common xtables-addons-dkms libtext-csv-xs-perl unzip

# 2. Download and build the country database
mkdir -p /usr/share/xt_geoip && cd /usr/share/xt_geoip
/usr/lib/xtables-addons/xt_geoip_dl
/usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip *.csv

# 3. Load and verify
modprobe xt_geoip && lsmod | grep geoip

# 4. Use it
iptables -A INPUT -m geoip --src-cc CN,RU -j DROP                  # block countries
iptables -A INPUT -p tcp --dport 22 -m geoip --src-cc IN -j ACCEPT # SSH from India only
iptables -A INPUT -p tcp --dport 22 -j DROP
iptables -A OUTPUT -m geoip --dst-cc KP -j DROP                    # block outbound
```

> Database commands and sources vary by distro and version. If a step fails, check `man xtables-addons`.
> GeoIP is not perfectly accurate and VPNs bypass it. Treat it as one layer of defence.

**Other Xtables-Addons features:** `TARPIT`, `DELUDE`, `CHAOS`, `ECHO`, `pknock`.

---

##  Lab 5: Access Control & Internet Sharing

### Access control

| Control by | Rule |
|---|---|
| **Source IP** | `iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT` then `-j DROP` for the rest |
| **MAC** | `iptables -A INPUT -m mac --mac-source AA:BB:CC:DD:EE:FF -j DROP` |
| **IP range** | `iptables -A FORWARD -m iprange --src-range 192.168.1.100-192.168.1.150 -j DROP` |
| **Time** | `iptables -A FORWARD -p tcp --dport 80 -m time --timestart 09:00 --timestop 18:00 --weekdays Mon,Tue,Wed,Thu,Fri -j ACCEPT` |
| **User** | `iptables -A OUTPUT -m owner --uid-owner 1001 -p tcp --dport 80 -j DROP` |
| **Rate** | `iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 30 -j REJECT` |
| **Content** | `iptables -A FORWARD -p tcp --dport 80 -m string --string "example.com" --algo bm -j DROP` |
| **Zone** | `iptables -A FORWARD -i eth0 -o eth1 -j DROP` (WAN to LAN blocked) |

>  The `time` match uses **UTC** by default. India is UTC+5:30, so convert times or use `--kerneltz`.
>  String matching works on plain HTTP only. Use a proxy such as Squid for HTTPS.

### Internet sharing

```
[Clients] ── eth1 (192.168.10.1) ── [Linux gateway] ── eth0 ── Internet
 GW 192.168.10.1 · DNS 8.8.8.8
```

```bash
# 1. Enable forwarding (permanent)
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# 2. NAT on the outgoing interface
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 3. Stateful forwarding
iptables -P FORWARD DROP
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 4. Save
netfilter-persistent save
```

**Client setup:** IP in `192.168.10.0/24`, gateway `192.168.10.1`, DNS `8.8.8.8`.
**Test:** `ping 8.8.8.8` on the client, then `iptables -t nat -L -n -v` and `conntrack -L` on the gateway.

> Use `-j SNAT --to-source <ip>` instead of MASQUERADE if the public IP is static.

---

##  Lab 6: Port Forwarding & Fail2ban

### Port forwarding (DNAT)

**Goal:** `gateway:8080` → internal web server `192.168.10.10:80`

```bash
sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 \
         -j DNAT --to-destination 192.168.10.10:80

iptables -A FORWARD -i eth0 -o eth1 -p tcp -d 192.168.10.10 --dport 80 \
         -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

**Test:** `curl http://<gateway-public-ip>:8080` from outside.

| Need | Use |
|---|---|
| Forward to another host | `DNAT` in `nat/PREROUTING` + `FORWARD` accept |
| Redirect to another port on same host | `iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080` |
| Traffic from the gateway itself | Rule in `nat/OUTPUT` (it skips PREROUTING) |

### Fail2ban

Fail2ban reads logs, spots repeated failures, and **adds iptables rules** to ban the offending IPs.

```
Log ─> Filter (regex) ─> Jail (maxretry / findtime) ─> Action (iptables ban) ─> Unban after bantime
```

```bash
apt install fail2ban && systemctl enable --now fail2ban
```

`/etc/fail2ban/jail.local` *(never edit `jail.conf`)*:

```ini
[DEFAULT]
bantime   = 10m
findtime  = 10m
maxretry  = 5
ignoreip  = 127.0.0.1/8 ::1 192.168.1.0/24
banaction = iptables-multiport

[sshd]
enabled = true
port    = ssh
backend = systemd
```

| Setting | Meaning |
|---|---|
| `maxretry` | Failures allowed before ban |
| `findtime` | Window for counting failures |
| `bantime` | Ban duration |
| `ignoreip` | Never-ban whitelist |
| `banaction` | Enforcement method (iptables) |

```bash
systemctl restart fail2ban
fail2ban-client status sshd                  # banned IPs
iptables -L -n --line-numbers                # look for chain f2b-sshd
tail -f /var/log/fail2ban.log
fail2ban-client set sshd unbanip <ip>        # manual unban
```

**Test:** fail SSH login 5 or more times from another machine, then check the status above.

>  **Wireshark tie-in:** `tcpdump -i eth0 port 22 -w ssh.pcap`, then open it in Wireshark with the filter `tcp.port == 22` to see the failed attempts and the dropped traffic after the ban.

---

##  Cheat Sheet

| Task | Command |
|---|---|
| List with numbers | `iptables -L -n -v --line-numbers` |
| Show as commands | `iptables -S` |
| Append / insert | `iptables -A INPUT ...` / `iptables -I INPUT 1 ...` |
| Delete by number | `iptables -D INPUT 3` |
| Flush / delete chains | `iptables -F` / `iptables -X` |
| Set policy | `iptables -P INPUT DROP` |
| Show nat table | `iptables -t nat -L -n -v` |
| Save / restore | `iptables-save > f` / `iptables-restore < f` |
| Persist (Debian/Ubuntu) | `netfilter-persistent save` |
| Enable forwarding | `sysctl -w net.ipv4.ip_forward=1` |
| Live connections | `conntrack -L` |
| Test ports | `nmap -p 22,80 <ip>` · `nc -zv <ip> <port>` |

**Reset to wide open (lab only):**

```bash
iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT
iptables -F; iptables -X; iptables -t nat -F; iptables -t mangle -F
```

**Common mistakes**

- ❌ `INPUT DROP` before allowing SSH
- ❌ General rule placed above a specific one
- ❌ Missing `ESTABLISHED,RELATED` (replies blocked)
- ❌ Forgetting `ip_forward=1` or FORWARD rules for NAT / port forwarding
- ❌ Not saving rules (lost on reboot)
- ❌ Securing IPv4 but leaving IPv6 open

---

## 🎓 Viva Questions

<details>
<summary><b>Netfilter vs iptables?</b></summary>
Netfilter is the kernel framework. iptables is the user-space tool that configures it.
</details>

<details>
<summary><b>Table vs chain?</b></summary>
Tables group rules by function (filter, nat, mangle, raw, security). Chains are ordered rule lists attached to hook points (INPUT, OUTPUT, FORWARD, PREROUTING, POSTROUTING).
</details>

<details>
<summary><b>Default table?</b></summary>
<code>filter</code>.
</details>

<details>
<summary><b>INPUT vs FORWARD?</b></summary>
INPUT is for packets addressed to the firewall. FORWARD is for packets passing through it.
</details>

<details>
<summary><b>DROP vs REJECT?</b></summary>
DROP discards silently and the sender times out. REJECT discards and sends an error back.
</details>

<details>
<summary><b>Why a default DROP policy?</b></summary>
Whitelist model: only explicitly allowed traffic passes, which is safer.
</details>

<details>
<summary><b>What happens if no rule matches?</b></summary>
The chain's default policy applies.
</details>

<details>
<summary><b>What is SPI and why is it better than stateless filtering?</b></summary>
SPI tracks connection state. Replies are allowed via ESTABLISHED/RELATED and INVALID packets are dropped, so fewer ports must be open.
</details>

<details>
<summary><b>Connection states?</b></summary>
NEW, ESTABLISHED, RELATED, INVALID, UNTRACKED.
</details>

<details>
<summary><b>How does Internet sharing work?</b></summary>
Enable IP forwarding, add MASQUERADE (or SNAT) in nat POSTROUTING on the outgoing interface, and allow traffic in FORWARD.
</details>

<details>
<summary><b>Which table and chain for port forwarding?</b></summary>
DNAT in the <code>nat</code> table's <code>PREROUTING</code> chain, plus an ACCEPT in the <code>filter</code> FORWARD chain.
</details>

<details>
<summary><b>Why don't IPv4 rules protect IPv6?</b></summary>
IPv6 has a separate netfilter stack managed by <code>ip6tables</code> and needs its own rules.
</details>

<details>
<summary><b>What does Xtables-Addons add?</b></summary>
Extra matches and targets: <code>geoip</code>, <code>TARPIT</code>, <code>DELUDE</code>, <code>CHAOS</code>, <code>pknock</code>.
</details>

<details>
<summary><b>How does Fail2ban use iptables?</b></summary>
It scans logs for repeated failures and creates rules (via a chain like <code>f2b-sshd</code>) to ban offending IPs temporarily.
</details>

<details>
<summary><b>How do you make rules persistent?</b></summary>
Save with <code>iptables-save</code> and restore at boot, or use <code>iptables-persistent</code> / <code>netfilter-persistent</code> (Debian/Ubuntu) or <code>iptables-services</code> (RHEL family).
</details>

---

<div align="center">

**PGCP-ITISS · ACTS Pune · Network Defense & Countermeasures**

</div>
