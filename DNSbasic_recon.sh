#!/bin/bash

# A script to automate DNS record lookups on a target.
#
# Usage:
#   ./DNSbasic_recon.sh <target>
#
# Arguments:
#   <target>: The domain name or IP address to query (e.g., example.com).
#
# This script uses nslookup to find the nameserver and dig to perform a
# series of DNS record lookups, providing summarized results for each.

# Check if a target was provided as an argument.
if [ -z "$1" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

TARGET="$1"

echo "Starting DNS reconnaissance for $TARGET..."
echo ""

# --- Step 1: Find the authoritative nameserver using nslookup ---
echo "Step 1: Finding the authoritative nameserver for $TARGET..."
# Use nslookup to find the name server and extract the address from the output.
# The `server` part of the output contains the nameserver information.
NS_SERVER=$(nslookup -type=ns "$TARGET" | grep "nameserver" | awk '{print $2}' | head -n 1)

if [ -z "$NS_SERVER" ]; then
    echo "Could not find an authoritative nameserver for $TARGET. Exiting."
    exit 1
fi

echo "Authoritative nameserver found: $NS_SERVER"
echo ""

# --- Step 2: Perform various DNS record lookups using dig ---

# A (Address) Record Lookup
echo "Step 2.1: Looking up A records (IPv4 addresses)..."
dig @$NS_SERVER "$TARGET" A +short
echo ""

# AAAA (IPv6 Address) Record Lookup
echo "Step 2.2: Looking up AAAA records (IPv6 addresses)..."
dig @$NS_SERVER "$TARGET" AAAA +short
echo ""

# MX (Mail Exchanger) Record Lookup
echo "Step 2.3: Looking up MX records (mail servers)..."
dig @$NS_SERVER "$TARGET" MX +short
echo ""

# CNAME (Canonical Name) Record Lookup
echo "Step 2.4: Looking up CNAME records (aliases)..."
dig @$NS_SERVER "$TARGET" CNAME +short
echo ""

# TXT (Text) Record Lookup
echo "Step 2.5: Looking up TXT records (text data)..."
dig @$NS_SERVER "$TARGET" TXT +short
echo ""

# SPF (Sender Policy Framework) Record Lookup
echo "Step 2.6: Looking up SPF records..."
dig @$NS_SERVER "$TARGET" SPF +short
echo ""

# SOA (Start of Authority) Record Lookup
echo "Step 2.7: Looking up SOA records..."
dig @$NS_SERVER "$TARGET" SOA +short
echo ""

echo "DNS reconnaissance completed."
