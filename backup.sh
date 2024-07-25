#!/bin/bash

# Script to backup hidden directories from home to $HOME/scripts, with exclusions

# Create backup directory if it doesn't exist
mkdir -p "$HOME/OneDrive - Cox Automotive/backup/hidden_backup"

# Get current date for backup file name
current_date=$(date +%Y-%m-%d)

# List of directories to exclude
exclude_dirs=(
    ".npm"
    ".Trash"
    ".cache"
    ".pyenv"
    ".local"
    ".vscode"
    ".asdf"
    ".gradle"
    ".ollama"
    ".sonarlint" # Added .vscode to the exclusion list
)

# Build the exclude options for tar
exclude_opts=""
for dir in "${exclude_dirs[@]}"; do
    exclude_opts="$exclude_opts --exclude=.$dir --exclude=.$dir/**"
done

# Find hidden directories, excluding the ones we don't want
hidden_dirs=$(find "$HOME" -maxdepth 1 -type d -name ".*" -not -name "." -not -name ".." | 
              grep -vE "$(IFS=\|; echo "${exclude_dirs[*]}" | sed 's/^/./' | sed 's/ /\\|./')")

# Create a tar archive of hidden directories, excluding specified directories
tar -czf "$HOME/OneDrive - Cox Automotive/backup/hidden_backup/hidden_dirs_$current_date.tar.gz" \
    -C "$HOME" \
    $exclude_opts \
    $(echo "$hidden_dirs" | sed 's|'"$HOME"'/||')

echo "Backup of hidden directories completed: $HOME/OneDrive - Cox Automotive/backup/hidden_backup/hidden_dirs_$current_date.tar.gz"
echo "Excluded directories: ${exclude_dirs[*]}"

