# 🌐 FCN — Complete Exam Notes 

**How to use this:** Read each Part once, then re-read only the 🔑 *Must-remember* boxes and the tables. Finish with Part 14 (formulas + traps) and the separate practice MCQ file. Numericals are the easiest marks — memorise the formulas.

**Contents**

| # | Part | # | Part |
| :-- | :-- | :-- | :-- |
| 1 | Network Fundamentals | 8 | Application Layer |
| 2 | OSI & TCP/IP Models | 9 | Cisco Device Basics |
| 3 | Physical Layer | 10 | STP, VLAN, VTP, EtherChannel |
| 4 | Data Link Layer | 11 | Network Security & Cryptography |
| 5 | IP Addressing, Subnetting, ICMP, IPv6, NAT | 12 | WAN & VPN |
| 6 | Routing | 13 | SDN, Virtual Networking, Mininet |
| 7 | Transport Layer (TCP / UDP) | 14 | Formulas, Ports, Standards, MCQ Traps |

---

## Part 1 — Network Fundamentals

### Network types

| Type | Full Form | Range / Example |
| :-- | :-- | :-- |
| **PAN** | Personal Area Network | A few metres (Bluetooth, phone ↔ earbuds) |
| **LAN** | Local Area Network | Building / campus (Ethernet, Wi-Fi) |
| **MAN** | Metropolitan Area Network | City (cable TV network, metro Ethernet) |
| **WAN** | Wide Area Network | Country / world (the Internet is the largest WAN) |

* **Intranet** = private network of one organisation. **Extranet** = intranet shared with selected outsiders. **Internet** = network of networks.
* **Client–Server:** dedicated server provides services. **Peer-to-Peer:** every host is both client and server.

### Topologies

| Topology | Key Facts |
| :-- | :-- |
| **Bus** | One backbone cable + terminators; cheap; a break in the backbone kills the network |
| **Star** | All devices connect to a central hub/switch; easy to manage; **central device failure = whole network down** (most common today) |
| **Ring** | Each node connects to two neighbours; data travels one direction; Token Ring / FDDI |
| **Mesh** | Every device linked to every other: **links = n(n−1)/2**, **ports per device = n−1**; most reliable, most expensive |
| **Tree / Hybrid** | Combination of the above |

### Transmission modes & communication types

* **Simplex:** one direction only (keyboard, TV broadcast). **Half-duplex:** both directions, **one at a time** (walkie-talkie, hub). **Full-duplex:** both **simultaneously** (telephone, switch).
* **Unicast** = one-to-one | **Multicast** = one-to-group | **Broadcast** = one-to-all | **Anycast** = one-to-nearest of a group (IPv6).

### Performance (very common numericals)

| Term | Meaning |
| :-- | :-- |
| **Bandwidth** | Maximum data rate of a link (bits/s) |
| **Throughput** | Actual achieved rate (always ≤ bandwidth) |
| **Latency** | Total time for data to travel source → destination |
| **Jitter** | Variation in delay (hurts voice/video) |

```
Transmission delay (Tt) = Packet length (bits) / Bandwidth (bps)
Propagation delay  (Tp) = Distance / Propagation speed
Total delay             = Tt + Tp + Queuing + Processing
Bandwidth-Delay Product = Bandwidth × Delay      (bits "in the pipe")
```

> **Worked example:** 1000-byte packet (8000 bits), 1 Mbps link → Tt = 8 ms. Distance 2000 km at 2×10⁸ m/s → Tp = 10 ms. Total (ignoring queuing) = **18 ms**.

> 🔑 **Must remember:** Signal speed ≈ 2×10⁸ m/s in cable, 3×10⁸ m/s in air/vacuum. Propagation delay depends on **distance**, transmission delay depends on **packet size and bandwidth**.

---

## Part 2 — OSI & TCP/IP Models

> **Mnemonic (top → bottom):** *All People Seem To Need Data Processing.* **(bottom → top):** *Please Do Not Throw Sausage Pizza Away.*

