#!/bin/bash

# Define your drives and log file
SRC="/Volumes/Soma"
DEST="/Volumes/Fisher"
LOGFILE="$HOME/.backup-drives.log"  # Adjust the path for the log file

# Check if both drives are mounted
if [[ ! -d "$SRC" || ! -d "$DEST" ]]; then
  echo "$(date): One or both drives are not mounted. Sync failed." >> "$LOGFILE"
  exit 1
fi

# Perform the sync with rsync
rsync -av --delete "$SRC/" "$DEST/" >> "$LOGFILE" 2>&1

# Log success or failure
if [ $? -eq 0 ]; then
  echo "$(date): Sync completed successfully." >> "$LOGFILE"
else
  echo "$(date): Sync failed." >> "$LOGFILE"
fi

