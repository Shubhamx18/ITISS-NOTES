# 🌐 FCN Exam Notes — Syllabus Only (PGCP-ITISS Aug 2026, ACTS Pune)

Organised **session by session** exactly as in the teaching guideline. Everything not in the syllabus has been removed. Revise the 🔑 boxes and tables last.

| Session | Topic | Part |
| :-- | :-- | :-- |
| 1–2 | Internetworking, OSI, Ethernet, Wireless, Cables | 1 |
| 3 | Internet Protocol, TCP/IP, TCP vs UDP | 2 |
| 4–6 | Subnetting & VLSM (+ lab numericals) | 3 |
| 6–7 | Router IOS, SDM, Managing a Router | 4 |
| 8–10 | Static / Dynamic Routing, RIP, IGRP, EIGRP, OSPF | 5 |
| 11 | Layer 2 Switching, STP | 6 |
| 12 | VLAN, Inter-VLAN, VTP | 7 |
| 13–14 | ACL, Port Security, Hardening, AAA (TACACS+ / RADIUS) | 8 |
| 15–16 | NAT, IPv6 | 9 |
| 17 | WAN, PPP, MLPPP, PPPoE, GRE, eBGP | 10 |
| 18–20 | SDN, Virtual Networking, Mininet | 11 |
| — | Quick tables & MCQ traps | 12 |

---

## Part 1 — Internetworking, OSI, Ethernet, Wireless, Cables (Sessions 1–2)

### Internetworking
* **Internetworking** = connecting several networks with **routers** so they work as one big network. **internet** (small i) = any connected networks; **Internet** = the global one.
* Devices: **Hub** (L1) | **Switch / Bridge** (L2) | **Router** (L3) | **Gateway** (all layers, protocol conversion).

### OSI model

> **Bottom → top:** *Please Do Not Throw Sausage Pizza Away.*

| Layer | PDU | Job | Examples |
| :-- | :-- | :-- | :-- |
| 7 Application | Data | User services | HTTP, FTP, DNS, SMTP |
| 6 Presentation | Data | Encryption, compression, format | SSL/TLS, JPEG |
| 5 Session | Data | Start / manage / end sessions | |
| 4 Transport | **Segment** | Ports, reliability | TCP, UDP |
| 3 Network | **Packet** | Logical (IP) addressing, routing | IP, **Router** |
| 2 Data Link | **Frame** | MAC addressing, error detection | **Switch** |
| 1 Physical | **Bits** | Signals, cables | **Hub**, repeater |

### Ethernet (IEEE 802.3)
* **CSMA/CD** (wired): listen → send → if collision, **random backoff** → retry. **CSMA/CA** (wireless): avoid collisions before sending.
* **MAC address:** 48 bits (12 hex digits); first 24 bits = vendor **OUI**; broadcast = `FF:FF:FF:FF:FF:FF`.
* **Frame:** min **64 B**, max **1518 B** (payload **46–1500 B**).

| Device | Collision domains | Broadcast domains |
| :-- | :-- | :-- |
| **Hub** | **1** | **1** |
| **Switch** | **1 per port** | **1** (unless VLANs) |
| **Router** | 1 per interface | **1 per interface** |

### Cables (lab questions)

| | **UTP** | **STP** |
| :-- | :-- | :-- |
| Full form | Unshielded Twisted Pair | Shielded Twisted Pair |
| Shielding | None | **Metallic shield** around pairs |
| EMI / crosstalk | More affected | **Better protection** |
| Cost / weight | Cheap, flexible | Costlier, bulkier |

| Category | Speed |
| :-- | :-- |
| Cat3 | 10 Mbps |
| Cat5 | 100 Mbps |
| **Cat5e** | **1 Gbps** |
| Cat6 | 1 Gbps (10 Gbps up to 55 m) |
| Cat6a | 10 Gbps up to 100 m |

* 🔑 **"e" in Cat5e = Enhanced** (less crosstalk → supports Gigabit).
* **Max twisted-pair length = 100 m**, connector **RJ-45**.
* **Straight-through:** different devices (PC–Switch, Switch–Router). **Crossover:** same devices (PC–PC, Switch–Switch). **Rollover:** console port.
* **Fibre:** **Single-mode** = laser, long distance. **Multimode** = LED, short distance.

