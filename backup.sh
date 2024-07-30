#!/bin/bash

# Script to backup hidden directories from home to $HOME/scripts, with exclusions

# Create backup directory if it doesn't exist
DIR="$HOME/OneDrive - Cox Automotive/backup/hidden_backup"
mkdir -p $DIR

# Get current date for backup file name
current_date=$(date +%Y-%m-%d)

# List of directories to exclude
exclude_dirs=(
     ".colima"
    ".npm"
    ".Trash"
    ".cache"
    ".pyenv"
    ".local"
    ".vscode"
    ".asdf"
    ".gradle"
    ".ollama"
    ".sonarlint" 
    ".cookiecutter"
    ".docker"
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

# Specify the file path
file_path="$HOME/OneDrive - Cox Automotive/backup/hidden_backup/hidden_dirs_$current_date.tar.gz"
# Get the file size in bytes
file_size=$(stat -f %z "$file_path")

# Convert 100MB to bytes (100 * 1024 * 1024)
size_threshold=$((100 * 1024 * 1024))

# Check if file size is greater than 100MB
if [ "$file_size" -gt "$size_threshold" ]; then
    #echo "The file is larger than 100MB"
    osascript -e 'tell application (path to frontmost application as text) to display dialog "Backups of hidden files is greater than 100mb.  Time to tune son..." buttons {"OK"} with icon stop'
fi

# Directory to check
directory=$DIR


# Count the number of files in the directory
file_count=$(ls -1 "$directory" | wc -l)

# Check if there are more than 14 files
if [ $file_count -gt 14 ]; then
    # Find the oldest file and remove it
    oldest_file=$(find "$directory" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
    
    if [ -n "$oldest_file" ]; then
        rm "$oldest_file"
        echo "Removed oldest file: $oldest_file"
    else
        echo "No files found to remove."
    fi
else
    echo "Directory has $file_count files. No action needed."
fi

cd $DIR
tar -tvf $file_path > files_list.log

echo "Backup of hidden directories completed: $HOME/OneDrive - Cox Automotive/backup/hidden_backup/hidden_dirs_$current_date.tar.gz"
echo "Excluded directories: ${exclude_dirs[*]}"

