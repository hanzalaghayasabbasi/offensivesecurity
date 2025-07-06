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

# Clone GitHub repo into a temp directory
repo_url="https://github.com/hanzalaghayasabbasi/offensivesecurity.git"
tmp_dir=$(mktemp -d)

echo "📥 Cloning repository to temporary location..."
git clone "$repo_url" "$tmp_dir"

if [ $? -eq 0 ]; then
  echo "✅ Clone successful. Transferring files..."

  # Remove unwanted files
  rm -f "$tmp_dir/README.md"
  rm -rf "$tmp_dir/.git"

  # Move files/folders to machine directory
  shopt -s dotglob  # include hidden files
  mv "$tmp_dir"/* "$machine_name/"
  rm -rf "$tmp_dir"

  echo "🔄 Renaming cloned script files..."

  # Rename only the cloned files in the machine directory that are scripts
  find "$machine_name" -maxdepth 1 -type f \( -iname "*.sh" -o -iname "*.py" -o -iname "*.pl" -o -iname "*.rb" \) | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    new_name="$dir/script_$base"
    mv "$file" "$new_name"
    chmod +x "$new_name"
    echo "  📄 Renamed: $base → script_$base"
  done

  echo "📁 Renaming folders (only if they contain scripts)..."

  # Rename only top-level folders (from clone) that contain scripts
  find "$machine_name" -mindepth 1 -maxdepth 1 -type d | while read -r folder; do
    if find "$folder" -type f \( -iname "*.sh" -o -iname "*.py" -o -iname "*.pl" -o -iname "*.rb" \) | grep -q .; then
      base_folder=$(basename "$folder")
      parent_folder=$(dirname "$folder")
      new_folder="$parent_folder/script_$base_folder"
      if [ "$folder" != "$new_folder" ]; then
        mv "$folder" "$new_folder"
        echo "  📂 Renamed: $base_folder → script_$base_folder"
      fi
    fi
  done

else
  echo "❌ Failed to clone repository."
  rm -rf "$tmp_dir"
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
