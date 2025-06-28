#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="/Volumes/Users/Public/长兴县区域水资源论证/mike/changxingxian/"
DESTINATION_DIR="/Users/tianli/Desktop/MIKE1/changxingxian/"

# Use rsync to sync the directories
rsync -avz --delete --exclude='.git/' "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Synchronization complete."