| Layer | PDU | Job | Protocols / Devices |
| :-- | :-- | :-- | :-- |
| **7 Application** | Data | Network services to the user | HTTP, FTP, SMTP, DNS, DHCP, SNMP, Telnet |
| **6 Presentation** | Data | Translation, encryption, compression | SSL/TLS, JPEG, MPEG, ASCII |
| **5 Session** | Data | Dialog control, sync, checkpoints | NetBIOS, RPC |
| **4 Transport** | **Segment** (TCP) / **Datagram** (UDP) | End-to-end delivery, ports, reliability, flow & congestion control | TCP, UDP |
| **3 Network** | **Packet** | Logical addressing, routing | IP, ICMP, IGMP, ARP*, **Router**, L3 switch |
| **2 Data Link** | **Frame** | Physical addressing, framing, error detection, access control | Ethernet, PPP, HDLC, **Switch**, Bridge, NIC |
| **1 Physical** | **Bits** | Signals, cables, connectors | **Hub**, Repeater, cables, modem |

*ARP is usually placed between Layer 2 and 3.

| TCP/IP Layer | Covers OSI |
| :-- | :-- |
| Application | 7 + 6 + 5 |
| Transport | 4 |
| Internet | 3 |
| Network Access (Link) | 2 + 1 |

* **Encapsulation:** Data → Segment → Packet → Frame → Bits. Each layer **adds a header**; Data Link also adds a **trailer (FCS)**.
* **Data Link sublayers:** **LLC** (802.2) and **MAC**.
* **Gateway** works at **all 7 layers** (protocol conversion).

---

## Part 3 — Physical Layer

### Signals & limits

* **Analog** = continuous; **Digital** = discrete. **Baseband** = digital signal sent directly; **Broadband** = signal modulated onto a carrier.
* **Attenuation** (signal weakens), **Distortion** (shape changes), **Noise** (unwanted signal). Repeaters/amplifiers fix attenuation.

```
Nyquist (noiseless):  Max bit rate = 2 × B × log2(L)       B = bandwidth (Hz), L = signal levels
Shannon (noisy):      Capacity     = B × log2(1 + SNR)      SNR_dB = 10 × log10(SNR)
```

> **Examples:** Nyquist: B = 3000 Hz, 4 levels → 2 × 3000 × 2 = **12,000 bps**. Shannon: B = 3000 Hz, SNR = 30 dB → SNR = 1000 → C = 3000 × log2(1001) ≈ **30 kbps**.

> 🔑 **Must remember:** Noiseless channel → **Nyquist**. Noisy channel → **Shannon**. If both are given, answer is the **smaller** value.

### Line coding

| Scheme | Key Fact |
| :-- | :-- |
| **NRZ-L / NRZ-I** | Simple; long runs of same bit cause loss of synchronisation |
| **RZ** | Returns to zero in every bit; needs more bandwidth |
| **Manchester** | **Transition in the middle of every bit** → self-synchronising; used by **10 Mbps Ethernet**; needs twice the bandwidth of NRZ |
| **Differential Manchester** | Transition in the middle always; bit value decided by presence/absence of a transition at the **start**; used by Token Ring |

### Multiplexing & switching

| Technique | Idea |
| :-- | :-- |
| **FDM** | Different **frequency bands** share a link at the same time (analog); guard bands prevent overlap |
| **TDM** | Users take turns in **time slots** (digital). Synchronous TDM = fixed slots; **Statistical TDM** = slots given only to active users |
| **WDM** | FDM for **light** over fibre (different wavelengths) |

| Switching | How it works |
| :-- | :-- |
| **Circuit switching** | Dedicated path set up first (setup → transfer → teardown); fixed delay; wasteful; used by telephone network |
| **Packet switching – Datagram** | No setup; each packet routed **independently**; may arrive out of order (Internet/IP) |
| **Packet switching – Virtual circuit** | Setup phase, then all packets follow the **same path** (Frame Relay, ATM, MPLS) |
| **Message switching** | Whole message stored & forwarded at each node |

### Transmission media

* **Guided:** Twisted pair (UTP/STP), Coaxial, Optical fibre. **Unguided:** Radio waves, Microwaves, Infrared.
* **Fibre** works by **total internal reflection**; immune to EMI; highest bandwidth. **Single-mode** = laser, long distance; **Multimode** = LED, short distance.

