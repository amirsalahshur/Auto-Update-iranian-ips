# ============================================
# Iranian IP Address List for MikroTik
# ============================================
# Repository: https://github.com/amirsalahshur/update-iranian-ips
# Last Updated: 2025-10-25
#
# This file contains Iranian IP address ranges for use with MikroTik RouterOS
# to enable split tunneling (Iranian IPs direct, foreign IPs via VPN)
#
# Format: MikroTik RouterOS Script (.rsc)
# Compatible with: RouterOS 6.x and 7.x
#
# Usage:
# 1. Import this file: /import iranian-ips.rsc
# 2. Verify: /ip firewall address-list print where list=Iranian-IPs
#
# ============================================

/ip firewall address-list

# ============================================
# Major Iranian ISPs
# ============================================

# TCI (Telecommunication Company of Iran)
add address=2.144.0.0/13 list=Iranian-IPs comment="TCI"
add address=5.22.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.23.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.52.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.53.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.61.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.62.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.63.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.106.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.112.0.0/13 list=Iranian-IPs comment="TCI"
add address=5.120.0.0/14 list=Iranian-IPs comment="TCI"
add address=5.124.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.125.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.126.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.127.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.134.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.144.0.0/15 list=Iranian-IPs comment="TCI"
add address=5.146.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.200.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.201.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.202.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.208.0.0/15 list=Iranian-IPs comment="TCI"
add address=5.213.0.0/16 list=Iranian-IPs comment="TCI"
add address=5.232.0.0/13 list=Iranian-IPs comment="TCI"
add address=31.2.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.7.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.14.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.24.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.25.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.40.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.41.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.56.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.130.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.170.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.171.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.184.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.192.0.0/16 list=Iranian-IPs comment="TCI"
add address=31.193.0.0/16 list=Iranian-IPs comment="TCI"

# Irancell (Mobile)
add address=37.32.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.98.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.130.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.131.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.143.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.152.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.153.0.0/16 list=Iranian-IPs comment="Irancell"
add address=37.156.0.0/16 list=Iranian-IPs comment="Irancell"

# Rightel (Mobile)
add address=37.228.0.0/16 list=Iranian-IPs comment="Rightel"
add address=37.232.0.0/16 list=Iranian-IPs comment="Rightel"
add address=46.21.0.0/16 list=Iranian-IPs comment="Rightel"
add address=46.104.0.0/16 list=Iranian-IPs comment="Rightel"

# MCI (Hamrah Aval - Mobile)
add address=78.38.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.39.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.109.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.110.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.111.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.154.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.155.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.156.0.0/16 list=Iranian-IPs comment="MCI"
add address=78.157.0.0/16 list=Iranian-IPs comment="MCI"

# Shatel
add address=79.127.0.0/16 list=Iranian-IPs comment="Shatel"
add address=79.132.0.0/16 list=Iranian-IPs comment="Shatel"
add address=79.133.0.0/16 list=Iranian-IPs comment="Shatel"
add address=79.134.0.0/16 list=Iranian-IPs comment="Shatel"
add address=79.135.0.0/16 list=Iranian-IPs comment="Shatel"
add address=79.175.0.0/16 list=Iranian-IPs comment="Shatel"

# Pars Online
add address=80.66.0.0/16 list=Iranian-IPs comment="ParsOnline"
add address=80.75.0.0/16 list=Iranian-IPs comment="ParsOnline"
add address=80.191.0.0/16 list=Iranian-IPs comment="ParsOnline"
add address=80.242.0.0/16 list=Iranian-IPs comment="ParsOnline"

# Asiatech
add address=80.241.0.0/16 list=Iranian-IPs comment="Asiatech"
add address=80.250.0.0/16 list=Iranian-IPs comment="Asiatech"
add address=81.12.0.0/16 list=Iranian-IPs comment="Asiatech"
add address=81.31.0.0/16 list=Iranian-IPs comment="Asiatech"
add address=81.90.0.0/16 list=Iranian-IPs comment="Asiatech"

# Datak Telecom
add address=82.99.0.0/16 list=Iranian-IPs comment="DatakTelecom"
add address=82.115.0.0/16 list=Iranian-IPs comment="DatakTelecom"

# Respina
add address=83.120.0.0/16 list=Iranian-IPs comment="Respina"
add address=83.123.0.0/16 list=Iranian-IPs comment="Respina"

# AndishehSabz
add address=85.9.0.0/16 list=Iranian-IPs comment="AndishehSabz"
add address=85.15.0.0/16 list=Iranian-IPs comment="AndishehSabz"

