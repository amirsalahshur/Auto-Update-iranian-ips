# Configuration Examples

This document provides various configuration scenarios and examples for different use cases.

## Table of Contents

1. [Basic Split Tunneling](#basic-split-tunneling)
2. [Multiple VPN Providers](#multiple-vpn-providers)
3. [Per-Device Routing](#per-device-routing)
4. [Custom IP Lists](#custom-ip-lists)
5. [Port Forwarding](#port-forwarding)
6. [QoS and Traffic Shaping](#qos-and-traffic-shaping)

---

## Basic Split Tunneling

This is the standard configuration covered in the installation guide.

```routeros
# Mangle rules for split tunneling
/ip firewall mangle
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"

# Routes
/ip route
add dst-address=0.0.0.0/0 gateway=wireguard1 routing-table=via-wireguard
add dst-address=0.0.0.0/0 gateway=YOUR_ISP_GATEWAY routing-table=main
```

---

## Multiple VPN Providers

If you want to use different VPN providers for different purposes:

### Scenario: Two WireGuard Tunnels

- `wireguard1` - For general foreign traffic
- `wireguard2` - For specific services (streaming, etc.)

```routeros
# Create two routing tables
/routing table
add fib name=via-wireguard1 comment="Primary VPN"
add fib name=via-wireguard2 comment="Secondary VPN"

# Create address list for secondary VPN
/ip firewall address-list
add address=netflix.com list=streaming-sites
add address=hulu.com list=streaming-sites
add address=disneyplus.com list=streaming-sites

# Mangle rules
/ip firewall mangle
# Iranian IPs - Direct
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

# Streaming sites - Secondary VPN
add action=mark-routing chain=prerouting dst-address-list=streaming-sites \
    new-routing-mark=via-wireguard2 src-address=192.168.88.0/24 \
    passthrough=no comment="Route streaming through secondary VPN"

# Everything else - Primary VPN
add action=mark-routing chain=prerouting new-routing-mark=via-wireguard1 \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through primary VPN"

# Routes
/ip route
add dst-address=0.0.0.0/0 gateway=wireguard1 routing-table=via-wireguard1
add dst-address=0.0.0.0/0 gateway=wireguard2 routing-table=via-wireguard2
add dst-address=0.0.0.0/0 gateway=YOUR_ISP_GATEWAY routing-table=main

# NAT
/ip firewall nat
add action=masquerade chain=srcnat out-interface=wireguard1
add action=masquerade chain=srcnat out-interface=wireguard2
add action=masquerade chain=srcnat out-interface-list=WAN
```

---

## Per-Device Routing

Route specific devices through VPN while others go direct.

### Scenario: Work Computer Always Through VPN

```routeros
# Assign static IP to work computer: 192.168.88.50

# Mangle rules
/ip firewall mangle
# Work computer - Always through VPN (even Iranian sites)
add action=mark-routing chain=prerouting src-address=192.168.88.50 \
    new-routing-mark=via-wireguard passthrough=no \
    comment="Work computer always through VPN"

# Other devices - Split tunnel
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"
```

### Scenario: Guest Network Direct (No VPN)

```routeros
# Guest network: 192.168.99.0/24

# Mangle rules
/ip firewall mangle
# Guest network - Always direct (no VPN)
add action=accept chain=prerouting src-address=192.168.99.0/24 \
    comment="Guest network - Direct only"

# Main network - Split tunnel
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"

# NAT (guest network doesn't use VPN NAT)
/ip firewall nat
add action=masquerade chain=srcnat src-address=192.168.99.0/24 \
    out-interface-list=WAN comment="Guest direct NAT"
add action=masquerade chain=srcnat out-interface=wireguard1 \
    comment="VPN NAT"
add action=masquerade chain=srcnat out-interface-list=WAN \
    comment="Direct NAT"
```

---

## Custom IP Lists

Add custom IP ranges to control routing.

### Scenario: Always Route Specific Sites Direct

```routeros
# Create custom list for sites that should never use VPN
/ip firewall address-list
add address=banking-site.ir list=always-direct
add address=government-site.ir list=always-direct
add address=university-site.ir list=always-direct

# Mangle rules
/ip firewall mangle
# Custom direct list - highest priority
add action=accept chain=prerouting dst-address-list=always-direct \
    src-address=192.168.88.0/24 \
    comment="Always direct - Custom list"

# Iranian IPs - Direct
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

# Everything else - VPN
add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"
```

### Scenario: Force Specific Foreign Sites Direct

Useful for sites that block VPN IPs:

```routeros
# Create list for foreign sites that should go direct
/ip firewall address-list
add address=netflix.com list=vpn-blocked-sites
add address=hulu.com list=vpn-blocked-sites

# Mangle rules
/ip firewall mangle
# VPN-blocked sites - Direct
add action=accept chain=prerouting dst-address-list=vpn-blocked-sites \
    src-address=192.168.88.0/24 \
    comment="Direct for VPN-blocked sites"

# Iranian IPs - Direct
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

# Everything else - VPN
add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"
```

---

## Port Forwarding

Forward ports from WAN to internal servers.

### Scenario: Web Server Behind Router

```routeros
# Port forward HTTP/HTTPS to internal server
/ip firewall nat
add action=dst-nat chain=dstnat dst-port=80 in-interface-list=WAN \
    protocol=tcp to-addresses=192.168.88.100 to-ports=80 \
    comment="HTTP to web server"

add action=dst-nat chain=dstnat dst-port=443 in-interface-list=WAN \
    protocol=tcp to-addresses=192.168.88.100 to-ports=443 \
    comment="HTTPS to web server"

# Allow forwarded traffic through firewall
/ip firewall filter
add action=accept chain=forward connection-nat-state=dstnat \
    in-interface-list=WAN comment="Allow port forwarded traffic" \
    place-before=[find comment="Drop WAN to LAN (not port forwarded)"]
```

---

## QoS and Traffic Shaping

Prioritize or limit certain types of traffic.

### Scenario: Prioritize Gaming Traffic Through VPN

```routeros
# Mark gaming traffic
/ip firewall mangle
add action=mark-packet chain=prerouting dst-port=3074,3478-3479 \
    new-packet-mark=gaming-traffic protocol=udp \
    comment="Mark Xbox Live traffic"

add action=mark-packet chain=prerouting dst-port=27015-27030,27036-27037 \
    new-packet-mark=gaming-traffic protocol=udp \
    comment="Mark Steam traffic"

# Create queue for gaming traffic
/queue simple
add max-limit=100M/100M name=gaming-priority packet-marks=gaming-traffic \
    priority=1/1 target=192.168.88.0/24
```

### Scenario: Limit Torrent Traffic

```routeros
# Mark torrent traffic
/ip firewall mangle
add action=mark-connection chain=prerouting dst-port=6881-6889 \
    new-connection-mark=torrent-conn protocol=tcp \
    comment="Mark torrent connections"

add action=mark-packet chain=prerouting connection-mark=torrent-conn \
    new-packet-mark=torrent-traffic comment="Mark torrent packets"

# Limit torrent traffic
/queue simple
add max-limit=5M/5M name=torrent-limit packet-marks=torrent-traffic \
    priority=8/8 target=192.168.88.0/24
```

---

## Load Balancing

Use multiple WAN connections or VPN tunnels.

### Scenario: Failover Between Two VPN Tunnels

```routeros
# Two WireGuard tunnels for redundancy
/ip route
add dst-address=0.0.0.0/0 gateway=wireguard1 distance=1 \
    routing-table=via-wireguard comment="Primary VPN"

add dst-address=0.0.0.0/0 gateway=wireguard2 distance=2 \
    routing-table=via-wireguard comment="Backup VPN - higher distance"

# Monitor primary tunnel
/tool netwatch
add host=10.0.0.1 interval=10s up-script={
    /ip route enable [find comment="Primary VPN"]
} down-script={
    /ip route disable [find comment="Primary VPN"]
}
```

---

## Advanced Firewall Examples

### Block Ads at Router Level

```routeros
# Create address list of ad servers
/ip firewall address-list
add address=ads.google.com list=ads
add address=doubleclick.net list=ads
add address=googlesyndication.com list=ads

# Block ad traffic
/ip firewall filter
add action=reject chain=forward dst-address-list=ads \
    reject-with=icmp-network-unreachable comment="Block ads"
```

### Time-Based Rules

```routeros
# Block social media during work hours (9 AM - 5 PM)
/ip firewall filter
add action=reject chain=forward dst-address-list=social-media \
    reject-with=icmp-network-unreachable \
    time=9h-17h,mon,tue,wed,thu,fri \
    comment="Block social media during work hours"
```

---

## Logging and Monitoring

### Log VPN Traffic

```routeros
# Log all traffic through VPN
/ip firewall mangle
add action=log chain=prerouting log-prefix="VPN-Traffic: " \
    new-routing-mark=via-wireguard passthrough=yes \
    src-address=192.168.88.0/24
```

### Monitor Specific Devices

```routeros
# Log traffic from specific device
/ip firewall filter
add action=log chain=forward log-prefix="Device-Monitor: " \
    src-address=192.168.88.50
```

---

## Performance Optimization

### Enable Connection Tracking Offload

```routeros
# For high-performance routers with hardware offload
/ip firewall connection tracking
set tcp-established-timeout=1d tcp-syn-sent-timeout=30s \
    tcp-time-wait-timeout=10s udp-timeout=30s \
    icmp-timeout=10s generic-timeout=10m
```

### Optimize FastTrack

```routeros
# Ensure FastTrack is optimized
/ip firewall filter
add action=fasttrack-connection chain=forward \
    connection-state=established,related hw-offload=yes \
    comment="FastTrack - optimized" place-before=0
```

---

## Backup and Restore

### Automated Backup

```routeros
# Daily backup script
/system script
add name=daily-backup source={
    /system backup save name=("backup-" . [/system clock get date])
    :delay 5s
    /file set [find name~"backup-"] comment="Auto backup"
}

# Schedule daily backup
/system scheduler
add name=daily-backup-schedule on-event="/system script run daily-backup" \
    start-time=04:00:00 interval=1d
```

---

## Security Hardening

### Disable Unnecessary Services

```routeros
/ip service
disable telnet,ftp,www,api,api-ssl

# Keep only SSH and Winbox
enable ssh,winbox
```

### Change Default Ports

```routeros
/ip service
set ssh port=2222
set winbox port=8291
```

### Enable Firewall Logging

```routeros
/ip firewall filter
add action=log chain=input log-prefix="INPUT-ATTACK: " \
    place-before=[find comment="Drop all other input"]
```

---

## Contributing

Have a useful configuration example? Please contribute by:
1. Forking the repository
2. Adding your example to this file
3. Submitting a pull request

---

**Examples maintained by the community**  
**Repository:** https://github.com/amirsalahshur/update-iranian-ips
