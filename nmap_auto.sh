#!/bin/bash
# A script to automate a series of Nmap scans for reconnaissance.
# Usage:
#   ./nmap_auto.sh <IP_ADDRESS>
# Make sure to run this script with 'sudo' as Nmap requires it for certain
# operations. Example: sudo ./nmap_auto.sh 192.168.1.1

# Check if an IP address was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Make sure to run this script with sudo for optimal effect."
    exit 1
fi

IP="$1"

echo "Step 1: Running initial full port scan on $IP to find open ports..."
echo "Command: sudo nmap -p- $IP -Pn --disable-arp-ping --stats-every 5"

# Run the first Nmap scan to find all open ports.
# -p- : Scans all 65535 ports.
# -Pn : Treats all hosts as online (skips host discovery).
# --disable-arp-ping : Prevents Nmap from using ARP pings.
# --stats-every 5 : Prints a status update every 5 seconds.
# The output is saved to a variable for later parsing.
PORTS_OUTPUT=$(sudo nmap -p- $IP -Pn --disable-arp-ping --stats-every 5)

# Extract the open ports from the scan output.
# grep -oE "([0-9]+)/open/" finds all occurrences of port/open/
# cut -d'/' -f1 extracts the port number before the '/'.
# tr '\n' ',' converts newlines to commas.
# sed 's/.$//' removes the trailing comma.
PORTS=$(echo "$PORTS_OUTPUT" | grep -oE "([0-9]+)/open/" | cut -d'/' -f1 | tr '\n' ',' | sed 's/.$//')

# Check if any ports were found.
if [ -z "$PORTS" ]; then
    echo "No open ports found on $IP. Exiting."
    exit 0
fi

echo "Open ports found: $PORTS"
echo ""

echo "Step 2: Running a more focused Nmap scan on the identified ports..."
echo "Command: sudo nmap -p $PORTS -sCV $IP -Pn --disable-arp-ping --stats-every 5"

# Run the second, more focused Nmap scan on the identified ports.
# -p $PORTS : Scans only the specified ports.
# -sC : Runs default scripts.
# -sV : Attempts to determine service versions.
# The output is saved to a variable.
SERVICE_OUTPUT=$(sudo nmap -p $PORTS -sCV $IP -Pn --disable-arp-ping --stats-every 5)

echo "$SERVICE_OUTPUT"
echo ""

# Search for a domain name in the service scan output.
# This assumes a domain name will appear in a line with 'Name' and 'is' or similar.
DOMAIN_NAME=$(echo "$SERVICE_OUTPUT" | grep -i "Name" | awk -F'Name:' '{print $2}' | awk '{print $1}' | tr -d ' ' | tr -d ')')

# Check if a domain name was found.
if [ -z "$DOMAIN_NAME" ]; then
    echo "No domain name found in the scan results. The second scan output is the final result."
else
    echo "Step 3: Domain name found ($DOMAIN_NAME)! Adding domain name to /etc/hosts"
    echo "$IP $DOMAIN_NAME" >> /etc/hosts
    echo "Running a final scan using the domain name..."
    echo "Command: sudo nmap -p $PORTS -sCV $DOMAIN_NAME -Pn --disable-arp-ping --stats-every 5"

    # Run the final Nmap scan using the domain name.
    # The output is saved to a variable for printing.
    FINAL_OUTPUT=$(sudo nmap -p $PORTS -sCV $DOMAIN_NAME -Pn --disable-arp-ping --stats-every 5)

    echo ""
    echo "Final Scan Results for $DOMAIN_NAME:"
    echo "$FINAL_OUTPUT" > "$IP Nmap_Auto Results"
fi