| Cable | Speed | Notes |
| :-- | :-- | :-- |
| Cat3 | 10 Mbps | Old telephone grade |
| Cat5 | 100 Mbps | Fast Ethernet |
| Cat5e | 1 Gbps | Enhanced, less crosstalk |
| Cat6 | 1 Gbps (10 Gbps up to 55 m) | |
| Cat6a | 10 Gbps up to 100 m | |

| Ethernet name | Medium | Max segment |
| :-- | :-- | :-- |
| 10Base5 | Thick coax | 500 m |
| 10Base2 | Thin coax | 185 m |
| 10BaseT | UTP | 100 m |
| 100BaseTX | Cat5 UTP | 100 m |
| 1000BaseT | Cat5e/6 UTP | 100 m |

* **Which cable?** Different devices (PC–Switch, Switch–Router) → **Straight-through**. Same devices (PC–PC, Switch–Switch) → **Crossover**. Console port → **Rollover**. (Modern auto-MDIX ports detect this automatically.)
* **UTP:** cheap, prone to EMI. **STP:** shielded, costlier. Max twisted-pair run = **100 m**, connector **RJ-45**.

---

## Part 4 — Data Link Layer

### 4.1 Framing & error detection

* **Framing:** marks frame start/end (flag bytes, bit stuffing `01111110` for HDLC/PPP, byte stuffing).

| Method | Detects | Remember |
| :-- | :-- | :-- |
| **Single parity bit** | **Odd** number of bit errors only | Even parity: total number of 1s made even |
| **2-D parity** | Better burst coverage | Rows + columns |
| **Checksum** | Internet checksum = 16-bit **1's complement** sum | Used in IP, TCP, UDP, ICMP headers |
| **CRC** | Burst errors very well | Used in Ethernet (32-bit FCS) |

* **CRC rule:** if the generator has degree *n* (n+1 bits), append **n zeros** to data, divide (XOR), append remainder. Receiver divides again; **remainder 0 → no error**.
* **Hamming code (error correction):** `2^r ≥ m + r + 1` (m = data bits, r = check bits). Check bits sit at positions 1, 2, 4, 8… Corrects **single-bit** errors.
  * m = 4 → r = 3 (7,4 code) | m = 7 → r = 4 | m = 11 → r = 4.
* **Hamming distance (dmin):** to **detect** d errors need `dmin ≥ d + 1`; to **correct** t errors need `dmin ≥ 2t + 1`.

### 4.2 Flow control & ARQ (sliding window)

| Protocol | Sender window | Receiver window | Retransmission |
| :-- | :-- | :-- | :-- |
| **Stop-and-Wait** | 1 | 1 | Resend the one frame |
| **Go-Back-N (GBN)** | up to **2^m − 1** | 1 | Resend lost frame **and all after it**; cumulative ACK |
| **Selective Repeat (SR)** | up to **2^(m−1)** | 2^(m−1) | Resend **only** the lost frame |

*(m = bits in the sequence number.)*

```
a = Tp / Tt
Stop-and-Wait efficiency = 1 / (1 + 2a)
Sliding window efficiency = N / (1 + 2a)   (capped at 100%)
```

> **Example:** a = 4 → Stop-and-Wait efficiency = 1/9 ≈ **11.1%**. 3-bit sequence → GBN window **7**, SR window **4**.

* **Piggybacking:** ACK carried inside a data frame going the other way.

### 4.3 Media access control (MAC)

| Protocol | Key Facts |
| :-- | :-- |
| **Pure ALOHA** | Send anytime; vulnerable time = **2T**; max efficiency **18.4%** (1/2e) at G = 0.5; S = G·e^(−2G) |
| **Slotted ALOHA** | Send only at slot start; vulnerable time = **T**; max efficiency **36.8%** (1/e) at G = 1; S = G·e^(−G) |
| **CSMA** | Listen before sending. Types: **1-persistent, non-persistent, p-persistent** |
| **CSMA/CD** | Wired Ethernet: listen, send, **detect collision**, jam, **binary exponential backoff**, retry |
| **CSMA/CA** | Wireless (802.11): avoid collisions using waiting, ACKs, optional **RTS/CTS** |
| **Controlled access** | Reservation, **Polling**, **Token passing** |
| **Channelisation** | FDMA, TDMA, CDMA |

