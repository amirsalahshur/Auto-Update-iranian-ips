# Complete Installation Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Pre-Installation Checklist](#pre-installation-checklist)
3. [Backup Your Configuration](#backup-your-configuration)
4. [Step-by-Step Installation](#step-by-step-installation)
5. [Post-Installation Testing](#post-installation-testing)
6. [Setting Up Automatic Updates](#setting-up-automatic-updates)

---

## Prerequisites

Before you begin, ensure you have:

### Hardware Requirements
- MikroTik router (any model with RouterOS 7.x+)
- At least 10MB free storage space
- Minimum 256MB RAM (512MB+ recommended)

### Software Requirements
- RouterOS version 7.x or higher (for WireGuard support)
- Working WireGuard VPN configuration
- Internet access from the router

### Network Requirements
- Access to router via Winbox, WebFig, or SSH
- Admin credentials for the router
- Active internet connection

### Knowledge Requirements
- Basic understanding of MikroTik RouterOS
- Familiarity with command-line interface
- Basic networking knowledge

---

## Pre-Installation Checklist

Run these commands to verify your router is ready:

### 1. Check RouterOS Version

```routeros
/system resource print
```

**Expected output:**
- `version: 7.xx` (must be 7.0 or higher)

If your version is below 7.0, upgrade RouterOS first.

### 2. Check Available Storage

```routeros
/system resource print
```

**Look for:**
- `free-hdd-space:` should be at least 10MB

### 3. Check Internet Connectivity

```routeros
/tool fetch url="https://www.google.com" mode=https
```

**Expected output:**
- `status: finished` 

### 4. Verify WireGuard Configuration

```routeros
/interface wireguard print
/interface wireguard peers print
```

**Expected output:**
- WireGuard interface should exist
- At least one peer should be configured
- Peer status should show `current-endpoint-address` and `last-handshake`

### 5. Note Your Interface Names

```routeros
/interface print
```

**Write down:**
- WAN interface name (usually `ether1`)
- LAN bridge name (usually `bridge`)
- WireGuard interface name (usually `wireguard1`)

### 6. Note Your LAN Subnet

```routeros
/ip address print
```

**Write down your LAN subnet (usually `192.168.88.0/24`)**

---

## Backup Your Configuration

**CRITICAL: Always backup before making changes!**

### Method 1: Binary Backup (Recommended)

```routeros
/system backup save name=before-split-tunnel
```

### Method 2: Text Export

```routeros
/export file=config-backup-text
```

### Verify Backups Were Created

```routeros
/file print
```

You should see both backup files listed.

### Download Backups (Optional but Recommended)

Using Winbox or WebFig, download the backup files to your computer.

---

## Step-by-Step Installation

### STEP 1: Configure Interface Lists

**Purpose:** Organize interfaces into logical groups for firewall rules.

```routeros
# Create interface lists
/interface list
add name=WAN comment="Internet facing interfaces"
add name=LAN comment="Local network interfaces"

# Add interfaces to lists
# REPLACE 'ether1' with your actual WAN interface name
# REPLACE 'bridge' with your actual LAN bridge name
# REPLACE 'wireguard1' with your actual WireGuard interface name

/interface list member
add interface=ether1 list=WAN comment="Main WAN"
add interface=bridge list=LAN comment="LAN Bridge"
add interface=wireguard1 list=LAN comment="WireGuard VPN"
```

**Verify:**
```routeros
/interface list member print
```

---

### STEP 2: Configure Firewall Rules

#### INPUT Chain Rules

**Purpose:** Control traffic destined to the router itself.

```routeros
/ip firewall filter

# Accept established/related connections
add action=accept chain=input connection-state=established,related,untracked \
    comment="Accept established/related/untracked"

# Drop invalid connections
add action=drop chain=input connection-state=invalid \
    comment="Drop invalid connections"

# Accept ICMP (ping)
add action=accept chain=input protocol=icmp \
    comment="Accept ICMP"

# Accept from LAN
add action=accept chain=input in-interface-list=LAN \
    comment="Accept from LAN"

# Accept WireGuard port
# CHANGE 51820 if you use a different port
add action=accept chain=input protocol=udp dst-port=51820 \
    comment="Accept WireGuard"

# Accept localhost
add action=accept chain=input dst-address=127.0.0.1 \
    comment="Accept localhost"

# Drop all other input
add action=drop chain=input \
    comment="Drop all other input"
```

#### FORWARD Chain Rules

**Purpose:** Control traffic passing through the router.

```routeros
# Accept established/related connections
add action=accept chain=forward connection-state=established,related,untracked \
    comment="Accept established/related/untracked"

# Drop invalid connections
add action=drop chain=forward connection-state=invalid \
    comment="Drop invalid connections"

# FastTrack for performance
add action=fasttrack-connection chain=forward \
    connection-state=established,related hw-offload=yes \
    comment="FastTrack established connections"

# Accept LAN to WAN
add action=accept chain=forward in-interface-list=LAN out-interface-list=WAN \
    comment="Accept LAN to WAN"

# Accept LAN to LAN (including WireGuard)
add action=accept chain=forward in-interface-list=LAN out-interface-list=LAN \
    comment="Accept LAN to LAN"

# Drop WAN to LAN (except port forwarded)
add action=drop chain=forward connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN \
    comment="Drop WAN to LAN (not port forwarded)"
```

**Verify:**
```routeros
/ip firewall filter print
```

---

### STEP 3: Configure NAT

**Purpose:** Enable internet access for LAN clients.

```routeros
/ip firewall nat

# NAT for WireGuard traffic
# REPLACE 'wireguard1' with your actual WireGuard interface name
add action=masquerade chain=srcnat out-interface=wireguard1 \
    comment="Masquerade via WireGuard"

# NAT for direct traffic
add action=masquerade chain=srcnat out-interface-list=WAN \
    comment="Masquerade direct traffic"
```

**Verify:**
```routeros
/ip firewall nat print
```

---

### STEP 4: Create Routing Table

**Purpose:** Separate routing table for VPN traffic.

```routeros
/routing table
add fib name=via-wireguard comment="Routing table for WireGuard"
```

**Verify:**
```routeros
/routing table print
```

---

### STEP 5: Configure Routes

**Purpose:** Define how traffic should be routed.

```routeros
# First, check your current default gateway
/ip route print where dst-address=0.0.0.0/0

# Add route for WireGuard traffic
# REPLACE 'wireguard1' with your actual WireGuard interface name
/ip route
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=wireguard1 \
    routing-table=via-wireguard comment="Foreign traffic via WireGuard"

# Your existing default route should remain for direct traffic
# If you don't have a default route, add it:
# REPLACE 'YOUR_GATEWAY' with your actual WAN gateway IP
# add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=YOUR_GATEWAY \
#     routing-table=main comment="Iranian traffic direct"
```

**Verify:**
```routeros
/ip route print
```

---

### STEP 6: Configure Mangle Rules (Split Tunneling)

**Purpose:** This is the core logic that decides which traffic goes where.

```routeros
# Remove any existing mangle rules first
/ip firewall mangle remove [find]

# Add split tunneling rules
# REPLACE '192.168.88.0/24' with your actual LAN subnet

/ip firewall mangle

# Rule 1: Iranian IPs go direct (bypass VPN)
add action=accept chain=prerouting dst-address-list=Iranian-IPs \
    src-address=192.168.88.0/24 \
    comment="Direct route for Iranian IPs"

# Rule 2: All other traffic goes through WireGuard
add action=mark-routing chain=prerouting new-routing-mark=via-wireguard \
    src-address=192.168.88.0/24 passthrough=no \
    comment="Route foreign IPs through WireGuard"
```

**Important Notes:**
- The order of these rules is critical
- Rule 1 must come before Rule 2
- `passthrough=no` prevents the packet from being processed by subsequent rules

**Verify:**
```routeros
/ip firewall mangle print
```

---

### STEP 7: Install the Update Script

**Option A: Copy from GitHub**

1. Open the script file from this repository: `update-iranian-ips.rsc`
2. Copy the entire content
3. Paste it into your MikroTik terminal

**Option B: Manual Entry**

Copy the script from the repository and paste it into terminal.

**Verify script was added:**
```routeros
/system script print
```

You should see `update-iranian-ips` in the list.

---

### STEP 8: Run the Update Script

**Run the script to load Iranian IPs:**

```routeros
/system script run update-iranian-ips
```

**Monitor the progress:**
```routeros
/log print where message~"Iranian"
```

**You should see logs like:**
```
Starting Iranian IPs Update
Download completed successfully
Old entries removed successfully
Import completed
Update Completed Successfully!
New IP entries: 5234
```

**Verify IPs were loaded:**
```routeros
/ip firewall address-list print count-only where list=Iranian-IPs
```

Should show a number like 5000+

---

## Post-Installation Testing

### Test 1: Verify Iranian IP Routing (Direct)

```routeros
# Traceroute to an Iranian IP
/tool traceroute 31.2.1.1
```

**Expected result:**
- Should go through your ISP gateway (not WireGuard)
- Fast response time

### Test 2: Verify Foreign IP Routing (VPN)

```routeros
# Traceroute to a foreign IP
/tool traceroute 8.8.8.8
```

**Expected result:**
- Should go through WireGuard interface
- First hop should be WireGuard tunnel

### Test 3: Check Mangle Rule Statistics

```routeros
/ip firewall mangle print stats
```

**Expected result:**
- Both rules should show increasing packet/byte counts as traffic flows

### Test 4: Verify Firewall

```routeros
# Try to ping router from LAN device - should work
# Try to ping router from internet - should be blocked

# Check firewall statistics
/ip firewall filter print stats
```

### Test 5: Real-World Testing

From a computer connected to your MikroTik:

**Test Iranian website:**
```bash
# Should be fast, direct connection
curl -w "Time: %{time_total}s\n" http://31.2.1.1
```

**Test foreign website:**
```bash
# Goes through VPN
curl -w "Time: %{time_total}s\n" http://8.8.8.8
```

**Check your public IP:**
```bash
# For Iranian sites (should show your real ISP IP)
curl http://icanhazip.com

# For foreign sites (should show VPN IP)
# You need to force it to go to a foreign IP
```

---

## Setting Up Automatic Updates

### Option 1: Daily Updates (Recommended)

**Run every day at 3:00 AM:**

```routeros
/system scheduler add name=update-iranian-ips-daily \
    on-event="/system script run update-iranian-ips" \
    start-date=oct/26/2025 \
    start-time=03:00:00 \
    interval=1d \
    comment="Update Iranian IPs daily at 3 AM"
```

### Option 2: Weekly Updates

**Run every Sunday at 2:00 AM:**

```routeros
/system scheduler add name=update-iranian-ips-weekly \
    on-event="/system script run update-iranian-ips" \
    start-date=oct/27/2025 \
    start-time=02:00:00 \
    interval=7d \
    comment="Update Iranian IPs weekly on Sunday"
```

### Option 3: Update on Startup

**Run after every reboot:**

```routeros
/system scheduler add name=update-iranian-ips-startup \
    on-event="/system script run update-iranian-ips" \
    start-time=startup \
    interval=0 \
    comment="Update Iranian IPs after reboot"
```

### Verify Scheduler

```routeros
/system scheduler print detail
```

---

## Configuration Complete! ✅

Your MikroTik router is now configured for intelligent split tunneling with automatic IP updates.

### What You've Accomplished

- ✅ Configured secure firewall rules
- ✅ Set up NAT for both direct and VPN traffic
- ✅ Created routing table for split tunneling
- ✅ Configured mangle rules for traffic classification
- ✅ Installed auto-update script
- ✅ Set up automatic updates

### Next Steps

1. **Monitor the system** for a few days to ensure everything works
2. **Check logs regularly** to verify automatic updates
3. **Test both Iranian and foreign website access**
4. **Keep your RouterOS updated**
5. **Star the GitHub repository** if you find it helpful!

### Need Help?

- Check the [Troubleshooting Guide](troubleshooting.md)
- Open an issue on [GitHub](https://github.com/amirsalahshur/update-iranian-ips/issues)
- Review [MikroTik Wiki](https://wiki.mikrotik.com)

---

## Quick Reference Commands

```routeros
# Check IP list count
/ip firewall address-list print count-only where list=Iranian-IPs

# Run update script manually
/system script run update-iranian-ips

# View update logs
/log print where message~"Iranian"

# Check mangle statistics
/ip firewall mangle print stats

# Check scheduler status
/system scheduler print

# View routing table
/ip route print where routing-table=via-wireguard

# Test connectivity
/tool traceroute 8.8.8.8
/tool traceroute 31.2.1.1
```

---

**Installation guide created by Amir Salahshur**  
**Repository:** https://github.com/amirsalahshur/update-iranian-ips
