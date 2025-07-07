#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "          NXC Brute Automation Tool          "
echo -e "==============================================${NC}\n"

# Ask for protocol
echo -e "${YELLOW}Choose protocol:${NC}"
echo -e " mssql     smb"
echo -e " ftp       ldap"
echo -e " nfs       rdp"
echo -e " ssh       vnc"
echo -e " winrm     wmi"
echo


read -p "Enter protocol name (e.g., mssql): " protocol

# Ask for target IP
read -p "Enter target IP address or range (e.g., 192.168.1.0/24): " ip_address

# Ask what type of authentication
echo -e "\n${YELLOW}Choose authentication method:${NC}"
echo "1) Username/Password"
echo "2) Hash"
read -p "Enter 1 or 2: " auth_method

# For username/password
if [[ "$auth_method" == "1" ]]; then
    echo -e "\n${YELLOW}Username options:${NC}"
    echo "1) Provide username file"
    echo "2) Enter single username"
    read -p "Choose option 1 or 2: " user_option

    if [[ "$user_option" == "1" ]]; then
        read -p "Enter username file path: " users_file
        users_param="-u $users_file"
    else
        read -p "Enter username: " username
        users_param="-u '$username'"
    fi

    echo -e "\n${YELLOW}Password options:${NC}"
    echo "1) Provide password file"
    echo "2) Enter single password"
    read -p "Choose option 1 or 2: " pass_option

    if [[ "$pass_option" == "1" ]]; then
        read -p "Enter password file path: " password_file
        password_param="--password-file $password_file"
    else
        read -p "Enter password (special characters will be quoted automatically): " password
        quoted_password=$(printf "%q" "$password")
        password_param="-p '$quoted_password'"
    fi

    full_command="nxc $protocol $ip_address $users_param $password_param --continue-on-success"

# For hash
elif [[ "$auth_method" == "2" ]]; then
    echo -e "\n${YELLOW}Hash options:${NC}"
    echo "1) Provide hash file"
    echo "2) Enter hash manually"
    read -p "Choose option 1 or 2: " hash_option

    if [[ "$hash_option" == "1" ]]; then
        read -p "Enter hash file path (only contains NTHASH values line by line): " hash_file
        hash_param="-H $hash_file"
    else
        echo -e "${YELLOW}You can provide:\n- NTHASH (single hash)\n- LMHASH:NTHASH (full format)${NC}"
        read -p "Enter hash value: " hash_value
        quoted_hash=$(printf "%q" "$hash_value")
        hash_param="-H '$quoted_hash'"
    fi

    echo -e "\n${YELLOW}Username options:${NC}"
    echo "1) Provide username file"
    echo "2) Enter single username"
    read -p "Choose option 1 or 2: " user_option

    if [[ "$user_option" == "1" ]]; then
        read -p "Enter username file path: " users_file
        users_param="-u $users_file"
    else
        read -p "Enter username: " username
        users_param="-u '$username'"
    fi

    full_command="nxc $protocol $ip_address $users_param $hash_param --continue-on-success"

else
    echo -e "${YELLOW}Invalid authentication option chosen.${NC}"
    exit 1
fi

# Display and confirm
echo -e "\n${YELLOW}This is the command that will be executed:${NC}"
echo "$full_command"
read -p "Do you want to run this command now? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    eval "$full_command | tee nxc_output.txt"
    echo -e "\n${CYAN}Command execution completed.${NC}"
else
    echo -e "${YELLOW}Command not executed.${NC}"
fi