### Wireless (IEEE 802.11)
* Parts: **AP** (access point), **SSID** (network name). Modes: **Infrastructure** (via AP) and **Ad hoc** (device-to-device).

| Standard | Band | Speed | Name |
| :-- | :-- | :-- | :-- |
| 802.11b | 2.4 GHz | 11 Mbps | |
| 802.11a | 5 GHz | 54 Mbps | |
| 802.11g | 2.4 GHz | 54 Mbps | |
| 802.11n | 2.4 + 5 GHz | up to 600 Mbps | Wi-Fi 4 |
| 802.11ac | 5 GHz | — | Wi-Fi 5 |
| 802.11ax | 2.4 + 5 GHz | — | Wi-Fi 6 |

* **Non-overlapping 2.4 GHz channels: 1, 6, 11.** Bluetooth = 802.15, WiMAX = 802.16.
* **Security (weak → strong):** WEP → WPA → **WPA2** → **WPA3**.

---

## Part 2 — Internet Protocol, TCP/IP Model, TCP vs UDP (Session 3)

### TCP/IP model

| TCP/IP layer | OSI layers | Protocols |
| :-- | :-- | :-- |
| Application | 7 + 6 + 5 | HTTP, FTP, DNS, SMTP, DHCP |
| Transport | 4 | TCP, UDP |
| Internet | 3 | IP, ICMP, ARP |
| Network Access | 2 + 1 | Ethernet, Wi-Fi |

### IP essentials
* **IP** = connectionless, best-effort, unreliable delivery with **32-bit** logical addresses. **TTL** drops by 1 at each router (stops loops).

| Class | First octet | Default mask |
| :-- | :-- | :-- |
| A | 1–126 | /8 |
| B | 128–191 | /16 |
| C | 192–223 | /24 |
| D | 224–239 | Multicast |
| E | 240–255 | Experimental |

* **Private:** `10.0.0.0/8`, `172.16.0.0/12` (172.16–172.31), `192.168.0.0/16`.
* **127.0.0.1** = loopback | **169.254.x.x** = APIPA (DHCP failed).
* **ARP:** IP → MAC. **ICMP:** diagnostics (`ping`, `traceroute`). **DHCP (UDP 67/68):** **DORA** = Discover → Offer → Request → Acknowledge.

### TCP vs UDP (lab question)

| Feature | **TCP** | **UDP** |
| :-- | :-- | :-- |
| Connection | Connection-oriented | Connectionless |
| Reliability | Reliable (ACKs, retransmission) | Unreliable, no guarantee |
| Handshake | 3-way: SYN → SYN-ACK → ACK | None |
| Header | 20 bytes (min) | 8 bytes |
| Speed | Slower | Faster |
| Flow control | Yes | No |
| Used for | HTTP, FTP, SMTP, SSH | DNS, DHCP, TFTP, SNMP, voice/video |

---

## Part 3 — Subnetting & VLSM (Sessions 4–6)

**3 steps:** (1) host bits `h` with **2^h − 2 ≥ hosts** → (2) **prefix = 32 − h** → (3) **block size = 2^h**.

| Hosts needed | h | Prefix | Mask (last octet) | Block |
| :-- | :-- | :-- | :-- | :-- |
| ≤ 2 | 2 | /30 | .252 | 4 |
| ≤ 6 | 3 | /29 | .248 | 8 |
| ≤ 14 | 4 | /28 | .240 | 16 |
| ≤ 30 | 5 | /27 | .224 | 32 |
| ≤ 62 | 6 | /26 | .192 | 64 |
| ≤ 126 | 7 | /25 | .128 | 128 |

* **Network address** = IP AND mask. **Broadcast** = all host bits 1. **Usable hosts** = between them.
* **VLSM rule:** always allocate the **largest** requirement first.

### Lab numericals (solved)

**1. `192.168.5.85/24`** → Network **192.168.5.0**, host part **.85** (0.0.0.85), broadcast 192.168.5.255.

