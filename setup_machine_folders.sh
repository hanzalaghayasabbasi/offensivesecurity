#!/bin/bash

# Prompt for machine name
read -p "Enter the machine name: " machine_name

# Validate input
if [ -z "$machine_name" ]; then
  echo "❌ Machine name cannot be empty."
  exit 1
fi

# Create base directory and default structure
mkdir -p "$machine_name"
mkdir -p "$machine_name/exploit"
mkdir -p "$machine_name/nmap_scan/tcp"
mkdir -p "$machine_name/nmap_scan/udp"
mkdir -p "$machine_name/directory_busting/files"
mkdir -p "$machine_name/directory_busting/folders"
mkdir -p "$machine_name/vhost"
mkdir -p "$machine_name/other_scans"

echo "✅ Default directory structure created under '$machine_name'."

# Clone GitHub repository into the machine directory
repo_url="https://github.com/hanzalaghayasabbasi/offensivesecurity.git"
repo_target="$machine_name/offensivesecurity"

if [ -d "$repo_target" ]; then
  echo "⚠️ Repository already exists at '$repo_target'. Skipping clone."
else
  echo "📥 Cloning offensive security repo into '$repo_target'..."
  git clone "$repo_url" "$repo_target"
  if [ $? -eq 0 ]; then
    echo "✅ Repository cloned successfully."
  else
    echo "❌ Failed to clone repository."
  fi
fi

# Ask if user wants to create additional folders
read -p "Do you want to create any additional folders inside '$machine_name'? (yes/no): " create_more

if [[ "$create_more" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
  read -p "How many additional folders do you want to create? " folder_count

  if ! [[ "$folder_count" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid number."
    exit 1
  fi

  for (( i=1; i<=folder_count; i++ ))
  do
    read -p "Enter name for folder #$i: " folder_name
    mkdir -p "$machine_name/$folder_name"
    echo "📁 Created: $machine_name/$folder_name"

    # Ask if subfolders should be created
    read -p "Do you want to create subfolders inside '$folder_name'? (yes/no): " create_sub

    if [[ "$create_sub" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
      read -p "How many subfolders inside '$folder_name'? " sub_count

      if ! [[ "$sub_count" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid number of subfolders."
        exit 1
      fi

      for (( j=1; j<=sub_count; j++ ))
      do
        read -p "Enter name for subfolder #$j inside '$folder_name': " subfolder_name
        mkdir -p "$machine_name/$folder_name/$subfolder_name"
        echo "  └── 📂 Subfolder created: $machine_name/$folder_name/$subfolder_name"
      done
    fi
  done
else
  echo "No additional folders created."
fi

echo "✅ Setup complete."
