#!/bin/bash

# Path to your backup script
BACKUP_SCRIPT="$HOME/scripts/laptop/backup.sh"

# Path for the log file
LOG_FILE="$HOME/backup.log"

# Check if the backup script exists
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "Error: Backup script not found at $BACKUP_SCRIPT"
    exit 1
fi

# Ensure the backup script is executable
chmod +x "$BACKUP_SCRIPT"

# Create a temporary file for the new crontab
TEMP_CRON=$(mktemp)

# Write out current crontab
crontab -l > "$TEMP_CRON"

# Check if the cron job already exists
if grep -q "$BACKUP_SCRIPT" "$TEMP_CRON"; then
    echo "Cron job for backup already exists. No changes made."
else
    # Append new cron job
    echo "0 * * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1" >> "$TEMP_CRON"
    
    # Install new cron file
    crontab "$TEMP_CRON"
    echo "Cron job added successfully. Your backup will run every hour."
fi

# Remove the temporary file
rm "$TEMP_CRON"

echo "Cron job setup complete. Backups will be logged to $LOG_FILE"