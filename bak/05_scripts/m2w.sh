#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="/Users/tianli/Desktop/MIKE1/changxingxian/"
DESTINATION_DIR="/Volumes/Users/Public/长兴县区域水资源论证/mike/changxingxian/"

# Use rsync to sync the directories
rsync -avz --delete --exclude='.git/' "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Synchronization complete."

