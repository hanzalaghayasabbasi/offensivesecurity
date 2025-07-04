#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo "              VIRTUAL HOST ENUM               "
echo -e "==============================================${NC}\n"


echo -e "${YELLOW}These are the commands I commonly use:${NC}\n"

echo -e "${CYAN}[1] wfuzz:${NC}"
echo "  sudo wfuzz -c --hc=400,404 -t 150 -w [wordlist] -u http://target -H \"Host: FUZZ.baseDomain\" --hh 985 | tee -a vhost_enum/wfuzz_vhost.txt"

echo -e "\n${CYAN}[2] ffuf (with -mc all -fc 404):${NC}"
echo "  ffuf -c -w [wordlist] -H \"Host: FUZZ.baseDomain\" -u http://baseDomain/ -t 150 -mc all -fc 404 | tee -a vhost_enum/ffuf_vhost1.txt"

echo -e "\n${CYAN}[3] ffuf (default -mc):${NC}"
echo "  ffuf -c -w [wordlist] -H \"Host: FUZZ.baseDomain\" -u http://baseDomain/ -t 150 | tee -a vhost_enum/ffuf_vhost2.txt"

echo -e "\n${CYAN}[4] gobuster:${NC}"
echo "  gobuster vhost -u http://baseDomain -w [wordlist] --append-domain -t 150 -o vhost_enum/gobuster_vhost.txt"
echo ""



read -p "Do you want to run vHost enumeration on your own domain? (y/n): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    read -p "Enter the base domain (e.g., monitorsthree.htb): " base_domain

    # Check for valid domain (reject IPs)
    if [[ "$base_domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${YELLOW}Please enter a domain name, not an IP address.${NC}"
        exit 1
    fi

    read -p "Enter the full path to the wordlist: " wordlist
    read -p "Enter number of threads (e.g., 150): " threads
    read -p "Enter output directory (default: vhosts): " output_dir

    # Default output path
    if [[ -z "$output_dir" ]]; then
        output_dir="vhosts"
    fi

    mkdir -p "$output_dir"

    # Display customized commands
    echo -e "\n${YELLOW}These are the customized commands:${NC}\n"

    echo -e "${CYAN}[1] wfuzz:${NC}"
    echo "  sudo wfuzz -c --hc=400,404 -t $threads -w $wordlist -u http://$base_domain -H \"Host: FUZZ.$base_domain\" --hh 985 | tee -a $output_dir/wfuzz_vhost.txt"

    echo -e "\n${CYAN}[2] ffuf (with -mc all -fc 404):${NC}"
    echo "  ffuf -c -w $wordlist -H \"Host: FUZZ.$base_domain\" -u http://$base_domain/ -t $threads -mc all -fc 404 | tee -a $output_dir/ffuf_vhost1.txt"

    echo -e "\n${CYAN}[3] ffuf (default -mc):${NC}"
    echo "  ffuf -c -w $wordlist -H \"Host: FUZZ.$base_domain\" -u http://$base_domain/ -t $threads | tee -a $output_dir/ffuf_vhost2.txt"

    echo -e "\n${CYAN}[4] gobuster:${NC}"
    echo "  gobuster vhost -u http://$base_domain -w $wordlist --append-domain -t $threads -o $output_dir/gobuster_vhost.txt"

    echo ""
    read -p "Do you want to run any of these commands now? (y/n): " run_now

    if [[ "$run_now" =~ ^[Yy]$ ]]; then
        read -p "Enter the numbers of the commands to run (e.g., 1 3 4): " selected

        for number in $selected; do
            echo -e "\n${CYAN}Running Command $number...${NC}"
            case $number in
                1)
                    echo -e "${YELLOW}[wfuzz]${NC}"
                    sudo wfuzz -c --hc=400,404 -t "$threads" -w "$wordlist" \
                        -u "http://$base_domain" \
                        -H "Host: FUZZ.$base_domain" --hh 985 | tee -a "$output_dir/wfuzz_vhost.txt"
                    ;;
                2)
                    echo -e "${YELLOW}[ffuf -mc all -fc 404]${NC}"
                    ffuf -c -w "$wordlist" -H "Host: FUZZ.$base_domain" \
                        -u "http://$base_domain/" -t "$threads" -mc all -fc 404 | tee -a "$output_dir/ffuf_vhost1.txt"
                    ;;
                3)
                    echo -e "${YELLOW}[ffuf default -mc]${NC}"
                    ffuf -c -w "$wordlist" -H "Host: FUZZ.$base_domain" \
                        -u "http://$base_domain/" -t "$threads" | tee -a "$output_dir/ffuf_vhost2.txt"
                    ;;
                4)
                    echo -e "${YELLOW}[gobuster]${NC}"
                    gobuster vhost -u "http://$base_domain" -w "$wordlist" \
                        --append-domain -t "$threads" -o "$output_dir/gobuster_vhost.txt"
                    ;;
                *)
                    echo -e "${YELLOW}Invalid selection: $number${NC}"
                    ;;
            esac
        done
    else
        echo -e "${YELLOW}Exiting without running any commands.${NC}"
    fi

    echo -e "\n${CYAN}Done. Results saved in '$output_dir'.${NC}"
else
    echo -e "${YELLOW}Exiting without doing anything.${NC}"
    exit 0
fi