> 🔑 **CSMA/CD rule:** transmission time must be ≥ 2 × propagation delay, so **min frame size = 2 × Tp × Bandwidth**. This is why Ethernet has a 64-byte minimum.

* **Hidden terminal problem** (two stations can't hear each other but both reach the AP) → solved by **RTS/CTS**.

### 4.4 Ethernet (IEEE 802.3)

```
| Preamble 7B | SFD 1B | Dest MAC 6B | Src MAC 6B | Type/Length 2B | Data 46–1500B | FCS 4B |
```

* **MAC address:** 48 bits (12 hex digits); first 24 bits = **OUI** (vendor). Broadcast = `FF:FF:FF:FF:FF:FF`. IPv4 multicast MACs start with `01:00:5E`.
* **Frame size:** min **64 B**, max **1518 B** (payload 46–1500). Default **MTU = 1500**.
* Ethernet speeds: Ethernet 10 Mbps, Fast Ethernet 100 Mbps, Gigabit 1000 Mbps.
* **PoE:** 802.3af (≈15.4 W), 802.3at (≈30 W).

| Device | Collision domains | Broadcast domains |
| :-- | :-- | :-- |
| **Hub** (n ports) | **1** | **1** |
| **Switch** (n ports) | **n** (one per port) | **1** (unless VLANs) |
| **Router** (n interfaces) | n | **n** (one per interface) |

### 4.5 Switch operation

* **Learn** (source MAC → port) → **Forward** (known destination) / **Flood** (unknown unicast, broadcast) → **Filter** (same segment).
* MAC table ageing default = **300 s** on Cisco.
* **Switching modes:** **Store-and-forward** (whole frame, checks FCS, safest) | **Cut-through** (forwards after destination MAC, lowest latency, no error check) | **Fragment-free** (reads first 64 B).
* **ARP:** IP → MAC (broadcast request, unicast reply). **RARP:** MAC → IP (obsolete). Gratuitous ARP announces own mapping.

### 4.6 Wireless LAN (IEEE 802.11)

* **AP** + **SSID**. **Infrastructure mode** (via AP) vs **Ad hoc** (direct).

| Standard | Band | Speed | Name |
| :-- | :-- | :-- | :-- |
| 802.11b | 2.4 GHz | 11 Mbps | |
| 802.11a | 5 GHz | 54 Mbps | |
| 802.11g | 2.4 GHz | 54 Mbps | |
| 802.11n | 2.4 + 5 GHz | up to 600 Mbps (MIMO) | Wi-Fi 4 |
| 802.11ac | 5 GHz | — | Wi-Fi 5 |
| 802.11ax | 2.4 + 5 GHz | — | Wi-Fi 6 |

* **Non-overlapping channels (2.4 GHz):** **1, 6, 11**.
* **Wi-Fi security (weak → strong):** WEP (RC4, broken) → WPA (TKIP) → **WPA2 (AES-CCMP)** → **WPA3 (SAE)**.

---

## Part 5 — IP Addressing, Subnetting, ICMP, NAT, IPv6

### 5.1 IPv4 basics

* **32 bits**, written in dotted decimal. **IP is connectionless, best-effort, unreliable** (reliability comes from TCP).

| Class | First octet | First bits | Default mask | Hosts/net |
| :-- | :-- | :-- | :-- | :-- |
| **A** | 1 – 126 | 0 | /8 (255.0.0.0) | 16,777,214 |
| **B** | 128 – 191 | 10 | /16 (255.255.0.0) | 65,534 |
| **C** | 192 – 223 | 110 | /24 (255.255.255.0) | 254 |
| **D** | 224 – 239 | 1110 | — | Multicast |
| **E** | 240 – 255 | 1111 | — | Experimental |

* **127.0.0.0/8** = loopback (127.0.0.1) | **169.254.0.0/16** = APIPA | **0.0.0.0** = "this host"/default route | **255.255.255.255** = limited broadcast.
* **Private (RFC 1918):** `10.0.0.0/8`, `172.16.0.0/12` (172.16 – 172.31), `192.168.0.0/16`.
* **Network address** = IP AND mask. **Broadcast** = all host bits 1.

### 5.2 IPv4 header

| Field | Size | Note |
| :-- | :-- | :-- |
| Version | 4 bits | = 4 |
| **IHL** | 4 bits | Header length in **4-byte words** (min 5 = 20 B, max 15 = 60 B) |
| Total Length | 16 bits | Max **65,535 B** |
| Identification, Flags (DF, MF), **Fragment Offset (13 bits, in 8-byte units)** | | Fragmentation |
| **TTL** | 8 bits | −1 at each router; 0 → discard + ICMP Time Exceeded |
| Protocol | 8 bits | ICMP 1, TCP 6, UDP 17, GRE 47, ESP 50, AH 51, EIGRP 88, OSPF 89 |
| Header Checksum | 16 bits | Header only; recomputed at every router |
| Source / Dest IP | 32 bits each | |

> **Fragmentation example:** 4000-byte datagram (20 B header + 3980 B data), MTU 1500 → data per fragment = 1480 (multiple of 8). Fragments carry **1480, 1480, 1020** B with offsets **0, 185, 370**; MF = 1, 1, 0.

### 5.3 Subnetting — 3 steps

1. Host bits `h` such that **2^h − 2 ≥ hosts needed**.
2. **Prefix = /(32 − h)**.
3. **Block size = 2^h** (subnets start at multiples of the block size).

| Hosts needed | h | Prefix | Mask (last octet) | Block |
| :-- | :-- | :-- | :-- | :-- |
| ≤ 2 | 2 | /30 | .252 | 4 |
| ≤ 6 | 3 | /29 | .248 | 8 |
| ≤ 14 | 4 | /28 | .240 | 16 |
| ≤ 30 | 5 | /27 | .224 | 32 |
| ≤ 62 | 6 | /26 | .192 | 64 |
| ≤ 126 | 7 | /25 | .128 | 128 |

* **Number of subnets = 2^(borrowed bits).** Magic number = **256 − mask octet value**.
* **/31** = point-to-point links (2 hosts, RFC 3021). **/32** = single host route.
* **CIDR** = classless notation (a.b.c.d/x); **supernetting / route aggregation** combines many networks into one prefix.

**Solved examples**

| Question | Answer |
| :-- | :-- |
| `192.168.10.130/26` network? | Block 64 → **192.168.10.128**, hosts .129–.190, broadcast **.191** |
| `10.128.240.50/30` | Block 4 → network **.48**, hosts **.49, .50**, broadcast **.51** |
| `10.0.0.0/22` usable hosts | 2^10 − 2 = **1022** |
| Mask for `/20` | **255.255.240.0** |
| Class B, 500 hosts/subnet | h = 9 → **/23** (255.255.254.0); subnets 152.152.0.0, .2.0, .4.0 … |
| Class C `195.1.1.0`, 12 hosts/subnet | **/28**; first hosts .1, .17, .33, .49 … subnet 10 → **.161** |

**VLSM (always allocate the largest first)** on `192.168.1.0/24`:

| Need | Prefix | Allocated |
| :-- | :-- | :-- |
| 52 hosts | /26 | 192.168.1.0/26 |
| 28 hosts | /27 | 192.168.1.64/27 |
| 15 hosts | /27 (/28 holds only 14) | 192.168.1.96/27 |
| 5 hosts | /29 | 192.168.1.128/29 |

### 5.4 ICMP, IGMP, DHCP, ARP

* **ICMP** reports errors/diagnostics (not for data): Echo Request **8** / Echo Reply **0** (**ping**), Destination Unreachable **3**, Time Exceeded **11** (**traceroute** relies on it by raising TTL 1, 2, 3 …), Redirect **5**.
* **IGMP:** hosts join/leave **multicast** groups.
* **DHCP (UDP 67 server / 68 client)** — **DORA**: Discover (broadcast) → Offer → Request → Acknowledge. A **DHCP relay** (`ip helper-address`) forwards broadcasts to a server on another subnet. Failure → **APIPA 169.254.x.x**.

### 5.5 NAT

* Translates **private ↔ public** IPs; conserves IPv4 addresses.

| Type | Mapping |
| :-- | :-- |
| **Static NAT** | 1 private ↔ 1 public (fixed); for servers |
| **Dynamic NAT** | Private → public from a **pool** |
| **PAT / Overload** | **Many private → 1 public**, told apart by **port numbers** (most common) |

* **Terms:** Inside Local = private IP of inside host | Inside Global = its public IP | Outside Global = real public IP of destination.
* **PAT config:** `ip nat inside` / `ip nat outside` on interfaces → `access-list 1 permit 192.168.1.0 0.0.0.255` → `ip nat inside source list 1 interface g0/1 overload`.
* **Static:** `ip nat inside source static 192.168.1.10 203.0.113.5`. **Verify:** `show ip nat translations`.

### 5.6 IPv6

* **128 bits**, 8 groups of 16-bit hex. **Fixed 40-byte header**, **no broadcast**, **no header checksum**, built-in IPsec support.
* **Shortening:** drop leading zeros; `::` replaces **one** run of zeros — **only once**. `2001:0db8:0000:0000:0000:0000:0000:0001` → `2001:db8::1`.

| Type | Prefix |
| :-- | :-- |
| Global unicast | `2000::/3` |
| **Link-local** | `FE80::/10` |
| Unique local (private) | `FC00::/7` |
| **Multicast** | `FF00::/8` (all-nodes `FF02::1`, all-routers `FF02::2`) |
| Loopback | `::1/128` |

* **LAN subnet = /64.** **NDP (ICMPv6)** replaces ARP: RS, RA, NS, NA. **SLAAC** = host builds own address from RA. **EUI-64:** split MAC, insert `FFFE`, **flip 7th bit**.
* **Config:** `ipv6 unicast-routing`, `ipv6 address 2001:db8:1::1/64`.
* **Transition:** **Dual stack**, **Tunneling**, **Translation (NAT64)**. Routing: RIPng, OSPFv3, EIGRP for IPv6, MP-BGP.

---

## Part 6 — Routing

* **Static** = manual; **Dynamic** = learned via protocols. **Default route:** `ip route 0.0.0.0 0.0.0.0 <next-hop>`. **Floating static** = backup with **higher AD**.

### Administrative Distance (lower wins between protocols)

| Source | AD | Source | AD |
| :-- | :-- | :-- | :-- |
| Connected | **0** | OSPF | **110** |
| Static | **1** | IS-IS | 115 |
| eBGP | **20** | RIP | **120** |
| EIGRP (internal) | **90** | EIGRP (external) | **170** |
| IGRP | 100 | iBGP | **200** |

* **AD** chooses between **different** protocols. **Metric** chooses between routes of the **same** protocol. If prefix lengths differ, **longest prefix match wins first**.

### Distance Vector vs Link State

| | Distance Vector | Link State |
| :-- | :-- | :-- |
| Algorithm | Bellman-Ford | **Dijkstra (SPF)** |
| Knowledge | Neighbours' tables ("routing by rumour") | **Full topology map** |
| Updates | Periodic, whole table | Triggered, only changes (LSAs flooded) |
| Convergence | Slower; **count-to-infinity** problem | Faster |
| Examples | RIP, IGRP, EIGRP (advanced DV) | OSPF, IS-IS |

* **DV loop prevention:** split horizon, route poisoning / poison reverse, holddown timers, triggered updates, maximum hop count.
* **IGP** inside an AS (RIP, OSPF, EIGRP, IS-IS). **EGP** between ASes = **BGP** (path vector).

### Protocol cheat table

| Protocol | Metric | Exam facts |
| :-- | :-- | :-- |
| **RIP** | Hop count | Max **15** (16 = unreachable); update every **30 s**; **UDP 520**. v1 = classful, broadcast; **v2 = classless, multicast 224.0.0.9**, VLSM + authentication |
| **EIGRP** | Bandwidth + Delay | **DUAL**; multicast **224
