#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "          BloodHound-python Automation        "
echo -e "==============================================${NC}\n"

# Get user inputs
read -p "Enter domain (e.g., marvel.local): " domain
read -p "Enter username (e.g., fcastle): " username
read -p "Enter password (special characters will be escaped automatically): " password
read -p "Enter nameserver (IP of Domain Controller): " ns_ip

# Safety check: verify user inputs
if [[ -z "$domain" || -z "$username" || -z "$password" || -z "$ns_ip" ]]; then
    echo -e "${RED}Error: All fields are required. Exiting.${NC}"
    exit 1
fi

# Check if IP is reachable
echo -e "\n${YELLOW}Checking connection to Domain Controller...${NC}"
if ping -c 1 -W 2 "$ns_ip" &> /dev/null; then
    echo -e "${CYAN}Domain Controller is reachable.${NC}"
else
    echo -e "${RED}Domain Controller is NOT reachable at $ns_ip. Please check the IP and network.${NC}"
    exit 1
fi

# Escape special characters in password
escaped_password=$(sed 's/[][\!*.^$\/#&@]/\\&/g' <<< "$password")

# Output file name for log
log_file="bloodhound_log.txt"

# Show full command
echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
echo "bloodhound-python -c ALL -u ${username} -p ${escaped_password} -d ${domain} -ns ${ns_ip} -o ."

# Ask user to proceed
read -p "Do you want to run this command now? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    timeout 120s bloodhound-python -c ALL -u "${username}" -p "${escaped_password}" -d "${domain}" -ns "${ns_ip}" -o . | tee -a "${log_file}"
    
    echo -e "\n${CYAN}BloodHound-python data collection completed.${NC}"

    if ls ./*.json 1> /dev/null 2>&1; then
        echo -e "${YELLOW}BloodHound data files successfully generated in current directory.${NC}"
    else
        echo -e "${YELLOW}No data files found. Something may have failed.${NC}"
    fi
else
    echo -e "${YELLOW}Command not executed.${NC}"
fi