**2. `10.128.240.50/30`** → block 4, `50` is in 48–51 → Network **10.128.240.48**, host part **0.0.0.2**, usable **.49 and .50**, broadcast **.51**.

**3. VLSM on `192.168.1.0/24`** (28, 52, 15, 5 hosts — sorted largest first):

| Subnet | Hosts | Prefix | Network | Usable range | Broadcast |
| :-- | :-- | :-- | :-- | :-- | :-- |
| Subnet 2 | 52 | /26 | 192.168.1.0 | .1 – .62 | .63 |
| Subnet 1 | 28 | /27 | 192.168.1.64 | .65 – .94 | .95 |
| Subnet 3 | 15 | /27 *(/28 holds only 14)* | 192.168.1.96 | .97 – .126 | .127 |
| Subnet 4 | 5 | /29 | 192.168.1.128 | .129 – .134 | .135 |

**4. Class C `195.1.1.0`, 10 subnets, 12 hosts each** → 12 hosts need **/28** (255.255.255.240), block **16**.

| Subnet | 0 | 1 | 2 | 3 | 10 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| Network | .0 | .16 | .32 | .48 | .160 |
| **Host 1** | **195.1.1.1** | **195.1.1.17** | **195.1.1.33** | **195.1.1.49** | **195.1.1.161** |

**5. `152.152.0.0/16`, 500 hosts per subnet** → 9 host bits (2⁹ − 2 = 510) → **/23**, mask **255.255.254.0**, block 2 in 3rd octet. Subnets: 152.152.**0**.0, 152.152.**2**.0, 152.152.**4**.0 … (7 borrowed bits → 128 subnets). First subnet usable: 152.152.0.1 – 152.152.1.254, broadcast 152.152.1.255.

---

## Part 4 — Router IOS, SDM, Managing a Router (Sessions 6–7)

* **CLI modes:** `Router>` User EXEC → `Router#` Privileged EXEC → `Router(config)#` Global → `Router(config-if)#` Interface → `Router(config-line)#` Line.
* **Memory:**

| Memory | Stores |
| :-- | :-- |
| **ROM** | POST, bootstrap, ROMMON |
| **Flash** | **IOS image** |
| **NVRAM** | **startup-config** |
| **RAM** | running-config, routing & ARP tables |

* **Boot sequence:** POST → Bootstrap (ROM) → load **IOS (Flash)** → load **startup-config (NVRAM)** → *if missing, setup mode*.
* **SDM (Security Device Manager):** web-based **GUI** to configure Cisco routers (needs `ip http server`); no CLI knowledge needed.

### Configuration register

| Value | Meaning |
| :-- | :-- |
| **0x2102** | **Default** — boot IOS from Flash, load startup-config |
| **0x2142** | **Ignore startup-config** (password recovery) |
| 0x2101 | Boot from ROM (RxBoot) |
| 0x2100 | Stay in ROMMON |

* **Password recovery steps:** Break during boot → ROMMON → `confreg 0x2142` → `reset` → skip setup → `enable` → `copy startup-config running-config` → set new password → `config-register 0x2102` → `copy running-config startup-config` → `reload`.
* Change in IOS: `config-register 0x2102`. Check: `show version`.

### Managing the router (lab topics)

| Topic | Commands / Facts |
| :-- | :-- |
| **Telnet** (TCP 23, clear text) | `line vty 0 4` → `password cisco` → `login`; connect with `telnet <IP>`; suspend with **Ctrl+Shift+6, X** |
| **SSH** (TCP 22, encrypted) | `ip domain-name x.com` → `crypto key generate rsa` → `transport input ssh` |
| **Resolving hostname** | Local: `ip host R2 10.0.0.2` · DNS: `ip name-server 8.8.8.8` + `ip domain-lookup` · Stop DNS wait on typos: `no ip domain-lookup` |
| **Debugging** | `debug ip rip`, `debug ip ospf events` · `show debugging` · **`undebug all`** · `terminal monitor` (see debug in Telnet/SSH) |
| **IOS backup/upgrade** | `copy flash: tftp:` (backup) · `copy tftp: flash:` (upgrade) · `show flash:` |
| **Passwords** | `enable secret <p>` (**encrypted**) vs `enable password` (plain) · `service password-encryption` |
| **Save / view** | `copy running-config startup-config` · `show running-config` · `show ip interface brief` · `show version` |
| **Interface** | `ip address 192.168.1.1 255.255.255.0` → `no shutdown` |
| **Neighbours** | **CDP** (Cisco only) `show cdp neighbors` · **LLDP** (IEEE standard) |

