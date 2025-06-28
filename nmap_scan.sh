#!/bin/bash

# Description:
# Performs full TCP and UDP port scans on a target IP using Nmap.
# Saves results inside structured folders and prints scan outputs to the screen.

# Usage: sudo ./nmap_scan.sh <target_ip>

set -e

if [ -z "$1" ]; then
    echo "Usage: sudo $0 <target_ip>"
    exit 1
fi

target_ip="$1"

# Folder structure for saving scan results
# TCP scans saved in:  nmap_scan/tcp/
# UDP scans saved in:  nmap_scan/udp/
mkdir -p nmap_scan/tcp
mkdir -p nmap_scan/udp

# Define filenames
tcp_scan_output="nmap_scan/tcp/${target_ip}_tcp_ports_temp.txt"
udp_scan_output="nmap_scan/udp/${target_ip}_udp_ports_temp.txt"
tcp_detailed_output="nmap_scan/tcp/${target_ip}_tcp_detailed_scan.txt"
udp_detailed_output="nmap_scan/udp/${target_ip}_udp_detailed_scan.txt"

open_tcp_ports=""
open_udp_ports=""

# TCP Scan Phase
echo "[*] Starting full TCP port scan on $target_ip..."
nmap -p- --min-rate 1000 -T4 "$target_ip" -oN "$tcp_scan_output" > /dev/null

while IFS= read -r line; do
    if [[ $line =~ ^[0-9]+/tcp ]]; then
        open_tcp_ports+="${line%%/*},"
    fi
done < "$tcp_scan_output"

open_tcp_ports="${open_tcp_ports%,}"

if [ -n "$open_tcp_ports" ]; then
    echo "[+] Open TCP ports found: $open_tcp_ports"
    echo "[*] Running detailed TCP scan..."
    nmap -p "$open_tcp_ports" --min-rate 1000 -sC -sV "$target_ip" -oN "$tcp_detailed_output"
    echo -e "\n[✓] TCP scan complete. Results saved to: $tcp_detailed_output"
    echo -e "\n====================================="
    echo -e   "==============UDP Scan==============="
    echo -e   "=====================================\n"
else
    echo "[-] No open TCP ports found."
fi

rm -f "$tcp_scan_output"

# UDP Scan Phase
echo "[*] Starting UDP port scan on $target_ip..."
nmap -sU --min-rate 1000 -T4 "$target_ip" -oN "$udp_scan_output" > /dev/null

while IFS= read -r line; do
    if [[ $line =~ ^[0-9]+/udp ]]; then
        open_udp_ports+="${line%%/*},"
    fi
done < "$udp_scan_output"

open_udp_ports="${open_udp_ports%,}"

if [ -n "$open_udp_ports" ]; then
    echo "[+] Open UDP ports found: $open_udp_ports"
    echo "[*] Running detailed UDP scan..."
    nmap -p "$open_udp_ports" --min-rate 1000 -sU -sC -sV "$target_ip" -oN "$udp_detailed_output"
    echo -e "\n[✓] UDP scan complete. Results saved to: $udp_detailed_output"
    echo -e "\n=====================================\n"
else
    echo "[-] No open UDP ports found."
fi

rm -f "$udp_scan_output"

 echo -e "\n====================================="
 echo -e   "====[✓] All scanning complete.======="
 echo -e   "=====================================\n"
