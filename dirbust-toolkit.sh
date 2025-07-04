#!/bin/bash

# Color setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'


echo -e "${CYAN}=============================================="
echo "          DIRECTORY AND FILE BUSTING          "
echo -e "==============================================${NC}\n"

echo -e "${YELLOW}These are the commands I commonly use:${NC}\n"

echo -e "${CYAN}Dirsearch:${NC}"
echo "  sudo dirsearch -u http://target/ -w [dirsearch-wordlist] -t 150 -o directory_busting/folders/dirsearch.txt -r"

echo -e "\n${CYAN}Gobuster:${NC}"
echo "  sudo gobuster dir -u http://target/ -w [gobuster-wordlist] -t 150 -o directory_busting/folders/gobuster.txt"

echo -e "\n${CYAN}FFUF:${NC}"
echo "  sudo ffuf -u http://target/FUZZ -w [ffuf-files-wordlist] -t 150 | tee -a directory_busting/files/ffuf_files.txt"
echo "  sudo ffuf -u http://target/FUZZ -w [ffuf-dirs-wordlist] -t 150 | tee -a directory_busting/folders/ffuf_dirs.txt"
echo ""

read -p "Do you want to run dirbusting on your own URL? (y/n): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    read -p "Enter the full target URL (e.g., http://10.10.11.123): " target_url
    read -p "Enter the wordlist for Dirsearch: " wordlist_dirsearch
    read -p "Enter the wordlist for Gobuster: " wordlist_gobuster
    read -p "Enter the wordlist for FFUF (Files): " wordlist_ffuf_files
    read -p "Enter the wordlist for FFUF (Dirs): " wordlist_ffuf_dirs
    read -p "Enter number of threads (e.g., 100): " threads
    read -p "Enter base output path (leave empty for default 'directory_busting'): " base_path

    # Default base path if not provided
    if [[ -z "$base_path" ]]; then
        base_path="directory_busting"
    else
        base_path="${base_path%/}"
    fi

    # Create required directories
    mkdir -p "$base_path/files"
    mkdir -p "$base_path/folders"

    echo -e "\n${CYAN}Generated Commands:${NC}"
    echo -e "${YELLOW}Below are your customized commands:${NC}\n"

    echo -e "1) sudo dirsearch -u $target_url -w $wordlist_dirsearch -t $threads -o $base_path/folders/dirsearch.txt -r\n\
2) sudo gobuster dir -u $target_url -w $wordlist_gobuster -t $threads -o $base_path/folders/gobuster.txt\n\
3) sudo ffuf -u ${target_url}/FUZZ -w $wordlist_ffuf_files -t $threads | tee -a $base_path/files/ffuf_files.txt\n\
4) sudo ffuf -u ${target_url}/FUZZ -w $wordlist_ffuf_dirs -t $threads | tee -a $base_path/folders/ffuf_dirs.txt"

    echo ""
    read -p "Do you want to run any of these commands now? (y/n): " run_choice

    if [[ "$run_choice" =~ ^[Yy]$ ]]; then
        read -p "Enter the numbers of the commands to run (e.g., 1 3 4): " selected

        for number in $selected; do
            echo -e "\n${CYAN}Running Command $number...${NC}"
            case $number in
                1) sudo dirsearch -u "$target_url" -w "$wordlist_dirsearch" -t "$threads" -o "$base_path/folders/dirsearch.txt" -r ;;
                2) sudo gobuster dir -u "$target_url" -w "$wordlist_gobuster" -t "$threads" -o "$base_path/folders/gobuster.txt" ;;
                3) sudo ffuf -u "${target_url}/FUZZ" -w "$wordlist_ffuf_files" -t "$threads" | tee -a "$base_path/files/ffuf_files.txt" ;;
                4) sudo ffuf -u "${target_url}/FUZZ" -w "$wordlist_ffuf_dirs" -t "$threads" | tee -a "$base_path/folders/ffuf_dirs.txt" ;;
                *) echo -e "${YELLOW}Invalid selection: $number${NC}" ;;
            esac
        done
    else
        echo -e "${YELLOW}Exiting without running commands.${NC}"
    fi
else
    echo -e "${YELLOW}Exiting without doing anything.${NC}"
    exit 0
fi

echo -e "\n${CYAN}Done. Results saved in '$output_dir'.${NC}"

