#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title app_nvim_ghostty
# @raycast.mode silent
# @raycast.icon 👻
# @raycast.packageName Custom
# @raycast.description Open selected file in Nvim in a new Ghostty window

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取选中的文件
SELECTED_FILE=$(get_finder_selection_single)
if [ -z "$SELECTED_FILE" ]; then
    show_error "没有在Finder中选择文件"
    exit 1
fi

# 获取文件目录
FILE_DIR=$(dirname "$SELECTED_FILE")

# 在Ghostty中执行cd和nvim命令
COMMAND="cd \"${FILE_DIR}\" && nvim \"${SELECTED_FILE}\""
run_in_ghostty "$COMMAND"

# 显示通知
show_success "Opened $(basename "$SELECTED_FILE") in Nvim"