---

## Part 5 — Static, Dynamic Routing & Routing Protocols (Sessions 8–10)

* **Static** = manual, no CPU overhead, doesn't adapt. **Dynamic** = learned via protocols, adapts to failures.
* **Static route:** `ip route 192.168.2.0 255.255.255.0 10.0.0.2` | **Default route:** `ip route 0.0.0.0 0.0.0.0 <next-hop>` | **Floating static** = backup with **higher AD**.

### Administrative Distance (lower wins between protocols)

| Source | AD | Source | AD |
| :-- | :-- | :-- | :-- |
| Connected | **0** | OSPF | **110** |
| Static | **1** | RIP | **120** |
| eBGP | **20** | EIGRP external | **170** |
| EIGRP internal | **90** | iBGP | **200** |
| IGRP | **100** | | |

* **AD** picks between **different protocols**; **metric** picks within **one protocol**.
* **Distance Vector:** RIP, IGRP, EIGRP (Bellman-Ford style, share tables with neighbours). **Link State:** OSPF (Dijkstra, full topology map). **Path Vector:** BGP.
* **Routing table codes:** `C` Connected | `S` Static | `R` RIP | `D` EIGRP | `O` OSPF | `B` BGP | `S*` default.

### Protocol comparison

| | **RIP** | **IGRP** | **EIGRP** | **OSPF** |
| :-- | :-- | :-- | :-- | :-- |
| Type | Distance vector | Distance vector | Advanced DV | Link state |
| Metric | **Hop count** | Bandwidth + Delay | Bandwidth + Delay | **Cost = 10⁸ / BW** |
| Max | **15 hops** (16 = unreachable) | 100 hops default | 255 | — |
| Updates | every **30 s** | every **90 s** | Triggered (hello 5 s) | Triggered (LSAs) |
| Vendor | Open | **Cisco**, classful, **obsolete** | Cisco (now open) | Open |
| Multicast | v2: 224.0.0.9 | — | **224.0.0.10** | **224.0.0.5 / .6** |
| Algorithm | Bellman-Ford | — | **DUAL** | **Dijkstra SPF** |

* **RIP:** v1 = classful, broadcast. **v2 = classless, multicast, VLSM, authentication.** Timers: update 30 / invalid 180 / holddown 180 / flush 240 s. Loop prevention: split horizon, route poisoning, holddown.
* **EIGRP:** keeps **neighbour, topology, routing tables**. **Successor** = best path; **Feasible Successor** = backup that meets the feasibility condition. Supports **unequal-cost load balancing**. **AS number must match** between neighbours.
* **OSPF:**
  * **Area 0** = backbone. **Hello 10 s, Dead 40 s.**
  * **Packet order:** Hello → DBD → LSR → LSU → LSAck. **States:** Down → Init → 2-Way → ExStart → Exchange → Loading → **Full**.
  * **DR/BDR election** (broadcast networks): highest **priority**, then highest **Router ID**; priority **0** = never elected.
  * **Router ID:** manual → highest **loopback** IP → highest **physical** IP.
  * Neighbours must match: **Area ID, Hello/Dead timers, subnet mask, authentication**.

### Configuration (lab)

| Protocol | Commands |
| :-- | :-- |
| **RIP** | `router rip` → `version 2` → `network 192.168.1.0` → `no auto-summary` |
| **IGRP** | `router igrp 100` → `network 192.168.1.0` |
| **EIGRP** | `router eigrp 100` → `network 192.168.1.0 0.0.0.255` → `no auto-summary` |
| **OSPF** | `router ospf 1` → `network 192.168.1.0 0.0.0.255 area 0` |
| Verify | `show ip route`, `show ip protocols`, `show ip ospf neighbor`, `show ip eigrp neighbors` |

