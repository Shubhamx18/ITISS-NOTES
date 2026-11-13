# 🌐 Computer Networks — Complete Revision & MCQ Cheat Sheet

> **Syllabus-Aligned Exam Guide** covering OSI/TCP-IP, Ethernet & Wireless, Subnetting/VLSM, Routing Protocols, Switching/STP, VLAN/VTP, Security/AAA, NAT/IPv6, WAN, and SDN/Mininet.

---

## 📑 Table of Contents

1. [OSI and TCP/IP Models](#1-osi-and-tcpip-models)
2. [Ethernet, Wireless & Cables](#2-ethernet-wireless--cables)
3. [IP, TCP, and UDP](#3-ip-tcp-and-udp)
4. [Subnetting and VLSM (Numerical)](#4-subnetting-and-vlsm-numerical)
5. [Router Basics](#5-router-basics)
6. [Routing (Highest Weight)](#6-routing-highest-weight)
7. [Switching and STP](#7-switching-and-stp)
8. [VLAN, Inter-VLAN, and VTP](#8-vlan-inter-vlan-and-vtp)
9. [Network Security](#9-network-security)
10. [NAT and IPv6](#10-nat-and-ipv6)
11. [WAN Technologies](#11-wan-technologies)
12. [SDN, Virtual Networking & Mininet](#12-sdn-virtual-networking--mininet)
13. [Common MCQ Traps](#13-common-mcq-traps)

---

## 1. OSI and TCP/IP Models

* **Core Concept:** Network communication is divided into layers; each layer performs one specific task and hands data over to the next layer.
* **Top $\rightarrow$ Bottom:** `Application` $\rightarrow$ `Presentation` $\rightarrow$ `Session` $\rightarrow$ `Transport` $\rightarrow$ `Network` $\rightarrow$ `Data Link` $\rightarrow$ `Physical`
* **Bottom $\rightarrow$ Top Mnemonic:** *"Please Do Not Throw Sausage Pizza Away"*

| Layer (Top $\downarrow$) | Data Unit (PDU) | Key Devices, Protocols & Functions |
| :--- | :--- | :--- |
| **7. Application** | Data | User-facing protocols: `HTTP`, `FTP`, `DNS`, `SMTP` |
| **6. Presentation** | Data | Encryption, compression, format conversion (`SSL/TLS`, `JPEG`) |
| **5. Session** | Data | Starts, manages, and terminates sessions/conversations |
| **4. Transport** | **Segment** | Port numbers, reliability (`TCP`, `UDP`) |
| **3. Network** | **Packet** | Logical addressing (`IP`), path selection (**Router**) |
| **2. Data Link** | **Frame** | Physical addressing (`MAC`), error detection (**Switch**) |
| **1. Physical** | **Bits** | Cables, electrical/optical signals (**Hub**, Repeater) |

### TCP/IP Model (4 Layers)

| TCP/IP Layer | Equivalent OSI Layers |
| :--- | :--- |
| **1. Application** | Application + Presentation + Session |
| **2. Transport** | Transport |
| **3. Internet** | Network |
| **4. Network Access** | Data Link + Physical |

---

## 2. Ethernet, Wireless & Cables

### Ethernet (`IEEE 802.3`)

* **Access Method:**
  * Wired Ethernet uses **CSMA/CD** *(listen, send; if two send simultaneously causing a collision, wait random backoff time and retry)*.
  * Wireless uses **CSMA/CA** *(tries to avoid collisions before sending)*.
* **MAC Address:** `48 bits` (12 hex digits). First `24 bits` = Vendor ID (**OUI**). Broadcast MAC = `FF:FF:FF:FF:FF:FF`.
* **Ethernet Frame Size:** Minimum **`64 bytes`**, Maximum **`1518 bytes`** *(Data payload: `46` to `1500 bytes`)*.
* **Collision & Broadcast Domains:**
  * **Hub:** All ports share **1 collision domain** and **1 broadcast domain**.
  * **Switch:** Each port is its **own collision domain**; all ports share **1 broadcast domain** (unless VLANs are used).
  * **Router:** Each interface is its **own broadcast domain** and **own collision domain**.
* **Cabling Limits:** Maximum twisted-pair length = **`100 m`** | Connector = **`RJ-45`**.

### Wireless (`IEEE 802.11`)

* **Core Terms:** Access Point (**AP**) and **SSID** *(wireless network name)*.
* **Operating Modes:** **Infrastructure Mode** *(clients connect via AP)* vs. **Ad Hoc Mode** *(direct device-to-device without AP)*.
 
| Standard | Frequency Band | Max Speed / Wi-Fi Gen |
| :--- | :--- | :--- |
| **802.11b** | 2.4 GHz | 11 Mbps |
| **802.11a** | 5 GHz | 54 Mbps |
| **802.11g** | 2.4 GHz | 54 Mbps |
| **802.11n** | 2.4 GHz and 5 GHz | Up to 600 Mbps (MIMO / Wi-Fi 4) |
| **802.11ac** | 5 GHz | Wi-Fi 5 |
| **802.11ax** | 2.4 GHz and 5 GHz | Wi-Fi 6 |

* **Non-Overlapping Channels ($2.4\text{ GHz}$):** **`1`**, **`6`**, **`11`**
* **Other IEEE Wireless Standards:** Bluetooth = **`802.15`** | WiMAX = **`802.16`**
* **Wireless Security Ranking:** **WPA3** *(Strongest)* $\rightarrow$ **WPA2** $\rightarrow$ **WEP** *(Weak / Deprecated)*

### Cables & Pinouts

* **UTP vs. STP:**
  * **UTP** *(Unshielded Twisted Pair)*: Cheap, flexible, susceptible to electromagnetic interference (EMI).
  * **STP** *(Shielded Twisted Pair)*: Has metallic shielding to block EMI/crosstalk, costlier, bulkier.
* **Ethernet Cable Categories:**
  * **`Cat3`:** $10\text{ Mbps}$
  * **`Cat5`:** $100\text{ Mbps}$
  * **`Cat5e`:** $1\text{ Gbps}$ (*"e"* = **Enhanced**, reduced crosstalk)
  * **`Cat6`:** $1\text{ Gbps}$ ($10\text{ Gbps}$ only up to $55\text{ m}$)
  * **`Cat6a`:** $10\text{ Gbps}$ up to full $100\text{ m}$
* **Which Cable to Use:**
  * **Different devices** *(PC $\leftrightarrow$ Switch, Switch $\leftrightarrow$ Router)* $\rightarrow$ **Straight-through**
  * **Same devices** *(PC $\leftrightarrow$ PC, Switch $\leftrightarrow$ Switch)* $\rightarrow$ **Crossover**
  * **Router/Switch Console Port** $\rightarrow$ **Rollover**
* **Fiber Optic Cables:**
  * **Single-mode:** Uses **Laser**, narrow core, **long distance**.
  * **Multimode:** Uses **LED**, wider core, **short distance**.

---

## 3. IP, TCP, and UDP

* **IP (Internet Protocol):** Connectionless, best-effort packet delivery using logical addresses. `TCP` or `UDP` handles reliability.

| Feature | TCP | UDP |
| :--- | :--- | :--- |
| **Connection** | Connection-oriented, reliable | Connectionless, fast, no delivery guarantee |
| **Handshake** | 3-Way Handshake: `SYN` $\rightarrow$ `SYN-ACK` $\rightarrow$ `ACK` | None |
| **Header Size** | **`20 bytes`** | **`8 bytes`** |
| **Use Cases** | Web (`HTTP/S`), Email (`SMTP/POP3`), File Transfer (`FTP`), `SSH` | `DNS`, `DHCP`, `TFTP`, `SNMP`, Voice/Video streaming |

### Must-Know Port Numbers

| TCP Ports | UDP Ports |
| :--- | :--- |
| **`20 / 21`** — FTP *(20 Data, 21 Control)* | **`53`** — DNS *(uses both, UDP 53 is standard)* |
| **`22`** — SSH | **`67 / 68`** — DHCP *(67 Server, 68 Client)* |
| **`23`** — Telnet | **`69`** — TFTP |
| **`25`** — SMTP | **`123`** — NTP |
| **`80`** — HTTP | **`161`** — SNMP |
| **`110`** — POP3 | **`520`** — RIP |
| **`179`** — BGP | |
| **`443`** — HTTPS | |

### IPv4 Essentials

* **Address & Header:** **`32 bits`**. Header size = `20 bytes` min, `60 bytes` max. **TTL** decrements by `1` at every router to prevent infinite loops.
* **IP Protocol Numbers:** `ICMP = 1` | `TCP = 6` | `UDP = 17` | `GRE = 47` | `EIGRP = 88` | `OSPF = 89`
* **IPv4 Address Classes:**
  * **Class A:** `1 – 126` (`/8`)
  * **Class B:** `128 – 191` (`/16`)
  * **Class C:** `192 – 223` (`/24`)
  * **Class D:** `224 – 239` *(Multicast)*
  * **Class E:** `240 – 255` *(Experimental)*
* **Special IPv4 Addresses:**
  * **`127.0.0.1`:** Loopback *(tests local TCP/IP stack)*
  * **`169.254.x.x`:** APIPA *(self-assigned when DHCP fails)*
* **Private IPv4 Ranges (RFC 1918):**
  * `10.0.0.0/8` (`10.0.0.0` – `10.255.255.255`)
  * `172.16.0.0/12` (`172.16.0.0` – `172.31.255.255`)
  * `192.168.0.0/16` (`192.168.0.0` – `192.168.255.255`)
* **Core Support Protocols:**
  * **ARP:** Resolves known IP address $\rightarrow$ unknown MAC address.
  * **DHCP:** Dynamically assigns IP settings via **DORA** (`Discover` $\rightarrow$ `Offer` $\rightarrow$ `Request` $\rightarrow$ `Acknowledge`).
  * **ICMP:** Diagnostic messaging used by `ping` and `traceroute`.

---

## 4. Subnetting and VLSM (Numerical)

### Fixed 3-Step Formula

1. **Find host bits ($h$)** such that:
   $$2^h - 2 \ge \text{hosts needed}$$
2. **Calculate CIDR Prefix:**
   $$\text{Prefix} = /(32 - h)$$
3. **Calculate Block Size:**
   $$\text{Block Size} = 2^h \quad (\text{Subnets always start at multiples of the block size})$$

### Rapid Subnetting Lookup Table

| Usable Hosts Needed | Host Bits ($h$) | CIDR Prefix | Subnet Mask (Last Octet) | Block Size |
| :--- | :--- | :--- | :--- | :--- |
| Up to **2** | $2$ | **`/30`** | `.252` | `4` |
| Up to **6** | $3$ | **`/29`** | `.248` | `8` |
| Up to **14** | $4$ | **`/28`** | `.240` | `16` |
| Up to **30** | $5$ | **`/27`** | `.224` | `32` |
| Up to **62** | $6$ | **`/26`** | `.192` | `64` |
| Up to **126** | $7$ | **`/25`** | `.128` | `128` |

### Solved Syllabus Numericals

1. **Identify Network & Host Part (`192.168.5.85/24`):**
   * Network Address: `192.168.5.0` | Host Part: `.85` | Broadcast Address: `192.168.5.255`
2. **Subnet Details (`10.128.240.50/30`):**
   * Block size = `4` $\rightarrow$ `50` falls in the `48 – 51` block.
   * Network: `.48` | Usable Hosts: `.49` and `.50` | Broadcast: `.51`
3. **VLSM Allocation on `192.168.1.0/24` *(Rule: Always allocate largest host requirement first)*:**
   * `52 hosts` $\rightarrow$ `/26` (Block 64) $\rightarrow$ **`192.168.1.0/26`**
   * `28 hosts` $\rightarrow$ `/27` (Block 32) $\rightarrow$ **`192.168.1.64/27`**
   * `15 hosts` $\rightarrow$ `/27` *(since `/28` only holds 14 hosts)* $\rightarrow$ **`192.168.1.96/27`**
   * `5 hosts` $\rightarrow$ `/29` (Block 8) $\rightarrow$ **`192.168.1.128/29`**
4. **Class C Subnetting (`195.1.1.0` for 10 subnets, 12 hosts each):**
   * `12 hosts` needs `/28` (Block `16`).
   * First usable host IPs: Subnet 0 = `.1`, Subnet 1 = `.17`, Subnet 2 = `.33`, Subnet 3 = `.49`, Subnet 10 = `.161`.
5. **Class B Subnetting (`152.152.0.0/16` for 500 hosts per subnet):**
   * Needs $9$ host bits ($2^9 - 2 = 510$) $\rightarrow$ **`/23`** (`255.255.254.0`), Block = `2` in 3rd octet.
   * Subnets: `152.152.0.0`, `152.152.2.0`, `152.152.4.0`, ...

---

## 5. Router Basics

* **CLI Prompt Hierarchy:**
  `Router>` *(User EXEC)* $\rightarrow$ `Router#` *(Privileged EXEC)* $\rightarrow$ `Router(config)#` *(Global Config)* $\rightarrow$ `Router(config-if)#` *(Interface)* $\rightarrow$ `Router(config-line)#` *(Line)*
* **Router Memory Components:**
  * **ROM:** POST & bootstrap startup code
  * **Flash:** Cisco IOS operating system image
  * **NVRAM:** Saved configuration (`startup-config`)
  * **RAM:** Active running configuration (`running-config`) and routing tables
* **Boot Sequence:** `POST` $\rightarrow$ `Bootstrap (ROM)` $\rightarrow$ `Load IOS (Flash)` $\rightarrow$ `Load startup-config (NVRAM)` *(if missing, enters initial setup mode)*.
* **Configuration Register:** Default = **`0x2102`** | Password Recovery = **`0x2142`** *(bypasses NVRAM `startup-config`)*.
* **SDM (Security Device Manager):** Web-based GUI tool to configure Cisco routers without CLI.
* **Management & Discovery:**
  * `Telnet` (Port `23`, unencrypted) vs. `SSH` (Port `22`, encrypted)
  * `CDP` (Cisco proprietary neighbor discovery) vs. `LLDP` (Vendor-neutral IEEE standard)

### Essential Cisco IOS Commands

| Task | Cisco IOS Command |
| :--- | :--- |
| Save active config to NVRAM | `copy running-config startup-config` |
| Stop all active debugging | `undebug all` |
| Display logs/debugs in Telnet/SSH | `terminal monitor` |
| Map static hostname to IP | `ip host <NAME> <IP>` |
| Disable DNS lookup on command typos | `no ip domain-lookup` |
| Set encrypted enable password | `enable secret <pass>` *(Note: `enable password` is plain text)* |

---

## 6. Routing (Highest Weight)

* **Core Concept:** Routers select the best path to remote networks. **Static Routing** = manually configured routes; **Dynamic Routing** = learned automatically via protocols.
* **Administrative Distance (AD):** Measures trustworthiness of a routing source (**Lower AD wins**).

| Route Source | AD | Route Source | AD |
| :--- | :--- | :--- | :--- |
| **Connected** | **`0`** | **OSPF** | **`110`** |
| **Static** | **`1`** | **RIP** | **`120`** |
| **eBGP** | **`20`** | **EIGRP (External)** | **`170`** |
| **EIGRP (Internal)** | **`90`** | **iBGP** | **`200`** |
| **IGRP** | **`100`** | | |

* **Static & Default Routes:**
  * **Static Route:** `ip route 192.168.2.0 255.255.255.0 10.0.0.2`
  * **Default Route:** `ip route 0.0.0.0 0.0.0.0 <next-hop>` *(gateway of last resort)*
  * **Floating Static Route:** Backup static route configured with a **higher AD** than the primary route; activates only if the primary route fails.
* **AD vs. Metric:** **AD** compares routes *between different* routing protocols; **Metric** compares routes *within the same* protocol.
* **Protocol Types:**
  * **Distance Vector:** `RIP`, `IGRP`, `EIGRP` *(Advanced DV)*
  * **Link State:** `OSPF`, `IS-IS`
  * **Path Vector:** `BGP`
  * **IGP** operates inside an Autonomous System (AS); **BGP** is the **EGP** between different ASs.

### Dynamic Routing Protocols Comparison

| Protocol | Metric | Key Exam Facts |
| :--- | :--- | :--- |
| **RIP** | Hop Count | Max **`15` hops** (`16` = unreachable); updates every `30 s`. `v1`: broadcast/classful; `v2`: multicast `224.0.0.9`/classless. Loop prevention: *split horizon, route poisoning, holddown timers*. |
| **IGRP** | Bandwidth + Delay | Cisco proprietary, obsolete. |
| **EIGRP** | Bandwidth + Delay | Uses **DUAL** algorithm; multicast `224.0.0.10`; terms: *Successor* & *Feasible Successor*; supports unequal-cost load balancing. |
| **OSPF** | Cost ($\frac{10^8}{\text{BW}}$) | Uses **Dijkstra SPF**; IP protocol `89`; multicast `224.0.0.5` (all routers) and `224.0.0.6` (DR/BDR). |
| **BGP** | Path Attributes | Uses **TCP `179`**; neighbors are called **peers**. |

### OSPF Deep Dive

* **Backbone Area:** **`Area 0`** | **Timers:** `Hello = 10 s`, `Dead = 40 s` *(4x Hello)*.
* **5 OSPF Packet Types (in sequence):** `Hello` $\rightarrow$ `DBD` $\rightarrow$ `LSR` $\rightarrow$ `LSU` $\rightarrow$ `LSAck`
* **Full Adjacency State:** **`Full`**
* **DR / BDR Election:** Highest **Priority** wins, then highest **Router ID** *(Priority `0` = never participates in election)*.
* **Router ID Selection Priority:**
  1. Manually configured `router-id`
  2. Highest IP on an active **Loopback** interface
  3. Highest IP on an active **Physical** interface
* **Basic Configuration:** `router ospf 1` $\rightarrow$ `network 192.168.1.0 0.0.0.255 area 0`
* **Neighbor Adjacency Requirements:** Must match **Area ID**, **Hello/Dead timers**, **Subnet Mask**, and **Authentication**.

### BGP & Routing Table Codes

* **BGP Peering & Scope:**
  * `eBGP` = between different AS (`AD 20`) | `iBGP` = within same AS (`AD 200`).
  * **BGP Messages:** `Open`, `Update`, `Keepalive`, `Notification`.
  * **Single-Homed eBGP Rules:** Neighbors do **not** auto-discover (`neighbor <IP> remote-as <AS>`). By default, eBGP neighbors must be **directly connected** (`TTL = 1`). The BGP `network <IP> mask <MASK>` command requires an **exact match** already present in the router's routing table before advertising.
* **Routing Table Codes:** `C` = Connected | `S` = Static | `R` = RIP | `O` = OSPF | `D` = EIGRP | `B` = BGP | `S*` = Default Route

---

## 7. Switching and STP

* **Switch Forwarding Logic:** Learns source MAC addresses into its MAC address table. Unknown unicast destinations and broadcasts are **flooded** out all ports except the incoming port.
* **Why STP Exists:** Redundant Layer 2 links create loops, causing **broadcast storms**, MAC table instability, and duplicate frames. STP blocks redundant ports to create a loop-free tree.
* **Root Bridge Election:** Switch with the **lowest Bridge ID** (`Priority + MAC`). Default priority = **`32768`** *(must be changed in increments of `4096`)*. Tie-breaker $\rightarrow$ **Lowest MAC address**.
* **STP Port Roles:**
  * **Root Port (RP):** Best path to the Root Bridge *(one per non-root switch)*.
  * **Designated Port (DP):** Forwarding port on each network segment *(all ports on Root Bridge are DP)*.
  * **Blocked Port:** Discards frames to prevent loops.
* **Timers & Port States:**
  * **Timers:** `Hello = 2 s` | `Forward Delay = 15 s` | `Max Age = 20 s`
  * **States:** `Blocking` $\rightarrow$ `Listening` $\rightarrow$ `Learning` $\rightarrow$ `Forwarding` *(Total convergence: `30 – 50 s`)*
* **STP Path Costs:** `10 Mbps = 100` | `100 Mbps = 19` | `1 Gbps = 4` | `10 Gbps = 2`

| STP Variant | Standard | Key Feature |
| :--- | :--- | :--- |
| **STP** | `802.1D` | Classic Spanning Tree (`30–50 s` convergence) |
| **RSTP** | `802.1w` | Rapid convergence; states: `Discarding`, `Learning`, `Forwarding` |
| **MSTP** | `802.1s` | Maps multiple VLANs to a few STP instances |
| **PVST+** | Cisco Proprietary | Runs a separate STP instance per VLAN |

* **STP Commands & Protections:**
  * Set Root Bridge: `spanning-tree vlan 1 priority 4096` *(or `spanning-tree vlan 1 root primary`)*
  * Disable STP: `no spanning-tree vlan 1` | Verify: `show spanning-tree`
  * **PortFast:** Moves edge access ports directly to `Forwarding`.
  * **BPDU Guard:** Places a PortFast port into `err-disabled` state if any BPDU is received.
  * **Root Guard:** Configured on switch-to-switch ports; puts port into `root-inconsistent` state if a superior BPDU arrives, preventing a downstream switch from hijacking the Root Bridge role.

---

## 8. VLAN, Inter-VLAN, and VTP

* **Core Concept:** VLANs logically segment one physical switch into multiple isolated broadcast domains. Inter-VLAN communication requires a Layer 3 device (Router or L3 Switch).
* **VLAN ID Ranges:** Normal = `1 – 1005` | Extended = `1006 – 4094`. **VLAN `1`** is the default and native VLAN.
* **Port Types:**
  * **Access Port:** Belongs to a **single VLAN** (untagged traffic to end hosts).
  * **Trunk Port:** Carries **multiple VLANs** between switches using **`802.1Q`** *(inserts a `4-byte` tag with a `12-bit` VLAN ID)*. `ISL` is the legacy Cisco trunking protocol.
* **Key Commands:** `vlan 10`, `switchport mode access`, `switchport access vlan 10`, `switchport mode trunk`, `show vlan brief`
* **Inter-VLAN Routing Methods:**
  1. **Router-on-a-Stick:** Single physical trunk link divided into logical subinterfaces (`encapsulation dot1Q 10`).
  2. **Layer 3 Switch:** Uses Switched Virtual Interfaces (**SVIs**, e.g., `interface vlan 10`).

### VTP (VLAN Trunking Protocol — Cisco)

Synchronizes VLAN databases across trunked switches *(Requires identical **VTP Domain Name**; **highest Configuration Revision Number** overwrites others)*.

| VTP Mode | Capabilities |
| :--- | :--- |
| **Server** | Creates, modifies, and deletes VLANs; advertises updates to clients. |
| **Client** | Cannot create/edit VLANs; automatically syncs VLANs from Server. |
| **Transparent** | Maintains local VLANs independently; forwards VTP ads without syncing them. |

* **Commands:** `vtp mode <server|client|transparent>`, `vtp domain <name>`

---

## 9. Network Security

### Access Control Lists (ACLs)

* **Standard ACL (`1 – 99`):** Filters by **Source IP only**; place **close to the destination**.
* **Extended ACL (`100 – 199`):** Filters by **Source IP, Destination IP, Protocol, and Port**; place **close to the source**.
* **Processing Logic:** Evaluated top-to-bottom; **first match wins**; every ACL ends with an implicit **`deny any`**.
* **Wildcard Mask:** Inverse of subnet mask (`0` = must match, `1` = ignore).
  * `/24` $\rightarrow$ `0.0.0.255` | Specific Host $\rightarrow$ `0.0.0.0` | Any $\rightarrow$ `255.255.255.255`
* **Applying ACLs:** `ip access-group 10 in|out` *(Max **1 ACL** per interface, per direction, per protocol)*.
* **APIC-EM Path Trace:** Tool that traces packet paths and pinpoints which ACL permits or drops traffic.

### Access Layer Threat Mitigation

* **Port Security:** Restricts allowed MAC addresses on a switch port.
  * **Violation Modes:** `Protect` *(drops silently)*, `Restrict` *(drops + logs)*, `Shutdown` *(default — puts port in `err-disabled`)*.
* **DHCP Snooping & DAI:**
  * **DHCP Snooping:** Ports facing legitimate DHCP servers are **Trusted**; user ports default to **Untrusted** (blocks rogue `DHCP Offer`/`Ack`). Builds the **DHCP Snooping Binding Table**.
  * **Dynamic ARP Inspection (DAI):** Uses the **DHCP Snooping Binding Table** to validate ARP packets on untrusted ports and drop forged ARP replies.
* **IEEE 802.1X:** Port-based network access control authenticating users/devices *before* granting LAN access (`EAPOL` between client/switch; `RADIUS` between switch/AAA server).

| Layer 2 Attack | Mitigation |
| :--- | :--- |
| **MAC Flooding** *(CAM table overflow)* | Port Security |
| **DHCP Spoofing / Starvation** | DHCP Snooping |
| **ARP Spoofing / Poisoning** | Dynamic ARP Inspection (**DAI**) |
| **VLAN Hopping** *(Switch spoofing / Double tagging)* | Disable DTP (`switchport nonegotiate`), change native VLAN from VLAN 1 |
| **STP Root Hijack / Manipulation** | BPDU Guard & Root Guard |

* **Device Hardening:** Configure `enable secret`, `service password-encryption`, `SSH` (disable Telnet), `exec-timeout`, and `shutdown` unused switch ports.

### AAA (Authentication, Authorization, Accounting)

* **Authentication:** Who are you? | **Authorization:** What are you allowed to do? | **Accounting:** What did you do?

| Feature | TACACS+ | RADIUS |
| :--- | :--- | :--- |
| **Standard** | Cisco Proprietary | Open Standard (RFC) |
| **Transport / Port** | **TCP `49`** | **UDP `1812 / 1813`** |
| **Encryption** | Encrypts **entire packet** | Encrypts **password only** |
| **AAA Architecture** | Separates Auth, Authz, and Acct | Combines Authentication & Authorization |

---

## 10. NAT and IPv6

### NAT (Network Address Translation)

* **Static NAT:** Permanent 1-to-1 private-to-public IP mapping.
* **Dynamic NAT:** Maps private IPs dynamically from a pool of public IPs.
* **PAT (NAT Overload):** Maps **many private IPs to 1 public IP** using unique source port numbers *(most widely used)*.
* **NAT Terminology:** *Inside Local*, *Inside Global*, *Outside Local*, *Outside Global*.
* **Verify Command:** `show ip nat translations`

### IPv6 Essentials

* **Address & Header:** **`128 bits`** (8 groups of 4 hex digits). Fixed header = **`40 bytes`**.
* **Major Changes from IPv4:** **No Broadcast** *(uses Multicast & Anycast)*; **Hop Limit** replaces TTL; **no header checksum**.
* **Shortening Rules:** Omit leading zeros in any group; replace consecutive all-zero groups with `::` (**used only once** per address).
* **IPv6 Address Prefixes:**
  * **Global Unicast:** `2000::/3`
  * **Link-Local:** `FE80::/10`
  * **Unique Local:** `FC00::/7`
  * **Multicast:** `FF00::/8`
  * **Loopback:** `::1`
* **Neighbor Discovery & Auto-Config:**
  * **NDP** *(Neighbor Discovery Protocol)* replaces ARP.
  * **SLAAC:** Stateless Address Autoconfiguration.
  * **EUI-64:** Inserts `FFFE` into the middle of the 48-bit MAC address and flips the **7th bit** (U/L bit).
* **IPv4 $\rightarrow$ IPv6 Transition Mechanisms:** Dual Stack, Tunneling, Translation (`NAT64`).
* **Cisco Commands:** `ipv6 unicast-routing`, `ipv6 address 2001:db8::1/64`

---

## 11. WAN Technologies

* **PPP (Point-to-Point Protocol):** Layer 2 WAN encapsulation.
  * **LCP** *(Link Control Protocol)*: Establishes, configures, and authenticates the link.
  * **NCP** *(Network Control Protocol)*: Negotiates Layer 3 protocols (IPv4, IPv6).
  * *(Note: Cisco default serial encapsulation is **HDLC**).*
* **PPP Authentication:**
  * **PAP:** 2-way handshake; sends credentials in **plain text**.
  * **CHAP:** 3-way handshake; uses **MD5 challenge-response** and periodic re-authentication *(recommended)*.
* **PPP Extensions:**
  * **MLPPP (Multilink PPP):** Bundles multiple physical serial links into one logical high-bandwidth link.
  * **PPPoE (PPP over Ethernet):** Used over DSL; uses a `Dialer` interface; adds `8-byte` overhead reducing Ethernet MTU to **`1492 bytes`**.
* **GRE (Generic Routing Encapsulation):** Tunneling protocol (**IP protocol `47`**) that encapsulates multicast and routing updates over IP; adds `24-byte` overhead; **unencrypted** *(pair with IPsec for security)*. Configured with `tunnel source` and `tunnel destination`.
* **eBGP Single-Homed Branch Config:** `router bgp <AS>` $\rightarrow$ `neighbor <IP> remote-as <AS>` $\rightarrow$ `network <net> mask <mask>`
* **Leased Lines & Clocking:** `T1 = 1.544 Mbps` | `E1 = 2.048 Mbps` | `clock rate` is configured on the **DCE** side.

---

## 12. SDN, Virtual Networking & Mininet

### Software-Defined Networking (SDN)

* **Architecture:** Decouples the **Control Plane** *(network brain, moved to a centralized SDN controller)* from the **Data Plane** *(switches forward packets based on flow tables)*.
* **Interfaces (APIs):**
  * **Northbound API:** `REST` *(SDN Applications $\leftrightarrow$ Controller)*
  * **Southbound API:** `OpenFlow` *(Controller $\leftrightarrow$ Switches)*
* **Packet Processing Flow:**
  `Unknown Packet` $\rightarrow$ Switch sends **`Packet-In`** to Controller $\rightarrow$ Controller pushes forwarding entry via **`Flow-Mod`**
* **Syllabus Core Pillars (Scalability, Reliability, Consistency):**
  * **Scalability:** Automates multi-tenancy in Data Centres and traffic engineering in ISPs; uses **clustered controllers** (e.g., ONOS, OpenDaylight) to eliminate single-controller `Packet-In` bottlenecks.
  * **Reliability (QoS & Availability):** Global topology view allows dynamic real-time **QoS** path optimization. On controller failure, switches operate in **fail-secure mode** *(drop new flows)* or **fail-standalone mode** *(revert to traditional L2/L3 switching)*.
  * **Consistency:** Centralized policy enforcement prevents CLI configuration drift and ACL conflicts, though a compromised controller can propagate **Access Control Violations** across the entire network.
  * **Opportunities & Challenges:** *Opportunities:* Vendor neutrality (white-box hardware), rapid REST automation, lower OpEx. *Challenges:* Controller is a **Single Point of Failure (SPOF)** and high-value attack target, southbound latency, and legacy device integration.

### Virtual Networking & Mininet

* **Virtual Switch:** Software switch inside a hypervisor connecting VMs *(e.g., Open vSwitch, VMware vSwitch, Hyper-V)*; supports VLANs and trunking.
* **Key SDN / NFV Use Cases:**
  * **NAC (Network Access Control):** Verifies user identity and device security posture before allowing network access.
  * **vCE (Virtual Customer Edge):** Virtualizes the customer-edge router as software (**NFV**).
  * **Data Centre Optimization:** Seamless live VM migration, multi-tenancy, and automated load balancing.
* **Mininet:**
  * Network **emulator** *(runs real Linux kernel and network stacks)*; requires `sudo`.
  * `sudo mn --topo linear,4` $\rightarrow$ Creates `4` switches and `4` hosts in a line.
  * `sudo mn --topo tree,depth=2,fanout=2` $\rightarrow$ Creates `3` switches and `4` hosts.
  * `pingall` $\rightarrow$ Tests reachability across all hosts.
  * `sudo mn -c` $\rightarrow$ Cleans up lingering Mininet processes/interfaces.

---

## 13. Common MCQ Traps

> [!WARNING]
> **Watch out for these classic exam distractors:**

* **AD vs. Metric:** **AD** chooses between *different* routing protocols; **Metric** chooses the best path *within one* protocol.
* **OSPF vs. BGP `network` Command:** OSPF's `network` command selects interfaces to run OSPF on; BGP's `network` command advertises an **exact-match route** already in the routing table.
* **Standard vs. Extended ACL:** Standard checks **Source IP only**; Extended checks Source IP, Destination IP, Protocol, and Ports.
* **DAI Prerequisite:** Dynamic ARP Inspection requires **DHCP Snooping** to be enabled first.
* **802.1X AAA Protocol:** Uses **RADIUS** *(not TACACS+)* between the switch and AAA server.
* **`Cat5e` Speed:** Supports **`1 Gbps`** *(not `100 Mbps`)*.
* **Subnetting `15` Hosts:** Requires a **`/27`** mask *(a `/28` provides only `14` usable host IPs)*.
* **TACACS+ vs. RADIUS Transport:** `TACACS+` uses **TCP (`49`)**; `RADIUS` uses **UDP (`1812/1813`)**.
* **GRE Security:** `GRE` provides **no encryption** *(must combine with IPsec for encryption)*.
* **SDN Fail Modes:** **Fail-secure** drops unknown packets when the controller disconnects; **fail-standalone** falls back to standard L2/L3 switching.
* **Mininet Type:** Mininet is an **emulator**, *not* a simulator.
* **IEEE 802.1 Standards:** `802.1D` = STP | `802.1w` = RSTP | `802.1s` = MSTP | `802.1Q` = VLAN Tagging | `802.1X` = Port-Based NAC.
