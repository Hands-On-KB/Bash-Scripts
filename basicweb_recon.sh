#!/bin/bash

# A script to automate directory and subdomain scans on a target.
#
# Usage:
#   ./basicweb_recon.sh <tool> <target_url> <dir_wordlist> <subdomain_wordlist>
#
# Arguments:
#   <tool>              : The reconnaissance tool to use (gobuster, feroxbuster, or ffuf).
#   <target_url>        : The target URL or IP address (e.g., http://example.com).
#   <dir_wordlist>      : The path to the directory wordlist file.
#   <subdomain_wordlist>: The path to the subdomain/vhost wordlist file.
#
# Example:
#   ./basicweb_recon.sh gobuster http://example.com /usr/share/wordlists/dirb/common.txt /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1mil-5000.txt

# Check if the correct number of arguments were provided.
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <tool> <target_url> <dir_wordlist> <subdomain_wordlist>"
    exit 1
fi

TOOL="$1"
TARGET_URL="$2"
DIR_WORDLIST="$3"
SUBDOMAIN_WORDLIST="$4"

# --- Function to check if a command exists ---
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# --- Tool-specific configuration and execution ---
case "$TOOL" in
    gobuster)
        if ! command_exists gobuster; then
            echo "Error: gobuster is not installed. Please install it to use this option."
            exit 1
        fi
        echo "Running GoBuster scans on $TARGET_URL..."

        # Directory Scan with gobuster
        echo "Step 1: Running directory scan..."
        gobuster dir -u "$TARGET_URL" -w "$DIR_WORDLIST" -t 50 -o "gobuster_dir_scan.txt"

        # Subdomain/Vhost Scan with gobuster
        echo ""
        echo "Step 2: Running subdomain/virtual host scan..."
        gobuster vhost -u "$TARGET_URL" -w "$SUBDOMAIN_WORDLIST" -t 50 -o "gobuster_vhost_scan.txt"
        ;;
    feroxbuster)
        if ! command_exists feroxbuster; then
            echo "Error: feroxbuster is not installed. Please install it to use this option."
            exit 1
        fi
        echo "Running FeroxBuster scans on $TARGET_URL..."

        # Directory Scan with feroxbuster
        echo "Step 1: Running directory scan..."
        feroxbuster -u "$TARGET_URL" -w "$DIR_WORDLIST" --extract-links --output "feroxbuster_dir_scan.txt"

        # Feroxbuster does not have a dedicated subdomain mode. We will use a vhost scan.
        echo ""
        echo "Step 2: Running subdomain/virtual host scan..."
        # Note: Feroxbuster's vhost scan uses the -H flag to specify the Host header
        feroxbuster -u "$TARGET_URL" -w "$SUBDOMAIN_WORDLIST" -H "Host:FUZZ.$TARGET_URL" --output "feroxbuster_vhost_scan.txt"
        ;;
    ffuf)
        if ! command_exists ffuf; then
            echo "Error: ffuf is not installed. Please install it to use this option."
            exit 1
        fi
        echo "Running FFUF scans on $TARGET_URL..."

        # Directory Scan with ffuf
        echo "Step 1: Running directory scan..."
        ffuf -u "$TARGET_URL/FUZZ" -w "$DIR_WORDLIST" -o "ffuf_dir_scan.json"

        # Subdomain Scan with ffuf
        echo ""
        echo "Step 2: Running subdomain scan..."
        ffuf -u "$TARGET_URL" -H "Host:FUZZ.$TARGET_URL" -w "$SUBDOMAIN_WORDLIST" -o "ffuf_subdomain_scan.json"
        ;;
    *)
        echo "Error: Invalid tool specified. Please choose one of: gobuster, feroxbuster, ffuf"
        exit 1
        ;;
esac

echo ""
echo "Reconnaissance scans completed."
