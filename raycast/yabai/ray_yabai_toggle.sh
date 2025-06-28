#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Yabai Toggle
# @raycast.mode silent
# @raycast.icon 🪟
# @raycast.packageName Custom
# @raycast.description Toggle Yabai window management service

# 引入通用函数库
source "/Users/tianli/useful_scripts/execute/raycast/common_functions.sh"

# 执行 toggle-yabai.sh 脚本
/Users/tianli/useful_scripts/execute/yabai/toggle-yabai.sh

# 检查当前状态并显示反馈
if pgrep -x "yabai" > /dev/null; then
  show_success "Yabai 服务已启动"
else
  show_error "Yabai 服务已停止"
fi
