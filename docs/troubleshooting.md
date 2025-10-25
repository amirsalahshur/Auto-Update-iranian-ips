# Troubleshooting Guide

## Table of Contents

1. [Common Issues](#common-issues)
2. [Script Issues](#script-issues)
3. [WireGuard Issues](#wireguard-issues)
4. [Routing Issues](#routing-issues)
5. [Firewall Issues](#firewall-issues)
6. [Performance Issues](#performance-issues)
7. [Diagnostic Commands](#diagnostic-commands)

---

## Common Issues

### Issue 1: Script Fails to Download IP List

**Symptoms:**
- Error message: "Failed to download or import Iranian IPs"
- IP count shows 0
- Log shows download errors

**Diagnosis:**

```routeros
# Test basic internet connectivity
/tool fetch url="https://www.google.com" mode=https

# Test GitHub connectivity specifically
/tool fetch url="https://github.com" mode=https

# Test DNS resolution
/ping github.com count=3

# Check available storage
/system resource print
```

**Solutions:**

#### Solution A: DNS Issue

If ping to `github.com` fails:

```routeros
# Check current DNS servers
/ip dns print

# Set Google DNS as backup
/ip dns set servers=8.8.8.8,8.8.4.4

# Test again
/ping github.com count=3
```

#### Solution B: Firewall Blocking

```routeros
# Temporarily disable firewall to test
/ip firewall filter disable [find]

# Try download again
/system script run update-iranian-ips

# Re-enable firewall
/ip firewall filter enable [find]

# If it worked, add specific rule to allow HTTPS
/ip firewall filter
add action=accept chain=output protocol=tcp dst-port=443 \
    comment="Allow HTTPS from router" place-before=0
```

#### Solution C: Certificate Issue

```routeros
# Download and import certificates
/tool fetch url="https://curl.se/ca/cacert.pem" mode=https

# Import certificates
/certificate import file-name=cacert.pem passphrase=""

# Try update again
/system script run update-iranian-ips
```

#### Solution D: Manual Download

```routeros
# Download directly to specific file
/tool fetch url="https://raw.githubusercontent.com/amirsalahshur/update-iranian-ips/main/mikrotik_address_list.rsc" \
    mode=https dst-path=manual-iranian-ips.rsc

# Wait for download
:delay 10s

# Check if file exists
/file print

# Import manually
/import file-name=manual-iranian-ips.rsc

# Verify
/ip firewall address-list print count-only where list=Iranian-IPs
```

---

### Issue 2: No IPs in Address List After Import

**Symptoms:**
- Script runs without errors
- But IP count is still 0
- Log shows "Import completed"

**Diagnosis:**

```routeros
# Check if file was actually downloaded
/file print

# Try to view the file content (first few lines)
/system script run {
    :local content [/file get iranian-ips.rsc contents]
    :put $content
}
```

**Solutions:**

#### Check File Format

The file must follow this exact format:

```routeros
/ip firewall address-list
add address=31.2.0.0/16 list=Iranian-IPs comment="Example"
add address=31.7.0.0/16 list=Iranian-IPs comment="Example"
```

#### Manual Import Test

```routeros
# Create a test file manually
/ip firewall address-list
add address=31.2.0.0/16 list=Iranian-IPs comment="Test Entry"

# Check if it appears
/ip firewall address-list print where list=Iranian-IPs

# If this works, the issue is with the downloaded file format
```

---

### Issue 3: WireGuard Stops Working After Configuration

**Symptoms:**
- Foreign websites not accessible
- Traceroute doesn't go through WireGuard
- WireGuard was working before

**Diagnosis:**

```routeros
# Check WireGuard status
/interface wireguard print
/interface wireguard peers print

# Check if interface is up
/interface print where name~"wireguard"

# Check last handshake
/interface wireguard peers print detail
```

**Solutions:**

#### Solution A: Interface Name Mismatch

```routeros
# Find your actual WireGuard interface name
/interface wireguard print

# Update NAT rule with correct name
/ip firewall nat
set [find comment="Masquerade via WireGuard"] out-interface=YOUR_ACTUAL_WIREGUARD_NAME

# Update route with correct name
/ip route
set [find comment="Foreign traffic via WireGuard"] gateway=YOUR_ACTUAL_WIREGUARD_NAME
```

#### Solution B: Firewall Blocking WireGuard

```routeros
# Check if WireGuard port is open
/ip firewall filter print where dst-port=51820

# If missing, add it
/ip firewall filter
add action=accept chain=input protocol=udp dst-port=51820 \
    comment="Accept WireGuard" place-before=0
```

#### Solution C: Routing Issue

```routeros
# Check routing table
/ip route print where routing-table=via-wireguard

# Check if mark-routing is working
/ip firewall mangle print stats

# Test forced routing
/tool traceroute 8.8.8.8 routing-table=via-wireguard
```

---

### Issue 4: Iranian Websites Go Through VPN

**Symptoms:**
- Iranian sites are slow
- Traceroute to Iranian IPs shows WireGuard
- Should be direct but goes through VPN

**Diagnosis:**

```routeros
# Check if IP is in the list
/ip firewall address-list print where address=31.2.1.1

# Check mangle rule order
/ip firewall mangle print

# Check mangle statistics
/ip firewall mangle print stats
```

**Solutions:**

#### Solution A: IP Not in List

```routeros
# Add the specific IP manually
/ip firewall address-list
add address=31.2.0.0/16 list=Iranian-IPs comment="Manual Entry"

# Or run update script
/system script run update-iranian-ips
```

#### Solution B: Wrong Mangle Rule Order

```routeros
# The Iranian IP rule MUST come FIRST
# Check current order
/ip firewall mangle print

# If order is wrong, move Iranian rule to top
/ip firewall mangle
move [find comment="Direct route for Iranian IPs"] 0
```

#### Solution C: Wrong Source Address

```routeros
# Check your actual LAN subnet
/ip address print

# Update mangle rules with correct subnet
/ip firewall mangle
set [find comment="Direct route for Iranian IPs"] \
    src-address=YOUR_ACTUAL_LAN_SUBNET
set [find comment="Route foreign IPs through WireGuard"] \
    src-address=YOUR_ACTUAL_LAN_SUBNET
```

---

### Issue 5: Router Running Out of Memory

**Symptoms:**
- Script fails with memory error
- Router becomes slow
- Can't add more firewall rules

**Diagnosis:**

```routeros
# Check memory usage
/system resource print

# Check how many IPs are loaded
/ip firewall address-list print count-only where list=Iranian-IPs

# Check total firewall rules
/ip firewall filter print count-only
```

**Solutions:**

#### Solution A: Clear Logs

```routeros
# View log size
/log print

# Reduce log size
/system logging action set memory memory-lines=100

# Clear logs
/log print
# (Logs will be cleared automatically when full)
```

#### Solution B: Remove Duplicate Entries

```routeros
# Check for duplicates
/ip firewall address-list print where list=Iranian-IPs

# Remove duplicates (script does this automatically)
/system script run update-iranian-ips
```

#### Solution C: Optimize Firewall Rules

```routeros
# Remove disabled rules
/ip firewall filter remove [find disabled=yes]
/ip firewall nat remove [find disabled=yes]
/ip firewall mangle remove [find disabled=yes]
```

---

### Issue 6: Scheduler Not Running Automatically

**Symptoms:**
- Manual script execution works
- But automatic updates don't happen
- Scheduler shows enabled but never runs

**Diagnosis:**

```routeros
# Check scheduler status
/system scheduler print detail

# Check if scheduler ran
/log print where message~"scheduler"

# Check system clock
/system clock print
```

**Solutions:**

#### Solution A: Wrong Time/Date

```routeros
# Set correct timezone
/system clock set time-zone-name=Asia/Tehran

# Verify date and time
/system clock print

# Check if NTP is working
/system ntp client print
```

#### Solution B: Scheduler Disabled

```routeros
# Check if scheduler is enabled
/system scheduler print

# Enable if disabled
/system scheduler enable [find name~"iranian"]
```

#### Solution C: Wrong Start Date

```routeros
# Update start date to today or future
/system scheduler set [find name~"iranian"] \
    start-date=oct/26/2025 start-time=03:00:00
```

---

## Script Issues

### Debug Script Execution

**Enable detailed logging:**

```routeros
# View all script-related logs
/log print where topics~"script"

# Clear old logs first
/log print
# (just viewing clears old entries)

# Run script
/system script run update-iranian-ips

# Check logs immediately
/log print where topics~"script"
```

### Script Hangs or Takes Too Long

**Symptoms:**
- Script runs but never completes
- No error messages
- System becomes unresponsive

**Solutions:**

```routeros
# Check if download is stuck
/tool fetch cancel [find]

# Kill any running scripts
/system script job remove [find]

# Check file downloads in progress
/tool fetch print

# Clear stuck files
/file remove [find name~"iranian"]

# Try again with shorter delay
# Edit script and reduce delay times from 5s to 2s
```

---

## WireGuard Issues

### WireGuard Peer Not Connecting

**Diagnosis:**

```routeros
# Check peer status
/interface wireguard peers print detail

# Look for:
# - current-endpoint-address (should be present)
# - last-handshake (should be recent, < 3 minutes)
# - rx/tx (should be increasing)
```

**Solutions:**

```routeros
# Check if endpoint is reachable
/ping YOUR_WIREGUARD_SERVER_IP

# Check allowed IPs
/interface wireguard peers print

# Allowed IPs should include 0.0.0.0/0 for full tunnel
# Or specific subnets for split tunnel

# Force reconnection
/interface wireguard peers set [find] endpoint-address=YOUR_SERVER_IP endpoint-port=51820
```

---

## Routing Issues

### Test Specific Route

```routeros
# Test without routing mark (normal traffic)
/tool traceroute 8.8.8.8

# Test with VPN routing mark
/tool traceroute 8.8.8.8 routing-table=via-wireguard

# Test to Iranian IP
/tool traceroute 31.2.1.1

# Check active routes
/ip route print where active
```

### Route Not Working

```routeros
# Check if route is active
/ip route print where routing-table=via-wireguard

# Check gateway status
/interface print where name~"wireguard"

# Distance should be 1 for primary route
# If route doesn't appear as active, check:
# 1. Gateway interface is up
# 2. No conflicting routes with lower distance
```

---

## Firewall Issues

### Traffic Being Blocked

**Diagnosis:**

```routeros
# Add logging to firewall
/ip firewall filter
add action=log chain=input log-prefix="INPUT-DROP: " place-before=[find comment="Drop all other input"]
add action=log chain=forward log-prefix="FORWARD-DROP: " place-before=[find comment="Drop all other forward"]

# Generate traffic and check logs
/log print where message~"DROP"
```

**Solution:**

Add specific accept rules before the drop rules.

### FastTrack Not Working

```routeros
# Check if fasttrack is enabled
/ip firewall filter print where action=fasttrack-connection

# Check if hardware offload is supported
/interface ethernet print

# Check fasttrack statistics
/ip firewall filter print stats where action=fasttrack-connection

# If no packets, fasttrack might not be working
# Remove and re-add the rule
```

---

## Performance Issues

### Slow Performance

**Check CPU usage:**

```routeros
/system resource print
```

**If CPU > 70%:**

```routeros
# Enable fasttrack if not already enabled
/ip firewall filter
add action=fasttrack-connection chain=forward \
    connection-state=established,related hw-offload=yes

# Reduce logging
/system logging set [find] disabled=yes
```

**Check connection count:**

```routeros
# View connection table size
/ip firewall connection print count-only

# If very high (>10000), you may need to:
# 1. Reduce connection timeout
# 2. Upgrade hardware
# 3. Optimize firewall rules
```

---

## Diagnostic Commands

### Complete System Check

```routeros
# System resources
/system resource print

# Disk usage
/file print

# Memory usage by feature
/system resource print

# Active connections
/ip firewall connection print count-only

# CPU load
/system resource cpu print

# Interface statistics
/interface print stats

# Routing table
/ip route print where active

# Firewall statistics
/ip firewall filter print stats
/ip firewall nat print stats
/ip firewall mangle print stats

# Address lists
/ip firewall address-list print count-only where list=Iranian-IPs

# Script status
/system script print
/system scheduler print

# Recent logs
/log print where time>([/system clock get time] - 1h)
```

### Export Current Configuration

```routeros
# Export everything
/export file=current-config

# Export only firewall
/ip firewall export file=firewall-config

# Export only scripts
/system script export file=scripts-config
```

### Reset to Known Good State

If nothing works and you want to start over:

```routeros
# Restore from backup
/system backup load name=before-split-tunnel

# Wait for router to reboot
# Then reconfigure step by step
```

---

## Getting Help

If you've tried all the above and still have issues:

1. **Gather Information:**
   ```routeros
   /export file=full-config
   /log print where topics~"error" file=error-logs
   ```

2. **Open GitHub Issue:**
   - Go to: https://github.com/amirsalahshur/update-iranian-ips/issues
   - Provide:
     - RouterOS version
     - Router model
     - Error messages from logs
     - Configuration export (remove sensitive info)

3. **MikroTik Forum:**
   - Post on: https://forum.mikrotik.com
   - MikroTik community is very helpful

4. **Check Documentation:**
   - MikroTik Wiki: https://wiki.mikrotik.com
   - WireGuard Docs: https://www.wireguard.com

---

## Prevention Tips

1. **Always backup** before making changes
2. **Test changes** in a lab environment first
3. **Document** your configuration
4. **Monitor** logs regularly
5. **Keep RouterOS updated**
6. **Use version control** for configurations

---

**Troubleshooting guide maintained by Amir Salahshur**  
**Repository:** https://github.com/amirsalahshur/update-iranian-ips

If you solved an issue not covered here, please contribute by opening a pull request!
