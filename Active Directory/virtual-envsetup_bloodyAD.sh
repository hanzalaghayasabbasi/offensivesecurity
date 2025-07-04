#!/bin/bash

# Color Setup
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=============================================="
echo -e "     BloodyAD Virtual Environment Setup"
echo -e "==============================================${NC}\n"

# Check if Python3 exists
if ! command -v python3 &> /dev/null
then
    echo -e "${RED}Python3 not found. Please install Python 3 first.${NC}"
    exit 1
fi

# Check if pip exists
if ! command -v pip &> /dev/null
then
    echo -e "${RED}pip not found. Please install pip first.${NC}"
    exit 1
fi

# Create virtual environment
echo -e "${YELLOW}Creating virtual environment...${NC}"
python3 -m venv bloodad-env

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create virtual environment.${NC}"
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source ./bloodad-env/bin/activate

# Clean pip cache
echo -e "${YELLOW}Cleaning pip cache...${NC}"
rm -rf ~/.cache/pip

# Install bloodyAD
echo -e "${YELLOW}Installing bloodyAD...${NC}"
pip install bloodyAD

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to install bloodyAD.${NC}"
    deactivate
    exit 1
fi

# Deactivate virtual environment after installation
deactivate

echo -e "\n${CYAN}=============================================="
echo -e "      Setup completed successfully!"
echo -e "==============================================${NC}"

echo -e "\n${YELLOW}To activate the virtual environment, run:${NC}"
echo -e "${CYAN}source ./bloodad-env/bin/activate${NC}\n"