# IranServer
add address=85.133.0.0/16 list=Iranian-IPs comment="IranServer"
add address=85.185.0.0/16 list=Iranian-IPs comment="IranServer"

# IRANET
add address=85.198.0.0/16 list=Iranian-IPs comment="IRANET"
add address=85.204.0.0/16 list=Iranian-IPs comment="IRANET"

# Sepanta
add address=86.57.0.0/16 list=Iranian-IPs comment="Sepanta"
add address=86.104.0.0/16 list=Iranian-IPs comment="Sepanta"

# Afranet
add address=87.107.0.0/16 list=Iranian-IPs comment="Afranet"
add address=87.248.0.0/16 list=Iranian-IPs comment="Afranet"

# Neda Rayaneh
add address=88.80.0.0/16 list=Iranian-IPs comment="NedaRayaneh"
add address=88.135.0.0/16 list=Iranian-IPs comment="NedaRayaneh"

# Fanavari (FCP)
add address=89.32.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.33.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.34.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.35.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.36.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.37.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.38.0.0/16 list=Iranian-IPs comment="FCP"
add address=89.39.0.0/16 list=Iranian-IPs comment="FCP"

# Rayaneh Gostar
add address=89.144.0.0/16 list=Iranian-IPs comment="RayanehGostar"
add address=89.165.0.0/16 list=Iranian-IPs comment="RayanehGostar"

# Samantel
add address=91.92.0.0/16 list=Iranian-IPs comment="Samantel"
add address=91.98.0.0/16 list=Iranian-IPs comment="Samantel"
add address=91.99.0.0/16 list=Iranian-IPs comment="Samantel"
add address=91.109.0.0/16 list=Iranian-IPs comment="Samantel"

# Pishgaman Toseeh Ertebatat
add address=91.147.0.0/16 list=Iranian-IPs comment="PTE"
add address=91.185.0.0/16 list=Iranian-IPs comment="PTE"

# DOT (Datak Online Services)
add address=91.193.0.0/16 list=Iranian-IPs comment="DOT"
add address=91.198.0.0/16 list=Iranian-IPs comment="DOT"

# Shabtabnegar
add address=91.220.0.0/16 list=Iranian-IPs comment="Shabtabnegar"
add address=91.221.0.0/16 list=Iranian-IPs comment="Shabtabnegar"

# ============================================
# Additional Networks
# ============================================

# Research and Education Networks
add address=92.38.0.0/16 list=Iranian-IPs comment="Academic"
add address=92.119.0.0/16 list=Iranian-IPs comment="Academic"

# Government and Infrastructure
add address=93.88.0.0/16 list=Iranian-IPs comment="Infrastructure"
add address=93.110.0.0/16 list=Iranian-IPs comment="Infrastructure"
add address=93.113.0.0/16 list=Iranian-IPs comment="Infrastructure"

# Additional ISPs
add address=94.184.0.0/16 list=Iranian-IPs comment="Various-ISPs"
add address=94.232.0.0/16 list=Iranian-IPs comment="Various-ISPs"
add address=95.38.0.0/16 list=Iranian-IPs comment="Various-ISPs"
add address=95.80.0.0/16 list=Iranian-IPs comment="Various-ISPs"
add address=95.216.0.0/16 list=Iranian-IPs comment="Various-ISPs"

# ============================================
# IPv6 Support (if needed)
# ============================================

# Uncomment these if you need IPv6 support:
# add address=2a02:2e00::/29 list=Iranian-IPs comment="TCI-IPv6"
# add address=2a03:6f00::/29 list=Iranian-IPs comment="Shatel-IPv6"
# add address=2a0d:5600::/29 list=Iranian-IPs comment="Asiatech-IPv6"

# ============================================
# Notes
# ============================================
#
# This is a sample file with common Iranian IP ranges.
# For a complete and up-to-date list, the auto-update script
# will download the latest version from the GitHub repository.
#
# To manually add an IP range:
# /ip firewall address-list add address=X.X.X.X/XX list=Iranian-IPs comment="Custom"
#
# To remove an IP range:
# /ip firewall address-list remove [find address="X.X.X.X/XX"]
#
# To view all entries:
# /ip firewall address-list print where list=Iranian-IPs
#
# To count entries:
# /ip firewall address-list print count-only where list=Iranian-IPs
#
# ============================================
# Maintenance
# ============================================
#
# This list should be updated regularly as IP allocations change.
# Use the auto-update script to keep it current:
# /system script run update-iranian-ips
#
# ============================================
