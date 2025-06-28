#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title app_ghostty
# @raycast.mode fullOutput
# @raycast.icon 👻
# @raycast.packageName Custom
# @raycast.description Open Ghostty in current Finder directory

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 获取当前目录
CURRENT_DIR=$(get_finder_current_dir)

# 在Ghostty中执行cd命令
run_in_ghostty "cd \"$CURRENT_DIR\""

# 显示成功通知
show_success "Ghostty opened in $(basename "$CURRENT_DIR")"
