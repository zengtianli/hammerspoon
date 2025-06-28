#!/bin/bash

# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title tool_find_folder
# @raycast.mode fullOutput
# @raycast.icon 🔍
# @raycast.packageName Navigation
# @raycast.description Use FZF to find and open directories in Finder

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# Check if fzf is installed
if ! check_command_exists "fzf"; then
    show_error "FZF未安装，请先安装：brew install fzf"
    exit 1
fi

# Set temporary file for fzf output
TEMP_FILE=$(mktemp)

# Use find to list directories and pipe to fzf
# The --height option limits the height of the fzf window
# Preview shows directory contents
find $HOME -type d -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | \
fzf --height 50% --reverse --preview 'ls -la {}' > "$TEMP_FILE"

# Get the selected directory from the temp file
SELECTED_DIR=$(cat "$TEMP_FILE")
rm "$TEMP_FILE"

# Check if a directory was selected
if [[ -n "$SELECTED_DIR" ]]; then
    # Open the directory in Finder
    open -a Finder "$SELECTED_DIR"
    show_success "已在Finder中打开: $SELECTED_DIR"
else
    show_warning "没有选择目录"
fi