---

## Part 6 — Layer 2 Switching & STP (Session 11)

* **Switch functions:** **Learn** source MAC → **Forward/Filter** by MAC table → **Flood** unknown unicast & broadcast → **Avoid loops (STP)**.
* **Why STP:** redundant links cause **loops → broadcast storms**, MAC table instability, duplicate frames. STP **blocks** some ports to build a loop-free tree.

### Root bridge & priority
* **Root bridge = lowest Bridge ID** = **Priority + MAC**. Tie → lowest MAC.
* **Priority:** default **32768**, range 0–61440, **steps of 4096**. **Lower is better.**
* **Make a switch root:** `spanning-tree vlan 1 priority 4096` *or* `spanning-tree vlan 1 root primary` (sets 24576 or lower) · `root secondary` = 28672.
* **Disable STP:** `no spanning-tree vlan 1` | **Verify:** `show spanning-tree`.

### Port roles & states
* **Root Port** (best path to root; one per non-root switch) | **Designated Port** (forwarding port per segment; all root-bridge ports) | **Blocked** port.
* **States:** Blocking → Listening → Learning → Forwarding (**30–50 s**). Timers: Hello **2 s**, Forward delay **15 s**, Max age **20 s**.
* **Cost:** 10 Mbps = 100 | **100 Mbps = 19** | 1 Gbps = 4 | 10 Gbps = 2.

### Types of STP (syllabus question)

| Type | Standard | Feature |
| :-- | :-- | :-- |
| **STP** | **802.1D** | Classic; slow (30–50 s) |
| **PVST+** | Cisco | **One STP instance per VLAN** |
| **RSTP** | **802.1w** | Fast convergence; states Discarding / Learning / Forwarding |
| **Rapid PVST+** | Cisco | RSTP per VLAN |
| **MSTP** | **802.1s** | Maps many VLANs to few instances |

* **Protections:** **PortFast** (edge ports straight to forwarding) | **BPDU Guard** (BPDU on PortFast port → `err-disabled`) | **Root Guard** (superior BPDU → `root-inconsistent`).

---

## Part 7 — VLAN, Inter-VLAN, VTP (Session 12)

* **VLAN** = logical split of a switch into separate **broadcast domains**. Different VLANs need a **Layer 3** device to talk.
* **Ranges:** **Normal 1–1005** | **Extended 1006–4094**. VLAN 1 = default & native.
* **Access port** = one VLAN. **Trunk port** = many VLANs using **802.1Q** (**4-byte tag**, **12-bit VLAN ID**). ISL = old Cisco trunking.

```
vlan 10
 name SALES
interface f0/1
 switchport mode access
 switchport access vlan 10
interface f0/24
 switchport mode trunk
show vlan brief        show interfaces trunk
```

* **Inter-VLAN routing:**
  * **Router-on-a-stick:** one trunk link + **subinterfaces**
    ```
    interface g0/0.10
     encapsulation dot1Q 10
     ip address 192.168.10.1 255.255.255.0
    interface g0/0
     no shutdown
    ```
  * **Layer 3 switch:** `ip routing` + **SVI** (`interface vlan 10` → `ip address ...`).
  * Hosts use the subinterface / SVI IP as **default gateway**.

### VTP (VLAN Trunking Protocol)
* Syncs VLANs across trunked switches. Needs **same domain name**; **highest configuration revision number** wins.

| Mode | Behaviour |
| :-- | :-- |
| **Server** | Create / edit / delete VLANs; advertises to others |
| **Client** | **Cannot create/edit VLANs**; syncs from server (can still assign ports to VLANs) |
| **Transparent** ("transfer" mode in the lab) | Keeps its **own local VLANs**; **forwards VTP ads** so the next switch still receives them |

* **Commands:** `vtp domain CDAC` → `vtp mode server|client|transparent` → `vtp version 2` → `show vtp status`.
* 🔑 **Extended-range VLANs (1006–4094)** can't be synced by VTP v1/v2 → create them in **transparent** mode.
* **Lab steps:** configure trunks → set VTP domain + modes → create VLANs on the **server** → verify clients learned them → assign access ports → `ping` hosts of the same VLAN.

