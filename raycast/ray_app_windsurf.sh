#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title app_windsurf
# @raycast.mode silent
# @raycast.icon 🏄‍♂️
# @raycast.packageName Custom
# @raycast.description Open Windsurf in current Finder directory

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取当前目录
CURRENT_DIR=$(get_finder_current_dir)

# Change to the directory
cd "$CURRENT_DIR"

# Open Windsurf
open -a Windsurf .

# 显示成功通知
show_success "Windsurf opened in $(basename "$CURRENT_DIR")"