---

## Part 8 — Infrastructure Security (Sessions 13–14)

### ACLs
* **Standard (1–99):** **source IP only** → place **near destination**. **Extended (100–199):** source, destination, protocol, port → place **near source**. (Named ACLs also exist.)
* **Rules:** top-to-bottom, **first match wins**, **implicit `deny any`** at the end. Max **1 ACL per interface, per direction, per protocol**.
* **Wildcard mask = inverse of subnet mask:** `/24` → 0.0.0.255 | `/26` → 0.0.0.63 | host → `0.0.0.0` | any → `255.255.255.255`.

```
! Standard
access-list 10 permit 192.168.1.0 0.0.0.255
interface g0/0
 ip access-group 10 out
! Extended
access-list 101 deny tcp 192.168.1.0 0.0.0.255 host 10.0.0.5 eq 80
access-list 101 permit ip any any
interface g0/1
 ip access-group 101 in
! Restrict Telnet/SSH access
line vty 0 4
 access-class 10 in
! Verify
show access-lists      show ip interface g0/0
```

* **IPv6 ACL:**
  ```
  ipv6 access-list BLOCK-WEB
   deny tcp any any eq 80
   permit ipv6 any any
  interface g0/0
   ipv6 traffic-filter BLOCK-WEB in
  ```
  IPv6 ACLs have **implicit permits for Neighbor Discovery** (nd-na, nd-ns) before the implicit deny.
* **APIC-EM Path Trace ACL analysis:** traces the path between two hosts and shows **which ACL permits or drops** the traffic.

### Access-layer threats and mitigation

| Threat | Mitigation |
| :-- | :-- |
| **MAC flooding** (fills MAC table) | **Port security** |
| **Rogue DHCP server / DHCP starvation** | **DHCP snooping** |
| **ARP spoofing** | **Dynamic ARP Inspection (DAI)** |
| **VLAN hopping** | Disable DTP, unused ports as access, change native VLAN |
| **STP attack** (fake root) | **BPDU Guard, Root Guard** |

* **Port security:** limits/learns MACs per port. `switchport port-security` → `maximum 2` → `mac-address sticky` → `violation shutdown`.
  * Violation modes: `protect` (drop silently) | `restrict` (drop + log) | **`shutdown`** (**default**, port goes `err-disabled`).
* **DHCP snooping:** server-facing ports **trusted**, user ports **untrusted**. `ip dhcp snooping` → `ip dhcp snooping vlan 10` → `ip dhcp snooping trust`. Builds the **binding table**.
* **DAI:** `ip arp inspection vlan 10` — validates ARP using the **snooping binding table**.

### Basic device hardening
* Use **`enable secret`**, `service password-encryption`, strong passwords (`security passwords min-length 10`).
* **SSH instead of Telnet** (`transport input ssh`); `exec-timeout 5 0` on lines.
* **Brute-force protection:** `login block-for 120 attempts 3 within 60`.
* Add a **login banner** (`banner motd`); disable unused services (`no ip http server`, `no cdp run`).
* Switch: **shut down unused ports**, move them to an unused VLAN, change the native VLAN, enable port security.

### AAA with TACACS+ and RADIUS
* **AAA:** **Authentication** (who are you?) | **Authorization** (what can you do?) | **Accounting** (what did you do?).

| | **RADIUS** | **TACACS+** |
| :-- | :-- | :-- |
| Standard | Open | **Cisco proprietary** |
| Transport | **UDP** (1812 auth, 1813 acct) | **TCP 49** |
| Encryption | **Password only** | **Entire packet** |
| AAA | Authentication + authorization combined | **Separated** (finer control) |

```
aaa new-model
username admin secret cisco123
aaa authentication login default local
line vty 0 4
 login authentication default
```
* With a server: `tacacs server TAC1` / `radius server RAD1` → `aaa authentication login default group tacacs+ local` (**local** as fallback).
* **802.1X:** port-based access control with **Supplicant → Authenticator (switch/AP) → Authentication server (RADIUS)**.

---

## Part 9 — NAT & IPv6 (Sessions 15–16)

##
